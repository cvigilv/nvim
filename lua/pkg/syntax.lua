---@module "pkg.syntax"
---@author Carlos Vigil-Vásquez
---@license MIT 2026

-- Parser needed by writing previews. nvim-treesitter's compatibility branch
-- still passes a removed flag to tree-sitter-cli 0.26, so provide current args.
local parser_configs = require("nvim-treesitter.parsers").get_parser_configs()
parser_configs.latex.install_info.revision = "v0.6.0"
require("nvim-treesitter.install").ts_generate_args = {
  "generate",
  "--abi",
  tostring(vim.treesitter.language_version),
}
require("nvim-treesitter.configs").setup({ ensure_installed = { "latex" } })

-- Treesitter text objects
require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
    include_surrounding_whitespace = false,
  },
  move = {
    set_jumps = true,
  },
})

-- Typst
-- vim.g.typst_syntax_highlight = 0
-- vim.g.typst_pdf_viewer = "sioyek"
-- vim.g.typst_auto_close_toc = 1

require("typst-preview").setup()
