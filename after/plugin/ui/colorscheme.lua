---@module "after.plugin.ui.colorscheme"
---@author Carlos Vigil-Vásquez
---@license MIT 2024-2025

local augroup = vim.api.nvim_create_augroup("carlos.colorscheme", { clear = true })

vim.api.nvim_create_autocmd("OptionSet", {
  desc="Synchronize theme with tmux",
  pattern = "background",
  callback = function()
    vim.cmd("silent !tmux source ~/.config/tmux/tmux_" .. vim.o.background .. ".conf")
  end,
  group = augroup,
})
vim.api.nvim_create_autocmd("Colorscheme", {
  desc="Override color scheme",
  pattern = { "zen*", "*bones" },
  callback = function(ev)
    local lush = require("lush")
    local base = require(ev.match)

    local function modify_colorscheme()
      -- Detect current background for out-of-bounds regions
      local bg = vim.api.nvim_get_option_value("background", { scope = "global" }) == "dark"
          and "#000000"
        or "#ffffff"
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
    vim.api.nvim_set_option_value(
      "winhighlight",
      "Normal:OutOfBounds",
      { scope = "local", win = vim.api.nvim_get_current_win() }
    )

    vim.api.nvim_create_autocmd("BufWinLeave", {
      pattern = ev.match,
      callback = function()
        vim.api.nvim_set_option_value(
          "winhighlight",
          "",
          { scope = "local", win = vim.api.nvim_get_current_win() }
        )
      end,
      once = true,
    })
  end,
  group = augroup,
})
vim.api.nvim_create_autocmd("VimEnter", {
  desc="Lazy-load color scheme",
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
