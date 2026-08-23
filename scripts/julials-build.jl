#!/usr/bin/env -S julia --startup-file=no --history-file=no
#
# Build, update, and remove native `julials` executables: LanguageServer.jl
# compiled ahead of time by JuliaC.
#
# Requires only a Julia installation; the script provisions everything else.
# Run `julials-build.jl --help` for usage.

const ROOT = get(ENV, "JULIALS_HOME", joinpath(homedir(), ".local", "share", "julials"))
const BUILD_DIR = joinpath(ROOT, "build")
const DRIVER_ENV = joinpath(BUILD_DIR, "driver")
const APP_SOURCE = joinpath(@__DIR__, "JuliaLSApp")
const BIN_DIR = joinpath(homedir(), ".local", "bin")
const MANIFEST = joinpath(ROOT, "manifest.json")

# JuliaC.jl is wrapped in `@static if VERSION >= v"1.12.0-rc1"`; below that the
# module is empty and no executable can be produced.
const MIN_JULIA = v"1.12.0-rc1"

# ---------------------------------------------------------------------------
# Driver environment
# ---------------------------------------------------------------------------

using Pkg

mkpath(DRIVER_ENV)
Pkg.activate(DRIVER_ENV; io = devnull)
isfile(joinpath(DRIVER_ENV, "Manifest.toml")) || Pkg.add(["ArgParse", "JSON"]; io = devnull)

using ArgParse
using Dates
using JSON
using TOML

"""
    BuildError(msg)

A problem with how the build was requested, as opposed to a bug. Reported without
a stacktrace, since the message is the whole story.
"""
struct BuildError <: Exception
    msg::String
end
Base.showerror(io::IO, e::BuildError) = print(io, e.msg)

# ---------------------------------------------------------------------------
# Julia channel resolution
# ---------------------------------------------------------------------------

"""
    julia_cmd_for(channel) -> Cmd

Command that launches `channel`. A path to an executable is used as given;
anything else is treated as a juliaup channel and reached through `julia +channel`.
"""
function julia_cmd_for(channel::AbstractString)
    isfile(channel) && return `$channel`
    channel == "default" && return `julia`
    return `julia +$channel`
end

"""
    julia_version(cmd) -> VersionNumber
"""
function julia_version(cmd::Cmd)
    out = try
        read(`$cmd --version`, String)
    catch err
        throw(BuildError("cannot run `$cmd`: $(sprint(showerror, err))"))
    end
    m = match(r"(\d+\.\d+\.\d+[^\s]*)", out)
    m === nothing && throw(BuildError("could not read a version from `$cmd --version`: $(repr(out))"))
    return VersionNumber(m.captures[1])
end

"""
    resolve_julia(channel; require_juliac = true) -> NamedTuple

Resolve `channel` to a Julia command and its version. With `require_juliac`, reject
versions JuliaC cannot compile with.
"""
function resolve_julia(channel::AbstractString; require_juliac::Bool = true)
    cmd = julia_cmd_for(channel)
    version = julia_version(cmd)

    require_juliac && version < MIN_JULIA && throw(BuildError("""
        JuliaC requires Julia >= $MIN_JULIA; channel `$channel` resolves to $version.

        JuliaC.jl guards its entire module with `@static if VERSION >= v"1.12.0-rc1"`,
        so on older Julia there is nothing to compile with. Julia $version gets no
        native julials binary; Neovim falls back to launching LanguageServer.jl from
        source for projects on that version.

        Build against a 1.12+ channel instead, for example `--julia release`.
        """))

    return (; cmd, version, channel)
end

minor_tag(v::VersionNumber) = "$(v.major).$(v.minor)"
exe_name(v::VersionNumber) = "julials-$(minor_tag(v))"
bundle_dir(v::VersionNumber) = joinpath(ROOT, exe_name(v))
app_dir(v::VersionNumber) = joinpath(BUILD_DIR, "JuliaLSApp-$(minor_tag(v))")
juliac_env(v::VersionNumber) = joinpath(BUILD_DIR, "juliac-$(minor_tag(v))")

