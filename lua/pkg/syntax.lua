---@module "pkg.syntax"
---@author Carlos Vigil-Vásquez
---@license MIT 2026

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
