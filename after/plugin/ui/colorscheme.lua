---@module "after.plugin.ui.colorscheme"
---@author Carlos Vigil-Vásquez
---@license MIT 2024-2025

local augroup = vim.api.nvim_create_augroup("carlos.colorscheme", { clear = true })

vim.api.nvim_create_autocmd("OptionSet", {
  desc = "Synchronize theme with tmux",
  pattern = "background",
  callback = function()
    vim.cmd("silent !tmux source ~/.config/tmux/tmux_" .. vim.o.background .. ".conf")
  end,
  group = augroup,
})
vim.api.nvim_create_autocmd("ColorScheme", {
  desc = "Override color scheme",
  pattern = { "zen*", "*bones" },
  callback = function(ev)
    local lush = require("lush")
    local base = require(ev.match)

    local function modify_colorscheme()
      -- Detect current background for out-of-bounds regions
      local is_dark = vim.api.nvim_get_option_value("background", { scope = "global" }) == "dark"
      local bg = is_dark and "#000000" or "#ffffff"

      local specs = lush.parse(
        function()
          return {
            OutOfBounds({ bg = base.NormalNC.bg }),
            Folded({}),
            MsgArea({ bg = bg }),
            ModeArea({ bg = bg }),
            TabLineFill({ bg = bg }),
            NormalFloat({ base.Normal }),
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
      vim.cmd("hi! @org.keyword.face.INTR.org ctermbg=0 ctermfg=255 guibg=#000000 guifg=#ffffff" .. (is_dark and " gui=reverse cterm=reverse" or ""))
    end
    modify_colorscheme()

    vim.api.nvim_create_autocmd("OptionSet", {
      pattern = "background",
      callback = modify_colorscheme,
      group = vim.api.nvim_create_augroup("carlos::colorscheme", { clear = true }),
    })
  end,
  group = augroup,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  desc = "Dim special buffers",
  pattern = {
    "/private/*.org",
    "*\\[CodeCompanion\\]*",
    "oil://*",
    "*orgagenda",
    "*COMMIT_EDITMSG",
    "*quickfix*",
    "term:*",
    "*doc/*.txt",
    "*_Luapad.lua",
  },
  callback = function(ev)
    local current_winhighlight = vim.api.nvim_get_option_value(
      "winhighlight",
      { scope = "local", win = vim.api.nvim_get_current_win() }
    )

    if current_winhighlight ~= "" then
      vim.api.nvim_set_option_value(
        "winhighlight",
        current_winhighlight .. ",Normal:OutOfBounds",
        { scope = "local", win = vim.api.nvim_get_current_win() }
      )
    else
      vim.api.nvim_set_option_value(
        "winhighlight",
        "Normal:OutOfBounds",
        { scope = "local", win = vim.api.nvim_get_current_win() }
      )
    end

    vim.api.nvim_create_autocmd("BufWinLeave", {
      pattern = ev.match,
      callback = function()
        vim.api.nvim_set_option_value(
          "winhighlight",
          current_winhighlight,
          { scope = "local", win = vim.api.nvim_get_current_win() }
        )
      end,
      once = true,
    })
  end,
  group = augroup,
})
vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Lazy-load color scheme",
  callback = function()
    -- Defaults
    local bg = "light"
    local colorscheme = "zenbones"

    -- Synchronize color scheme with system
    local theme = vim.fn.system("defaults read -g AppleInterfaceStyle"):gsub("\n", "")
    if theme == "Dark" then
      colorscheme = "neobones"
      bg = "dark"
    end

    -- Set color scheme
    vim.o.background = bg
    vim.cmd("colorscheme " .. colorscheme)

    -- Return true to delete
    return true
  end,
  once = true,
  nested = true,
  group = augroup,
})
