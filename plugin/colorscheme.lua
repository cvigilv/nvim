---@module "after.plugin.colorscheme"
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
    local current_winhighlight = vim.wo.winhighlight

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
    local colorscheme = "claro"

    -- Synchronize color scheme with system
    local theme = vim.fn.system("defaults read -g AppleInterfaceStyle"):gsub("\n", "")
    if theme == "Dark" then
      colorscheme = "oscuro"
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
