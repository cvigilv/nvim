---@module 'lib.statusline'
---@author Carlos Vigil-Vásquez
---@license MIT

local components = require("lib.statusline.components")
local helpers = require("lib.statusline.helpers")
local modifiers = require("lib.statusline.modifiers")
local ui = require("lib.statusline.ui")

M = {
  components = components,
  helpers = helpers,
  modifiers = modifiers,
  ui = ui,
}

return M
