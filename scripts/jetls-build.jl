#!/usr/bin/env -S julia --startup-file=no --history-file=no
#
# Build, update, and remove native `jetls` executables: JETLS.jl compiled ahead
# of time by JuliaC.
#
# Requires only a Julia installation and git; the script provisions everything
# else. Run `jetls-build.jl --help` for usage.
#
# `serve` and `check` work in the compiled executable. `schema --settings` and its
# siblings do not: they read files from a directory JuliaC compiles from and then
# discards, so the path baked into the binary no longer exists. Read the schemas
# from a JETLS checkout, or from the `jetls` app installed by `Pkg.Apps`.

const ROOT = get(ENV, "JETLS_HOME", joinpath(homedir(), ".local", "share", "jetls"))
const BUILD_DIR = joinpath(ROOT, "build")
const DRIVER_ENV = joinpath(BUILD_DIR, "driver")
const BIN_DIR = joinpath(homedir(), ".local", "bin")
const MANIFEST = joinpath(ROOT, "manifest.json")

const JETLS_URL = "https://github.com/aviatesk/JETLS.jl"
const DEFAULT_REV = "release"

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
        so on older Julia there is nothing to compile with. JETLS itself declares
        `julia = "1.12.2"` in its `[compat]`, so no older channel can run it either.

        Build against a 1.12+ channel instead, for example `--julia release`.
        """))

    return (; cmd, version, channel)
end

minor_tag(v::VersionNumber) = "$(v.major).$(v.minor)"
exe_name(v::VersionNumber) = "jetls-$(minor_tag(v))"
bundle_dir(v::VersionNumber) = joinpath(ROOT, exe_name(v))
source_dir(v::VersionNumber) = joinpath(BUILD_DIR, "JETLS-$(minor_tag(v))")
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
    sync_source!(dir, rev; update) -> String

Put a JETLS checkout at `rev` in `dir` and return the commit it resolves to.
Cloning rather than adding the package to an environment gives JuliaC the package
directory it wants, and gives `update` a plain `git fetch`.

One checkout per Julia minor version: the resolved `Manifest.toml` lives beside the
sources, so a build for one version cannot disturb another's resolution.
"""
function sync_source!(dir::AbstractString, rev::AbstractString; update::Bool)
    if !isdir(joinpath(dir, ".git"))
        mkpath(dirname(dir))
        ispath(dir) && rm(dir; recursive = true)
        @info "Cloning JETLS" url = JETLS_URL rev dir
        run(`git clone --quiet $JETLS_URL $dir`)
        run(`git -C $dir checkout --quiet $rev`)
    elseif update
        @info "Updating JETLS checkout" rev dir
        run(`git -C $dir fetch --quiet --tags origin`)
        # Discard the Manifest.toml written by earlier resolutions so the checkout
        # can move; it is regenerated by `Pkg.instantiate`.
        run(`git -C $dir checkout --quiet -- .`)
        run(`git -C $dir checkout --quiet $rev`)
        # A branch name needs the fetched tip; a tag or commit is already there.
        success(`git -C $dir symbolic-ref --quiet HEAD`) &&
            run(`git -C $dir reset --quiet --hard origin/$rev`)
    end
    return readchomp(`git -C $dir rev-parse HEAD`)
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
    resolve_source!(jl, dir; update)

