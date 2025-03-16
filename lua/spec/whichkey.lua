---@module "spec.whichkey"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

return {
  {
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
        sort = { "desc", "local", "order", "group", "alphanum", "mod" },
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
        { "<space>f", icon = "", group = "+harpoon" },
        { "<leader>s", icon = "", group = "+snippets" },
      })
    end,
  },
}
