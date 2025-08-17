---@module "plugin.pkm.contacto"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local M = {}

---@param opts Contacto.Configuration|nil User provided configuration table
M.setup = function(opts)
  -- Update options with user options
  opts = require("plugin.pkm.contacto.config").update_config(opts)

  -- Setup plugin behaviours
  require("plugin.pkm.contacto.highlights").setup(opts)
  require("plugin.pkm.contacto.conceal").setup(opts)
  print("foo")
  require("plugin.pkm.contacto.excmd").setup(opts)
  print("bar")
end


return M
