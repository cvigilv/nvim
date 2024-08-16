return {
  -- which-key {{{
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        preset = "classic",
        delay = 50,
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
        { "<space>f", icon = "󰛢", group = "+harpoon" },
        { "<leader>s", icon = "󱃖 ", group = "+snippets" },
      })
    end,
  }, --}}}
  -- incline {{{
  {
    "b0o/incline.nvim",
    event = "VeryLazy",
    dependencies = "rktjmp/lush.nvim",
    config = function()
      -- Setup `incline`
      local incline = require("incline")
      incline.setup({
        window = {
          padding = 0,
          placement = { horizontal = "right", vertical = "top" },
        },
        render = function(props)
          local c = require("user.helpers.statusline.components")
          local colors = require("patana.palette")
          local palette = {
            focus = {
              fg = colors.norm,
              bg = colors.oob,
            },
            unfocus = {
              fg = colors.comment,
              bg = colors.oob,
            },
          }

          -- Component
          local bufname = vim.api.nvim_buf_get_name(props.buf)
          local filename = bufname ~= "" and vim.fn.fnamemodify(bufname, ":t") or bufname
          local extension = vim.fn.fnamemodify(bufname, ":e")
          local icon, _ = require("nvim-web-devicons").get_icon(filename, extension)
          icon = icon or ""

          -- FIXME: Harpoon indicator showing in every window of tab, not just the "hooked" one
          local harpooned = ""
          local ok, harpoon = pcall(require, "harpoon")
          if ok then
            local list = harpoon:list()

            for _, item in ipairs(list.items) do
              if item.value == vim.fn.expand("%:p:.") then
                harpooned = "󰛢 "
                break
              end
            end
          end

          -- Incline theme
          local state = nil
          local guifg = palette.unfocus ~= nil and palette.unfocus.fg
          local guibg = palette.unfocus ~= nil and palette.unfocus.bg

          if props.focused then
            state = "bold"
            guifg = palette.focus ~= nil and palette.focus.fg
            guibg = palette.focus ~= nil and palette.focus.bg
          end

          -- File status
          local status = require("incline.helpers").eval_statusline(
            c.filestatus() or nil,
            { winid = props.win, highlights = false }
          )

          return {
            { " ", guifg = guifg, guibg = guibg, gui = state },
            { icon .. " " or "", guifg = guifg, guibg = guibg, gui = state },
            { filename, guifg = guifg, guibg = guibg, gui = state },
            { " ", guifg = guifg, guibg = guibg, gui = state },
            { status, guifg = guifg, guibg = guibg, gui = state },
            { harpooned, guifg = guifg, guibg = guibg, gui = state },
            { " ", guifg = guifg, guibg = guibg, gui = state },
          }
        end,
        hide = { cursorline = false, only_win = true },
        ignore = {
          unlisted_buffers = false,
          floating_wins = true,
          filetypes = { "oil" },
          buftypes = {},
          wintypes = {},
        },
      })
    end,
  },
  --}}}
}
