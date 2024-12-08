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
  -- ZenMode
  {
    "folke/zen-mode.nvim",
    opts = {
      window = {
        backdrop = 0.50, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
        -- height and width can be:
        -- * an absolute number of cells when > 1
        -- * a percentage of the width / height of the editor when <= 1
        -- * a function that returns the width or the height
        width = 120, -- width of the Zen window
        height = 1, -- height of the Zen window
        -- by default, no options are changed for the Zen window
        -- uncomment any of the options below, or add other vim.wo options you want to apply
        options = {
          signcolumn = "no", -- disable signcolumn
          number = false, -- disable number column
          relativenumber = false, -- disable relative numbers
          -- cursorline = false, -- disable cursorline
          -- cursorcolumn = false, -- disable cursor column
          foldcolumn = "0", -- disable fold column
          -- list = false, -- disable whitespace characters
        },
      },
      plugins = {
        -- disable some global vim options (vim.o...)
        -- comment the lines to not apply the options
        options = {
          enabled = true,
          ruler = false, -- disables the ruler text in the cmd line area
          showcmd = false, -- disables the command in the last line of the screen
          -- you may turn on/off statusline in zen mode by setting 'laststatus'
          -- statusline will be shown only if 'laststatus' == 3
          laststatus = 0, -- turn off the statusline in zen mode
        },
        twilight = { enabled = true }, -- enable to start Twilight when zen mode opens
        gitsigns = { enabled = false }, -- disables git signs
        tmux = { enabled = true }, -- disables the tmux statusline
        todo = { enabled = false }, -- if set to "true", todo-comments.nvim highlights will be disabled
      },
    },
  },
  {
    "stevearc/quicker.nvim",
    event = "FileType qf",
    opts = {
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
      keys = {
        {
          ">",
          function()
            require("quicker").expand({ before = 3, after = 3, add_to_existing = true })
          end,
          desc = "Expand quickfix context",
        },
        {
          "<",
          function() require("quicker").collapse() end,
          desc = "Collapse quickfix context",
        },
      },
    },
  },
}