Instantiate the JETLS project under `jl`, upgrading dependencies first if asked.
Most of what JETLS depends on is vendored in its own repository and pinned by
revision in `[sources]`, so `Pkg.update()` only moves the few registered packages.
"""
function resolve_source!(jl, dir::AbstractString; update::Bool)
    @info "Resolving JETLS dependencies" julia = jl.version update
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
    source_versions(jl, dir, commit) -> Dict{String,Any}

What went into the binary: the JETLS release date string, the commit it was built
from, the versions of the analysis packages, and the checkout the build read. The
executable does not depend on the checkout at run time — everything it serves is
compiled in — so this is a record for tracing a binary back to a revision.
"""
function source_versions(jl, dir::AbstractString, commit::AbstractString)
    version_file = joinpath(dir, "JETLS_VERSION")
    out = Dict{String,Any}(
        "JETLS" => isfile(version_file) ? strip(read(version_file, String)) : "unknown",
        "commit" => commit,
        "source" => dir,
    )
    code = """
        using Pkg, TOML
        out = Dict{String,Any}()
        for (_, info) in Pkg.dependencies()
            info.name in ("JET", "JuliaLowering", "JuliaSyntax", "LSP", "Compiler") || continue
            out[info.name] = string(info.version)
        end
        TOML.print(stdout, out)
        """
    return merge(out, TOML.parse(julia_run(jl, dir, code; capture = true)))
end

# ---------------------------------------------------------------------------
# Compilation
# ---------------------------------------------------------------------------

"""
    julia_paths(jl) -> NamedTuple

Directories of the Julia installation behind `jl.cmd`.
"""
function julia_paths(jl)
    code = """
        println(Sys.BINDIR)
        println(Sys.STDLIB)
        println(abspath(Sys.BINDIR, Base.LIBEXECDIR))
        println(abspath(Sys.BINDIR, Base.DATAROOTDIR, "julia", "base"))
        println(abspath(Sys.BINDIR, Base.LIBDIR, "julia"))
        """
    cmd = addenv(`$(jl.cmd) --startup-file=no --history-file=no -e $code`,
                 "JULIA_LOAD_PATH" => nothing)
    bindir, stdlib, libexec, base, libjulia = split(strip(read(cmd, String)), '\n')
    return (; bindir = String(bindir), stdlib = String(stdlib),
              libexec = String(libexec), base = String(base),
              libjulia = String(libjulia))
end

"""
    bundle_julia_data!(jl, out)

Copy the parts of a Julia installation that `--bundle` omits but the running
server still reaches for relative to its own `Sys.BINDIR`:

  * `share/julia/stdlib/vX.Y` — what `@stdlib` on `LOAD_PATH` resolves to, and what
    `Pkg.Types.load_stdlib()` reads to tell stdlib manifest entries from ordinary
    ones. JETLS loads a project's packages into its own process, so it needs both.
  * `libexec/julia` — holds the `7z` that Pkg uses to read the compressed General
    registry.
  * `share/julia/base` — the Julia sources that `methods` output points at.
    Go-to-definition and hover on anything from `Base` resolve through them.
"""
function bundle_julia_data!(jl, out::AbstractString)
    p = julia_paths(jl)
    copied = String[]

    for (src, dst) in (
        p.stdlib => joinpath(out, "share", "julia", "stdlib", "v$(minor_tag(jl.version))"),
        p.libexec => joinpath(out, "libexec"),
        p.base => joinpath(out, "share", "julia", "base"),
    )
        isdir(src) || throw(BuildError("no directory at $src"))
        mkpath(dirname(dst))
        ispath(dst) && rm(dst; recursive = true)
        cp(src, dst; follow_symlinks = true)
        push!(copied, dst)
    end

    @info "Bundled Julia data files" copied
end

"""
    bundle_julia_libs!(jl, out)

Fill in the shared libraries `--bundle` leaves out of `lib/julia`.

JuliaC copies only what the compiled program itself loads. JETLS loads a project's
packages into its own process, and those reach stdlibs JETLS never touches: a
project that pulls in `SparseArrays` has `SuiteSparse_jll` dlopen `libamd`, which
resolves relative to the bundle and is otherwise absent.

Entries JuliaC already placed are left as they are, since it rewrites install names
as it copies. `sys.dylib` and the `*.dSYM` bundles are skipped: the system image
this executable runs is linked into the executable, and debug symbols are never
read at run time.
"""
function bundle_julia_libs!(jl, out::AbstractString)
    p = julia_paths(jl)
    dst_dir = joinpath(out, "lib", "julia")
    isdir(dst_dir) || throw(BuildError("no lib/julia in the bundle at $dst_dir"))

    added = String[]
    for name in readdir(p.libjulia)
        (name == "sys.dylib" || endswith(name, ".dSYM")) && continue
        dst = joinpath(dst_dir, name)
        (ispath(dst) || islink(dst)) && continue
        cp(joinpath(p.libjulia, name), dst; follow_symlinks = false)
        push!(added, name)
    end

    @info "Bundled stdlib shared libraries" count = length(added) dir = dst_dir
