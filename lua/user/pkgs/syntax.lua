return {
  { --
    "lukas-reineke/headlines.nvim",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = function()
      require("headlines").setup({
        markdown = {
          dash_string = "━",
          quote_string = "┃",
          fat_headlines = false,
        },
      })
    end,
  },
  { -- treesitter {{{
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "julia",
          "python",
          "org",
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
  { -- Biology-related{{{
    "bioSyntax/bioSyntax-vim",
  }, -- }}}
}
