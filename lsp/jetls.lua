---@brief
---
--- https://github.com/aviatesk/JETLS.jl
---
--- JETLS is a next-generation language server for Julia, powered by JET.jl and
--- JuliaSyntax.jl. It aims to replace LanguageServer.jl (`julials`).
---
--- Prefers a native `jetls-<major>.<minor>` executable matching the Julia on
--- `$PATH`, built by `scripts/jetls-build.jl`:
--- ```sh
--- ./scripts/jetls-build.jl build --julia release
--- ```
--- `update` fetches the newest JETLS and rebuilds, `clean` removes the binaries.
---
--- Without a matching binary this falls back to the `jetls` app, which loads
--- JETLS.jl from source on every start. Install it with:
--- ```sh
--- julia -e 'using Pkg; Pkg.Apps.add(; url="https://github.com/aviatesk/JETLS.jl", rev="release")'
--- ```
--- That puts `jetls` in `~/.julia/bin/`, which must be on your `$PATH`. Update it
--- with `julia -e 'using Pkg; Pkg.Apps.update("JETLS")'`.
---
--- Either way the Julia used is whichever `julia` resolves on `$PATH`, so the
--- juliaup default channel decides which server starts. Changing it takes effect
--- on the next `:Lsp restart jetls`.
---
--- Requires Neovim v0.11 or later.
---
--- Configuration is delivered under the `jetls` settings key (see the
--- configuration reference: https://aviatesk.github.io/JETLS.jl/release/configuration/).
--- Project-local settings can also live in a `.JETLSConfig.toml` at the project root.

--- Version of the `julia` on `$PATH`, as `major.minor`, which names the binary.
---@return string|nil
local function julia_minor()
  local julia = vim.fn.exepath("julia")
  if julia == "" then return nil end
  local out = vim.system({ julia, "--version" }, { text = true }):wait()
  if out.code ~= 0 then return nil end
  local major, minor = (out.stdout or ""):match("(%d+)%.(%d+)%.%d+")
  if not major then return nil end
  return major .. "." .. minor
end

---@type vim.lsp.Config
return {
  --- Resolved per client start rather than when this file is read, so switching the
  --- juliaup default channel only needs `:Lsp restart jetls`.
  cmd = function(dispatchers, config)
    local cwd = config.root_dir or assert(vim.uv.cwd())
    local minor = julia_minor()
    local exe = minor and vim.fn.exepath("jetls-" .. minor) or ""

    if exe == "" then
      return vim.lsp.rpc.start({ "jetls", "serve" }, dispatchers, { cwd = cwd })
    end

    -- The `jetls` app passes `--threads=auto` as a Julia flag. A compiled
    -- executable takes no Julia flags: everything on its command line belongs to
    -- JETLS, so the thread count has to arrive through the environment.
    return vim.lsp.rpc.start({ exe, "serve" }, dispatchers, {
      cwd = cwd,
      env = { JULIA_NUM_THREADS = "auto" },
    })
  end,
  filetypes = { "julia" },
  root_markers = { "Project.toml", "JuliaProject.toml", ".git" },
  on_attach = function(_, bufnr)
    -- Workaround for a Neovim bug present in older v0.12 nightlies: JETLS
    -- registers `textDocument/diagnostic` *dynamically* (via the server's
    -- `client/registerCapability` request, after attach). Neovim then loops
    -- over already-attached buffers and calls `vim.lsp.diagnostic._refresh()`
    -- on buffers that were never enabled for pull diagnostics, indexing a nil
    -- `bufstate` at runtime/lua/vim/lsp/diagnostic.lua:380 and raising
    -- "SERVER_REQUEST_HANDLER_ERROR ... attempt to index local 'bufstate'".
    --
    -- Pre-enabling pull diagnostics here creates the `bufstate` before the
    -- dynamic registration fires, so the refresh no longer crashes. This is
    -- fixed upstream by the LSP diagnostics refactor (the guarded
    -- `Diagnostics:refresh`); the guard below no-ops on newer nightlies where
    -- `_enable` no longer exists, so it is safe to leave in place.
    local diag = vim.lsp.diagnostic
    if type(diag) == "table" and type(diag._enable) == "function" then
      pcall(diag._enable, bufnr)
    end
  end,
  settings = {
    jetls = {
      formatter = "Runic",
      full_analysis = {
        auto_instantiate = true,
      },
      code_lens = {
        testrunner = true,
      },
    },
  },
}
