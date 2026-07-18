---@module "plugin.correo"
---@author Carlos Vigil-Vásquez
---@license MIT 2026

local M = {}

M.setup = function(opts)
  opts = require("plugin.correo.config").updateconfig(opts)
  vim.g.correo = { opts = opts }
  vim.print(vim.g.correo)
end

return M
