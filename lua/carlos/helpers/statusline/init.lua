---@module 'carlos.helpers.statusline'
---@author Carlos Vigil-Vásquez
---@license MIT

local components = require("carlos.helpers.statusline.components")
local helpers = require("carlos.helpers.statusline.helpers")
local modifiers = require("carlos.helpers.statusline.modifiers")
local ui = require("carlos.helpers.statusline.ui")

M = {
  components = components,
  helpers = helpers,
  modifiers = modifiers,
  ui = ui,
}

return M
