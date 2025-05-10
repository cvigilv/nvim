---@module "spec.ui"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

return {
  { -- quicker.nvim
    "stevearc/quicker.nvim",
    filetype = "qf",
    opts = {
      buflisted = false,
      colorcolumn = "",
      number = true,
      relativenumber = false,
      signcolumn = "auto",
      winfixheight = true,
      wrap = false,
      winfixbuf = true,
    },
  },
  { -- which-key
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        preset = "helix",
        delay = 150,
        filter = function(mapping) return mapping.desc and mapping.desc ~= "" end,
        spec = {},
        notify = true,
        plugins = {
          marks = false,
          registers = true,
          spelling = { suggestions = 16 },
          presets = {
            operators = true,
            motions = true,
            text_objects = true,
            windows = true,
            nav = true,
            z = true,
            g = true,
          },
        },
        win = {
          border = "single",
          title_pos = "center",
          wo = { winblend = 10, anchor = "NE" },
        },
        layout = {
          width = { max = 16 },
        },
        icons = {
          breadcrumb = "->",
          separator = "   ",
          mappings = false,
        },
        disable = {
          ft = { "TelescopePrompt", "Lazy" },
          bt = {},
        },
      })
      -- Keymap groupings
      wk.add({
        { "<leader>", icon = "", group = "+leader" },
        { "<leader>f", icon = "", group = "+finder" },
        { "<leader>g", icon = "", group = "+git" },
        { "<leader>z", icon = "", group = "+zettelkasten" },
        { "<leader>l", icon = "", group = "+lsp" },
        { "<leader>d", icon = "", group = "+diagnostics" },
        { "<leader>s", icon = "", group = "+snippets" },
      })
    end,
  },
  { -- zenbones
    "zenbones-theme/zenbones.nvim",
    dependencies = "rktjmp/lush.nvim",
    lazy = false,
    priority = 1000,
    init = function()
      vim.g.zenbones_lightness = "bright"
      vim.g.zenbones_colorize_diagnostic_underline_text = true
      vim.g.neobones_lightness = "bright"
      vim.g.neobones_colorize_diagnostic_underline_text = true
      vim.g.zenwritten_lightness = "bright"
      vim.g.zenwritten_colorize_diagnostic_underline_text = true
      vim.g.zenwritten_lightness = "bright"
      vim.g.zenwritten_colorize_diagnostic_underline_text = true
    end,
  },
  { -- bareline.nvim
    "hernancerm/bareline.nvim",
    event = "VimEnter",
    opts = {},
  },
}