end

"""
    bundle_julia_exe!(jl, out)

Put the Julia that built the bundle next to the executable, as `bin/julia`.

`Base.julia_cmd()` names `joinpath(Sys.BINDIR, "julia")`, and Julia spawns exactly
that to write a package's precompile cache. JETLS loads a project's packages into
its own process, so it reaches code loading — and therefore precompilation — on any
project whose caches are not current.

This copy only starts under the `--sysimage` flag `julia_cmd()` supplies, which
points back at the compiled executable: the bundle ships no separate `sys.dylib`.
Replacing it with a symlink to the original installation would point the child at
a different `Sys.BINDIR`, and so at a different stdlib than the parent is using.
"""
function bundle_julia_exe!(jl, out::AbstractString)
    p = julia_paths(jl)
    src = joinpath(p.bindir, "julia")
    isfile(src) || throw(BuildError("no julia executable at $src"))
    dst = joinpath(out, "bin", "julia")
    ispath(dst) && rm(dst)
    cp(src, dst; follow_symlinks = true)
    chmod(dst, 0o755)
    @info "Bundled Julia executable" dst
end

"""
    compile!(jl, dir; verbose, lazy_artifacts) -> String

Compile the JETLS checkout in `dir` into `bundle_dir(jl.version)` and return the
executable.

No `--trim`: JETLS runs the compiler on user code, loads packages through
`Base.require`, and dispatches dynamically throughout, none of which static
reachability analysis can follow. `--project` is deliberately absent — JuliaC
rejects it alongside a package directory and takes the project from the directory
itself.
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
    @info "Compiling" julia = jl.version source = dir output = out
    verbose && @info "JuliaC invocation" cmd
    run(cmd)

    exe = joinpath(out, "bin", name)
    isfile(exe) || error("JuliaC reported success but produced no executable at $exe")
    bundle_julia_data!(jl, out)
    bundle_julia_libs!(jl, out)
    bundle_julia_exe!(jl, out)
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

function build_one(channel::AbstractString, rev::AbstractString;
                   update::Bool, verbose::Bool, lazy_artifacts::Bool)
    jl = resolve_julia(channel)
    dir = source_dir(jl.version)
    commit = sync_source!(dir, rev; update)
    resolve_source!(jl, dir; update)
    deps = source_versions(jl, dir, commit)
    exe = compile!(jl, dir; verbose, lazy_artifacts)
    link = link!(exe)
    record!(jl, exe, deps)
    @info "Built" executable = exe link bundle = Base.format_bytes(dir_size(bundle_dir(jl.version))) JETLS = get(deps, "JETLS", "?") commit
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
        prog = "jetls-build",
        description = "Build native JETLS.jl executables with JuliaC. " *
                      "One executable per Julia minor version, named for it.",
        commands_are_required = true,
    )
    @add_arg_table! s begin
        "build"
            help = "compile executables for the given Julia channels"
            action = :command
        "update"
            help = "fetch the newest JETLS, upgrade its dependencies, and rebuild"
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
            "--rev"
                help = "JETLS branch, tag, or commit to build"
                arg_type = String
                default = DEFAULT_REV
                metavar = "REV"
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
            help = "also remove the JETLS checkouts, the build environments, and the manifest"
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
        build_one(channel, opts["rev"];
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
        println(stderr, "jetls-build: ", err.msg)
        return 1
    end
end

exit(cli())
