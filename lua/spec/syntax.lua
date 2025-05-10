---@module "spec.syntax"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

return {
  { -- Tree-sitter
    "nvim-treesitter/nvim-treesitter",
    event="VeryLazy",
    opts = {
      ensure_installed = {
        "julia",
        "python",
        "bash",
        "lua",
        "markdown",
        "markdown_inline",
        "vimdoc",
      },
      auto_install = true,
      sync_install = true,
      ignore_install = {},
      modules = {},
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { "markdown" },
      },
      incremental_selection = { enable = false },
      indent = { enable = false },
      textobjects = { enable = false },
    },
  },
  { -- Typst
    "kaarmu/typst.vim",
    ft = "typst",
  },
}
