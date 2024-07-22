---@module 'user.helpers.statusline'
---@author Carlos Vigil-Vásquez
---@license MIT

local components = require("user.helpers.statusline.components")
local helpers = require("user.helpers.statusline.helpers")
local modifiers = require("user.helpers.statusline.modifiers")
local ui = require("user.helpers.statusline.ui")

M = {
  components = components,
  helpers = helpers,
  modifiers = modifiers,
  ui = ui,
}

return M
