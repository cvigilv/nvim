"""
    JuliaLSApp

Command-line front end for `LanguageServer.jl`, shaped for ahead-of-time
compilation by JuliaC into a native executable.

Every setting the server needs at startup — the environment to analyze, the depot,
the symbol-cache location, and the Julia binary used for indexing — arrives on the
command line, so one binary serves any editor configuration.
"""
module JuliaLSApp

using LanguageServer

const LS_VERSION = something(pkgversion(LanguageServer), v"0.0.0")
const BUILD_JULIA_VERSION = VERSION

const USAGE = """
julials — LanguageServer.jl compiled for Julia $(BUILD_JULIA_VERSION.major).$(BUILD_JULIA_VERSION.minor)

Speaks the Language Server Protocol over stdin/stdout. Editors normally supply
every option below; the defaults exist so the binary is usable on its own.

Usage: julials [options]

Options:
  --env PATH                  Julia environment to analyze. Defaults to the project
                              containing the working directory, else the default
                              global environment.
  --depot PATH                Depot handed to the indexing subprocess. Empty means
                              inherit the ambient JULIA_DEPOT_PATH.
  --symbol-store PATH         Directory for the symbol cache.
  --julia-exe PATH            Julia binary used to index packages. Defaults to the
                              first `julia` on PATH.
  --julia-version VERSION     Version of --julia-exe, to skip probing it.
  --no-download               Do not fetch precomputed symbol caches.
  --symbolcache-upstream URL  Alternative symbol-cache server.
  -v, --version               Print version information and exit.
  -h, --help                  Print this message and exit.
"""

version_string() =
    "julials (LanguageServer.jl $LS_VERSION, Julia $BUILD_JULIA_VERSION)"

"""
    default_env() -> String

Environment to analyze when the caller names none: the project enclosing the
working directory, falling back to the default global environment.
"""
function default_env()
    project = Base.current_project(pwd())
    project === nothing || return dirname(project)
    return dirname(Base.load_path_expand("@v#.#"))
end

default_symbol_store() = joinpath(homedir(), ".cache", "julials", "symbolstore")

"""
    parse_version_output(s) -> VersionNumber

Pull the version out of `julia --version` output.
"""
function parse_version_output(s::AbstractString)
    m = match(r"(\d+\.\d+\.\d+[^\s]*)", s)
    m === nothing && error("could not read a version number from: $(repr(s))")
    return VersionNumber(m.captures[1])
end

"""
    julia_exe_info(path, version) -> NamedTuple{(:path, :version)}

Locate the Julia binary `SymbolServer` spawns to index packages. This binary is
not it: inside a compiled bundle `Sys.BINDIR` holds `julials`, not `julia`, so
`SymbolServer`'s own default would point at a file that does not exist.
"""
function julia_exe_info(path::AbstractString, version::AbstractString)
    if isempty(path)
        found = Sys.which("julia")
        found === nothing && error(
            "no --julia-exe given and no `julia` on PATH; SymbolServer needs a real " *
            "Julia binary to index packages"
        )
        path = found
    end
    isfile(path) || error("--julia-exe is not a file: $path")

    v = isempty(version) ? parse_version_output(read(`$path --version`, String)) :
        VersionNumber(version)

    if (v.major, v.minor) != (BUILD_JULIA_VERSION.major, BUILD_JULIA_VERSION.minor)
        @warn "Indexing Julia differs from the one this binary was built against; \
               symbol caches are keyed by version and will not be shared" indexer = v build = BUILD_JULIA_VERSION
    end
    return (path = String(path), version = v)
end

"""
    parse_argv(args) -> NamedTuple

Parse the command line. Unknown flags are an error rather than a silent no-op:
a typo in an editor config should surface immediately, not as a server that
quietly ignores half its configuration.
"""
function parse_argv(args::Vector{String})
    env_path = ""
    depot_path = ""
    symbol_store = ""
    julia_exe = ""
    julia_version = ""
    download = true
    symbolcache_upstream = nothing
    action = :serve

    i = firstindex(args)
    function take_value(flag)
        i == lastindex(args) && error("$flag requires a value")
        i += 1
        return args[i]
    end

    while i <= lastindex(args)
        arg = args[i]
        if arg == "--env"
            env_path = take_value(arg)
        elseif arg == "--depot"
            depot_path = take_value(arg)
        elseif arg == "--symbol-store"
            symbol_store = take_value(arg)
        elseif arg == "--julia-exe"
            julia_exe = take_value(arg)
        elseif arg == "--julia-version"
            julia_version = take_value(arg)
        elseif arg == "--no-download"
            download = false
        elseif arg == "--symbolcache-upstream"
            symbolcache_upstream = take_value(arg)
        elseif arg == "-v" || arg == "--version"
            action = :version
        elseif arg == "-h" || arg == "--help"
            action = :help
        else
            error("unrecognized argument: $arg\n\n$USAGE")
        end
        i += 1
    end

    isempty(env_path) && (env_path = default_env())
    isempty(symbol_store) && (symbol_store = default_symbol_store())

    return (; action, env_path, depot_path, symbol_store, julia_exe, julia_version,
            download, symbolcache_upstream)
end

function @main(args)
    o = parse_argv(args)
    o.action === :version && (println(version_string()); return 0)
    o.action === :help && (print(USAGE); return 0)

    mkpath(o.symbol_store)

    # stdout carries JSON-RPC frames and nothing else; progress goes to stderr.
    @info "julials starting" version_string() env = o.env_path depot = o.depot_path store = o.symbol_store

    server = LanguageServerInstance(
        stdin,
        stdout,
        o.env_path,
        o.depot_path,
        nothing,                 # err_handler
        o.symbol_store,
        o.download,
        o.symbolcache_upstream,
        julia_exe_info(o.julia_exe, o.julia_version),
    )
    run(server)
    return 0
end

end # module
