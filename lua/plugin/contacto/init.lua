---@module "plugin.contacto"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local M = {}

---@param opts Contacto.Configuration|nil User provided configuration table
M.setup = function(opts)
  -- Update options with user options
  opts = require("plugin.contacto.config").update_config(opts)

  -- Setup plugin behaviours
  require("plugin.contacto.highlights").setup(opts)
  require("plugin.contacto.conceal").setup(opts)
  require("plugin.contacto.excmd").setup(opts)
end

return M
