---@module "spec.syntax"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/folke/lazydev.nvim",
})

require("nvim-treesitter.configs").setup({
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
  }
)

require("lazydev").setup()
