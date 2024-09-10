---@module 'plugin.statusline'
---@author Carlos Vigil-Vásquez
---@license MIT

-- PHILOSOPHY: The `winbar` is meant to display information pertinent to the current buffer and
-- its location. Details such as file path, cursor position, LSP breadcrumbs, etc. are meant
-- to populate this UI element. This is an information-rich element, therefore its only shown
-- when its necessary, i.e. when the window is focused.

-- Setup winbar
local c = require("user.helpers.winbar.components")
local h = require("user.helpers.winbar.helpers")
local stl = require("user.helpers.statusline")

h.setup_winbar_hlgroups()

_G.focused_winbar = function()
  local components = {
    -- Right align contents
    "%=",

    -- Location block
    " ",
    stl.helpers.center("L%l:C%c", 9),

    -- Current buffer block
    "%#WinBarCaps#%#WinBarOOB# ",
    stl.components.fileicon(),
    vim.fn.expand("%:.:h") .. "/%#WinBarOOBBold#",
    vim.fn.expand("%:t"),
    "%#WinBarOOB#",
    stl.components.filestatus(),
    c.is_harpooned(),
    "%#WinBarCaps# %#WinBar# ",
  }
  return table.concat(vim.tbl_filter(function(value) return value ~= nil end, components), "")
end

_G.unfocused_winbar = function()
  local components = {
    -- Right align contents
    "%=",

    -- Current buffer block
    "%#WinBarCaps#%#WinBarOOBNC# ",
    stl.components.fileicon(),
    vim.fn.expand("%:.:h") .. "/%#WinBarOOB#",
    vim.fn.expand("%:t"),
    "%#WinBarOOBNC#",
    stl.components.filestatus(),
    "%#WinBarCaps# %#WinBar# ",
  }
  return table.concat(vim.tbl_filter(function(value) return value ~= nil end, components), "")
end

-- Setup `winbar` based on focus state of window and don't show winbar in some specific buftypes
-- TODO: Convert this into a global variable to reuse in more places
local ignored_filetypes = {}
local ignored_buftypes = {
  "acwrite",
  "nofile",
  "nowrite",
  "quickfix",
  "terminal",
  "prompt",
}

local event_winbar = {
  VimEnter = _G.focused_winbar(),
  WinEnter = _G.focused_winbar(),
  WinLeave = _G.unfocused_winbar(),
}

for event, winbar in pairs(event_winbar) do
  vim.api.nvim_create_autocmd(event, {
    group = vim.api.nvim_create_augroup("user::ui::winba", { clear = false }),
    desc = "Setup local `winbar` for current window based on event `" .. event .. "`",
    callback = function()
      local current_buftype = vim.api.nvim_get_option_value("buftype", { scope = "local" })
      local current_filetype = vim.api.nvim_get_option_value("filetype", { scope = "local" })

      if
        not (
          vim.tbl_contains(ignored_buftypes, current_buftype)
          or vim.tbl_contains(ignored_filetypes, current_filetype)
        )
      then
        vim.api.nvim_set_option_value("winbar", winbar, { scope = "local" })
      end
    end,
  })
end
