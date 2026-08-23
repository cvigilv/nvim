---@brief
---
--- https://fatou.dev
---
--- Fatou is a language server, formatter, and linter for Julia, written in Rust.
--- It analyzes source text only — there is no Julia runtime behind it, so it starts
--- instantly and answers from the syntax tree rather than from type inference or a
--- package index. Alongside `jetls` and `julials` it covers the fast, always-available
--- half: syntax-level diagnostics, symbols, rename, and folding on any file, including
--- ones outside a project.
---
--- Install with one of:
--- ```sh
--- cargo install fatou
--- npm install -g fatou
--- pipx install fatou
--- ```
--- Prebuilt binaries are also published. Verify with `fatou --version`.
---
--- Configuration comes from a `fatou.toml`, not from LSP settings: the server looks
--- for one in the project, then at `$FATOU_CONFIG`, then at the global location.
--- `[format]` takes `line-width`, `indent-width`, and `line-ending`; `[lint]` takes
--- `select`, `ignore`, `severity`, and per-rule tables under `[lint.rules.<id>]`.
--- Unknown keys are rejected rather than ignored. Rule reference:
--- https://fatou.dev/reference/rules.html
---
--- Julia buffers are formatted by Runic through conform (see `lua/pkg/tooling.lua`),
--- so `<leader>lf` does not reach the `textDocument/formatting` this server offers.
--- Reaching it takes an explicit `vim.lsp.buf.format({ name = "fatou" })`.

---@type vim.lsp.Config
return {
  cmd = { "fatou", "lsp" },
  filetypes = { "julia" },
  -- `fatou.toml` comes first so the server root matches the directory its own
  -- configuration discovery settles on.
  root_markers = { "fatou.toml", "Project.toml", "JuliaProject.toml", ".git" },
}