# ---------------------------------------------------------------------------
# Build state
# ---------------------------------------------------------------------------

read_manifest() = isfile(MANIFEST) ? JSON.parsefile(MANIFEST) : Dict{String,Any}()

function write_manifest(m::AbstractDict)
    mkpath(dirname(MANIFEST))
    open(MANIFEST, "w") do io
        JSON.print(io, m, 2)
        println(io)
    end
end

"""
    sync_app!(dir)

Copy the app sources into `dir`. `Project.toml` and `src/` are owned by the
repository; the resolved `Manifest.toml` stays in the build tree, one per Julia
minor version, so resolution survives between builds.
"""
function sync_app!(dir::AbstractString)
    isdir(APP_SOURCE) || throw(BuildError("app sources missing: $APP_SOURCE"))
    mkpath(joinpath(dir, "src"))
    cp(joinpath(APP_SOURCE, "Project.toml"), joinpath(dir, "Project.toml"); force = true)
    for f in readdir(joinpath(APP_SOURCE, "src"))
        cp(joinpath(APP_SOURCE, "src", f), joinpath(dir, "src", f); force = true)
    end
end

"""
    julia_run(jl, project, code; capture = false)

Run `code` under `jl.cmd` with `project` active. `JULIA_LOAD_PATH` is cleared so a
parent environment cannot leak into the build.
"""
function julia_run(jl, project::AbstractString, code::AbstractString; capture::Bool = false)
    cmd = addenv(
        `$(jl.cmd) --startup-file=no --history-file=no --project=$project -e $code`,
        "JULIA_LOAD_PATH" => nothing,
    )
    capture || (run(cmd); return "")
    buf = IOBuffer()
    run(pipeline(cmd; stdout = buf))
    return String(take!(buf))
end

"""
    resolve_app!(jl, dir; update)

Instantiate the app project under `jl`, upgrading dependencies first if asked.
"""
function resolve_app!(jl, dir::AbstractString; update::Bool)
    @info "Resolving JuliaLSApp dependencies" julia = jl.version update
    op = update ? "Pkg.update()" : "Pkg.instantiate()"
    julia_run(jl, dir, "using Pkg; $op; Pkg.precompile()")
end

"""
    ensure_juliac!(jl) -> String

Install JuliaC into a per-version environment and return its path.
"""
function ensure_juliac!(jl)
    env = juliac_env(jl.version)
    mkpath(env)
    if !isfile(joinpath(env, "Manifest.toml"))
        @info "Installing JuliaC" julia = jl.version env
        julia_run(jl, env, "using Pkg; Pkg.add(\"JuliaC\")")
    end
    return env
end

"""
    app_dep_versions(jl, dir) -> Dict{String,Any}

Versions resolved into the app project, plus the on-disk source of SymbolServer.
SymbolServer freezes `joinpath(@__DIR__, "server.jl")` into the binary at compile
time, so if that directory ever disappears indexing breaks; recording it here makes
that failure traceable.
"""
function app_dep_versions(jl, dir::AbstractString)
    code = """
        using Pkg, TOML
        out = Dict{String,Any}()
        for (_, info) in Pkg.dependencies()
            info.name in ("LanguageServer", "SymbolServer", "StaticLint", "CSTParser") || continue
            out[info.name] = string(info.version)
            info.name == "SymbolServer" && (out["SymbolServerSource"] = info.source)
        end
        TOML.print(stdout, out)
        """
    return TOML.parse(julia_run(jl, dir, code; capture = true))
end

# ---------------------------------------------------------------------------
# Compilation
# ---------------------------------------------------------------------------

