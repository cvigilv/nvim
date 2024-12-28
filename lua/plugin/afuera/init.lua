---@module "plugin.afuera"
---@author Carlos Vigil-Vásquez
---@license MIT 2024

local M = {}

---Sets up the plugin with the given options.
---@param opts Afuera.Configuration Configuration options for the plugin
M.setup = function(opts)
  opts = require("plugin.afuera.config").updateconfig(opts)

  -- Setup plugin functionality
  opts.state = {}
  require("plugin.afuera.autocmds").setup(opts)
  require("plugin.afuera.excmds").setup(opts)
end

return M
