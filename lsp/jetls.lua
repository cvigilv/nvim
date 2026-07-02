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
