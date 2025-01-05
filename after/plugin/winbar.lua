---@module 'plugin.statusline'
---@author Carlos Vigil-Vásquez
---@license MIT

-- PHILOSOPHY: The `winbar` is meant to display information pertinent to the current buffer and
-- its location. Details such as file path, cursor position, LSP breadcrumbs, etc. are meant
-- to populate this UI element. This is an information-rich element, therefore its only shown
-- when its necessary, i.e. when the window is focused.

-- Setup winbar
local c = require("carlos.helpers.winbar.components")
local h = require("carlos.helpers.winbar.helpers")
local stl = require("carlos.helpers.statusline")

h.setup_winbar_hlgroups()

_G.carlos.winbar = function()
  local components = {
    -- Right align contents
    "%#Normal#%=",

    -- Buffer number and window
    "%#Comment#",
    " (B" .. vim.api.nvim_get_current_buf(),
    ", W" .. vim.api.nvim_get_current_win() .. ") ",

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

vim.o.winbar = "%{%v:lua.carlos.winbar()%}"
