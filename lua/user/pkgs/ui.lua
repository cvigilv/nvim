return {
  -- centerpad {{{
  {
    "smithbm2316/centerpad.nvim",
    setup = true,
  },
  -- }}}
  -- which-key {{{
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        preset = "classic",
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
          border = "none",
          padding = { 1, 10 },
          title_pos = "center",
          wo = { winblend = 10 },
        },
        layout = {
          width = { min = 20 },
          spacing = 5,
        },
        icons = {
          breadcrumb = "➜",
          separator = "-",
        },
        disable = {
          ft = { "TelescopePrompt", "Lazy" },
          bt = {},
        },
      })

      -- Keymap groupings
      wk.add({
        { "<leader>f", icon = "󰈞", group = "+finder" },
        { "<leader>g", icon = "󰊢", group = "+git" },
        { "<leader>z", icon = "", group = "+zettelkasten" },
        { "<leader>l", icon = "󰌘", group = "+lsp" },
        { "<leader>d", icon = "", group = "+diagnostics" },
        { "<space>f", icon = "󰛢 ", group = "+harpoon" },
        { "<leader>s", icon = "󱃖 ", group = "+snippets" },
      })
    end,
  }, --}}}
  -- Context {{{
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "VeryLazy",
    config = function()
      require("treesitter-context").setup({
        line_numbers = true,
        mode = "topline",
      })
    end,
  }, -- }}}
}