"""
    julia_paths(jl) -> NamedTuple

Directories of the Julia installation behind `jl.cmd`.
"""
function julia_paths(jl)
    code = "println(Sys.BINDIR); println(Sys.STDLIB); println(abspath(Sys.BINDIR, Base.LIBEXECDIR))"
    cmd = addenv(`$(jl.cmd) --startup-file=no --history-file=no -e $code`,
                 "JULIA_LOAD_PATH" => nothing)
    bindir, stdlib, libexec = split(strip(read(cmd, String)), '\n')
    return (; bindir = String(bindir), stdlib = String(stdlib), libexec = String(libexec))
end

"""
    bundle_julia_data!(jl, out)

Copy the parts of a Julia installation that `--bundle` omits but the running
server still reaches for relative to its own `Sys.BINDIR`:

  * `share/julia/stdlib/vX.Y` — `Pkg.Types.load_stdlib()` reads this directory to
    tell stdlib manifest entries from ordinary ones. Without it, every request
    that touches a project manifest throws `IOError: readdir(...) ENOENT`.
  * `libexec/julia` — holds the `7z` that Pkg uses to read the compressed General
    registry. Without it SymbolServer cannot tell public packages from private
    ones, so it declines to download any prebuilt symbol cache and indexes every
    dependency locally instead.
"""
function bundle_julia_data!(jl, out::AbstractString)
    p = julia_paths(jl)

    stdlib_dst = joinpath(out, "share", "julia", "stdlib", "v$(minor_tag(jl.version))")
    isdir(p.stdlib) || throw(BuildError("no stdlib directory at $(p.stdlib)"))
    mkpath(dirname(stdlib_dst))
    ispath(stdlib_dst) && rm(stdlib_dst; recursive = true)
    cp(p.stdlib, stdlib_dst; follow_symlinks = true)

    libexec_dst = joinpath(out, "libexec")
    isdir(p.libexec) || throw(BuildError("no libexec directory at $(p.libexec)"))
    ispath(libexec_dst) && rm(libexec_dst; recursive = true)
    cp(p.libexec, libexec_dst; follow_symlinks = true)

    @info "Bundled Julia data files" stdlib = stdlib_dst libexec = libexec_dst
end

"""
    compile!(jl, dir; verbose, lazy_artifacts) -> String

Compile the app in `dir` into `bundle_dir(jl.version)` and return the executable.

No `--trim`: LanguageServer.jl reaches through `Pkg`, `eval`, and dynamic dispatch,
which static reachability analysis cannot follow, so the bundle keeps full IR and is
correspondingly large. `--project` is deliberately absent — JuliaC rejects it
alongside a package directory and takes the project from the directory itself.
"""
function compile!(jl, dir::AbstractString; verbose::Bool, lazy_artifacts::Bool)
    out = bundle_dir(jl.version)
    name = exe_name(jl.version)
    env = ensure_juliac!(jl)

    ispath(out) && rm(out; recursive = true)
    mkpath(out)

    juliac_args = String["--output-exe", name, "--bundle", out]
    lazy_artifacts && push!(juliac_args, "--bundle-lazy-artifacts")
    verbose && push!(juliac_args, "--verbose")
    push!(juliac_args, dir)

    cmd = addenv(
        `$(jl.cmd) --startup-file=no --history-file=no --project=$env -e "using JuliaC; JuliaC.main(ARGS)" -- $juliac_args`,
        "JULIA_LOAD_PATH" => nothing,
    )
    @info "Compiling" julia = jl.version output = out
    verbose && @info "JuliaC invocation" cmd
    run(cmd)

    exe = joinpath(out, "bin", name)
    isfile(exe) || error("JuliaC reported success but produced no executable at $exe")
    bundle_julia_data!(jl, out)
    return exe
end

"""
    link!(exe) -> String

Point a stable name in `~/.local/bin` at the bundled executable.
"""
function link!(exe::AbstractString)
    mkpath(BIN_DIR)
    link = joinpath(BIN_DIR, basename(exe))
    (ispath(link) || islink(link)) && rm(link)
    symlink(exe, link)
    return link
end

