---@brief
---
--- https://github.com/aviatesk/JETLS.jl
---
--- JETLS is a next-generation language server for Julia, powered by JET.jl and
--- JuliaSyntax.jl. It aims to replace LanguageServer.jl (`julials`).
---
--- Install the `jetls` executable with Julia's app manager:
--- ```sh
--- julia -e 'using Pkg; Pkg.Apps.add(; url="https://github.com/aviatesk/JETLS.jl", rev="release")'
--- ```
--- This installs `jetls` into `~/.julia/bin/`, which must be on your `$PATH`.
--- Verify with `jetls --help`.
---
--- To update an existing install:
--- ```sh
--- julia -e 'using Pkg; Pkg.Apps.update("JETLS")'
--- ```
---
--- Requires Neovim v0.11 or later.
---
--- Configuration is delivered under the `jetls` settings key (see the
--- configuration reference: https://aviatesk.github.io/JETLS.jl/release/configuration/).
--- Project-local settings can also live in a `.JETLSConfig.toml` at the project root.

---@type vim.lsp.Config
return {
  cmd = { "jetls", "serve" },
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
