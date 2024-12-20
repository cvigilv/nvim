---@module "plugin.afuera"
---@author Carlos Vigil-Vásquez
---@license MIT 2024

local M = {}

M.setup = function(opts)
  opts = require("plugin.afuera.config").updateconfig(opts)

  -- Setup plugin functionality
  require("plugin.afuera.autocmds").setup(opts)
  require("plugin.afuera.excmds").setup(opts)
end

return M
