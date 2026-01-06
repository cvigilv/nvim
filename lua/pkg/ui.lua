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
          border = { " ", " ", " ", " ", " ", " ", " ", " " },
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
  { -- bareline.nvim
    "hernancerm/bareline.nvim",
    event = "VimEnter",
    opts = {},
  },
  { -- zenbones
    "zenbones-theme/zenbones.nvim",
    dependencies = "rktjmp/lush.nvim",
    lazy = false,
    priority = 1000,
    init = function()
      -- TODO Move to custom zenbones
      -- Setup
      vim.g.zenbones_lightness = "bright"
      vim.g.zenbones_darkness = "stark"
      vim.g.zenbones_lighten_noncurrent_window = true
      vim.g.zenbones_darken_noncurrent_window = true
      vim.g.zenbones_colorize_diagnostic_underline_text = true

      vim.g.neobones_lightness = "bright"
      vim.g.neobones_darkness = "stark"
      vim.g.neobones_lighten_noncurrent_window = true
      vim.g.neobones_darken_noncurrent_window = true
      vim.g.neobones_colorize_diagnostic_underline_text = true

      vim.g.zenwritten_lightness = "bright"
      vim.g.zenwritten_darkness = "stark"
      vim.g.zenwritten_lighten_noncurrent_window = true
      vim.g.zenwritten_darken_noncurrent_window = true
      vim.g.zenwritten_colorize_diagnostic_underline_text = true

      -- Customizations
      local augroup = vim.api.nvim_create_augroup("zenbones", { clear = true })
      vim.api.nvim_create_autocmd("ColorScheme", {
        desc = "Override color scheme",
        pattern = { "zen*", "*bones" },
        callback = function(ev)
          local lush = require("lush")
          local base = require(ev.match)

          local function modify_colorscheme()
            -- Detect current background for out-of-bounds regions
            local is_dark = vim.api.nvim_get_option_value("background", { scope = "global" })
              == "dark"
            local bg = is_dark and "#000000" or "#ffffff"

            local specs = lush.parse(
              function()
                return {
                  OutOfBounds({ bg = base.NormalNC.bg }),
                  Folded({}),
                  MsgArea({ bg = bg }),
                  ModeArea({ bg = bg }),
                  TabLineFill({ bg = bg }),
                  NormalFloat({ bg = base.NormalNC.bg }),
                  FloatBorder({ fg = base.Normal.bg, bg = base.NormalNC.bg }),
                  NormalNC({ base.Normal }),
                  StatusLine({ base.StatusLine, bold = true }),
                  StatusLineNC({ base.StatusLineNC, italic = true }),
                }
              end
            )
            -- Apply specs using lush tool-chain
            lush.apply(lush.compile(specs))

            vim.cmd("hi! link @org.keyword.face.TODO DiagnosticVirtualTextError")
            vim.cmd("hi! link @org.keyword.face.NEXT DiagnosticVirtualTextHint")
            vim.cmd("hi! link @org.keyword.face.PROG DiagnosticVirtualTextWarn")
            vim.cmd("hi! link @org.keyword.face.DONE DiagnosticVirtualTextOk")
            vim.cmd("hi! link @org.keyword.face.CNCL DiagnosticVirtualTextOk")
            vim.cmd(
              "hi! @org.keyword.face.INTR.org ctermbg=0 ctermfg=255 guibg=#000000 guifg=#ffffff"
                .. (is_dark and " gui=reverse cterm=reverse" or "")
            )
          end
          modify_colorscheme()

          vim.api.nvim_create_autocmd("OptionSet", {
            pattern = "background",
            callback = modify_colorscheme,
            group = augroup,
          })
        end,
        group = augroup,
      })
    end,
  },
}
