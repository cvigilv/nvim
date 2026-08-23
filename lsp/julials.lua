---@brief
---
--- https://github.com/julia-vscode/LanguageServer.jl
---
--- Prefers a native `julials-<major>.<minor>` executable matching the Julia on
--- `$PATH`, built by `scripts/julials-build.jl`:
--- ```sh
--- ./scripts/julials-build.jl build --julia release
--- ```
--- A compiled server answers `initialize` in under two seconds, against a little
--- over thirty for the source launch. `update` rebuilds against the current
--- LanguageServer.jl, `clean` removes the binaries.
---
--- Without a matching binary this falls back to running LanguageServer.jl from
--- source out of `~/.julia/environments/nvim-lspconfig`, which is the only option
--- on Julia 1.10 and 1.11 — JuliaC cannot compile on either. Install it with:
--- ```sh
--- julia --project=~/.julia/environments/nvim-lspconfig -e 'using Pkg; Pkg.add("LanguageServer")'
--- ```
---
--- Either way the Julia used is whichever `julia` resolves on `$PATH`, so the
--- juliaup default channel decides which server starts. Changing it takes effect
--- on the next `:Lsp restart julials`.
---
--- Note: for LanguageServer.jl to see a project's dependencies the project must be
--- instantiated:
--- ```sh
--- julia --project=/path/to/my/project -e 'using Pkg; Pkg.instantiate()'
--- ```

local root_files = { "Project.toml", "JuliaProject.toml" }

local function activate_env(path)
  assert(vim.fn.has("nvim-0.10") == 1, "requires Nvim 0.10 or newer")
  local bufnr = vim.api.nvim_get_current_buf()
  local julials_clients = vim.lsp.get_clients({ bufnr = bufnr, name = "julials" })
  assert(
    #julials_clients > 0,
    "method julia/activateenvironment is not supported by any servers active on the current buffer"
  )
  local function _activate_env(environment)
    if environment then
      for _, julials_client in ipairs(julials_clients) do
        julials_client:notify("julia/activateenvironment", { envPath = environment })
      end
      vim.notify("Julia environment activated: \n`" .. environment .. "`", vim.log.levels.INFO)
    end
  end
  if path then
    path = vim.fs.normalize(vim.fn.fnamemodify(vim.fn.expand(path), ":p"))
    local found_env = false
    for _, project_file in ipairs(root_files) do
      local file = vim.uv.fs_stat(vim.fs.joinpath(path, project_file))
      if file and file.type then
        found_env = true
        break
      end
    end
    if not found_env then
      vim.notify("Path is not a julia environment: \n`" .. path .. "`", vim.log.levels.WARN)
      return
    end
    _activate_env(path)
  else
    local depot_paths = vim.env.JULIA_DEPOT_PATH
        and vim.split(vim.env.JULIA_DEPOT_PATH, vim.fn.has("win32") == 1 and ";" or ":")
      or { vim.fn.expand("~/.julia") }
    local environments = {}
    vim.list_extend(
      environments,
      vim.fs.find(root_files, { type = "file", upward = true, limit = math.huge })
    )
    for _, depot_path in ipairs(depot_paths) do
      local depot_env = vim.fs.joinpath(vim.fs.normalize(depot_path), "environments")
      vim.list_extend(
        environments,
        vim.fs.find(
          function(name, env_path)
            return vim.tbl_contains(root_files, name)
              and string.sub(env_path, #depot_env + 1):match("^/[^/]*$")
          end,
          { path = depot_env, type = "file", limit = math.huge }
        )
      )
    end
    environments = vim.tbl_map(vim.fs.dirname, environments)
    vim.ui.select(environments, { prompt = "Select a Julia environment" }, _activate_env)
  end
end

--- Version of the `julia` on `$PATH`, as `major.minor` (which names the binary)
--- and the full version (which keys SymbolServer's caches).
---@return string|nil minor, string|nil full
local function julia_version()
  local julia = vim.fn.exepath("julia")
  if julia == "" then return nil, nil end
  local out = vim.system({ julia, "--version" }, { text = true }):wait()
  if out.code ~= 0 then return nil, nil end
  local major, minor, patch = (out.stdout or ""):match("(%d+)%.(%d+)%.(%d+)")
  if not major then return nil, nil end
  return major .. "." .. minor, major .. "." .. minor .. "." .. patch
end

--- Where LanguageServer.jl keeps its symbol caches. Passing this explicitly matters
--- for the compiled binary: SymbolServer's default is a path inside the package
--- directory it was compiled from.
local function symbol_store()
  return vim.fs.joinpath(vim.fn.stdpath("cache") --[[@as string]], "julials", "symbolstore")
end

--- Launch LanguageServer.jl from source. Used when no compiled binary matches the
--- current Julia.
---@param env_path string
---@return string[]
local function source_cmd(env_path)
  return {
    "julia",
    "--startup-file=no",
    "--history-file=no",
    "--project=" .. vim.fn.expand("~/.julia/environments/nvim-lspconfig"),
    "-e",
    [[
      using LanguageServer
      depot_path = get(ENV, "JULIA_DEPOT_PATH", "")
      project_path = ARGS[1]
      @info "Running language server from source" VERSION project_path depot_path
      server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path)
      server.runlinter = true
      run(server)
    ]],
    env_path,
  }
end

---@type vim.lsp.Config
return {
  --- Resolved per client start rather than when this file is read, so switching the
  --- juliaup default channel only needs `:Lsp restart julials`.
  cmd = function(dispatchers, config)
    local env_path = config.root_dir or assert(vim.uv.cwd())
    local minor, full = julia_version()
    local exe = minor and vim.fn.exepath("julials-" .. minor) or ""

    if exe == "" then
      return vim.lsp.rpc.start(source_cmd(env_path), dispatchers, { cwd = env_path })
    end

    return vim.lsp.rpc.start({
      exe,
      "--env",
      env_path,
      "--depot",
      vim.env.JULIA_DEPOT_PATH or "",
      "--symbol-store",
      symbol_store(),
      "--julia-exe",
      vim.fn.exepath("julia"),
      "--julia-version",
      full,
    }, dispatchers, { cwd = env_path })
  end,
  filetypes = { "julia" },
  root_markers = root_files,
  on_attach = function(_, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, "LspJuliaSetEnv", activate_env, {
      desc = "Activate a Julia environment",
      nargs = "?",
      complete = "file",
    })
  end,
  settings = {
    symbolCacheDownload = true,
    lint = {
      missingrefs = "all",
      iter = true,
      lazy = true,
      modname = true,
    },
  },
}
