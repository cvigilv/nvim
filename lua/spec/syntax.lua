return {
  { -- treesitter {{{
    "nvim-treesitter/nvim-treesitter",
    config = function()
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
      })
    end,
  },
  -- }}}
  { -- Typst {{{
    "kaarmu/typst.vim",
    ft = "typst",
    lazy = false,
  },
  --}}}
}