function dir_size(dir::AbstractString)
    total = 0
    for (root, _, files) in walkdir(dir), f in files
        p = joinpath(root, f)
        islink(p) || (total += filesize(p))
    end
    return total
end

function record!(jl, exe::AbstractString, deps::AbstractDict)
    m = read_manifest()
    m[exe_name(jl.version)] = Dict(
        "julia_version" => string(jl.version),
        "channel" => jl.channel,
        "executable" => exe,
        "bundle" => bundle_dir(jl.version),
        "built" => string(now()),
        "dependencies" => deps,
    )
    write_manifest(m)
end

function build_one(channel::AbstractString; update::Bool, verbose::Bool, lazy_artifacts::Bool)
    jl = resolve_julia(channel)
    dir = app_dir(jl.version)
    sync_app!(dir)
    resolve_app!(jl, dir; update)
    deps = app_dep_versions(jl, dir)
    exe = compile!(jl, dir; verbose, lazy_artifacts)
    link = link!(exe)
    record!(jl, exe, deps)
    @info "Built" executable = exe link bundle = Base.format_bytes(dir_size(bundle_dir(jl.version))) LanguageServer = get(deps, "LanguageServer", "?")
    return exe
end

# ---------------------------------------------------------------------------
# clean
# ---------------------------------------------------------------------------

function clean(channels::Vector{String}; all::Bool)
    m = read_manifest()
    names = if all || isempty(channels)
        collect(keys(m))
    else
        [exe_name(resolve_julia(c; require_juliac = false).version) for c in channels]
    end

    for name in names
        for path in (joinpath(ROOT, name), joinpath(BIN_DIR, name))
            if ispath(path) || islink(path)
                @info "Removing" path
                rm(path; recursive = true)
            end
        end
        delete!(m, name)
    end

    if all
        for path in (BUILD_DIR, MANIFEST)
            ispath(path) && (@info "Removing" path; rm(path; recursive = true))
        end
        isdir(ROOT) && isempty(readdir(ROOT)) && rm(ROOT)
    else
        write_manifest(m)
    end
end

# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

function argparser()
    s = ArgParseSettings(
        prog = "julials-build",
        description = "Build native LanguageServer.jl executables with JuliaC. " *
                      "One executable per Julia minor version, named for it.",
        commands_are_required = true,
    )
    @add_arg_table! s begin
        "build"
            help = "compile executables for the given Julia channels"
            action = :command
        "update"
            help = "upgrade LanguageServer.jl and rebuild"
            action = :command
        "clean"
            help = "remove executables and build artifacts"
            action = :command
    end

    for cmd in ("build", "update")
        @add_arg_table! s[cmd] begin
            "--julia"
                help = "juliaup channel or path to a Julia executable; repeatable (default: release)"
                arg_type = String
                action = :append_arg
                metavar = "CHANNEL"
            "--lazy-artifacts"
                help = "also bundle lazily downloaded artifacts"
                action = :store_true
            "--verbose"
                help = "print the underlying JuliaC invocation and its output"
                action = :store_true
        end
    end

    @add_arg_table! s["clean"] begin
        "--julia"
            help = "only clean this channel's executable; repeatable"
            arg_type = String
            action = :append_arg
            metavar = "CHANNEL"
        "--all"
            help = "also remove the build environments and the manifest"
            action = :store_true
    end
    return s
end

function main()
    args = parse_args(ARGS, argparser())
    cmd = args["%COMMAND%"]
    opts = args[cmd]

    if cmd == "clean"
        clean(opts["julia"]; all = opts["all"])
        return 0
    end

    channels = isempty(opts["julia"]) ? ["release"] : opts["julia"]
    for channel in channels
        build_one(channel;
                  update = cmd == "update",
                  verbose = opts["verbose"],
                  lazy_artifacts = opts["lazy-artifacts"])
    end
    return 0
end

function cli()
    try
        return main()
    catch err
        err isa BuildError || rethrow()
        println(stderr, "julials-build: ", err.msg)
        return 1
    end
end

exit(cli())
