---@module "plugin.afuera.highlights"
---@author Carlos Vigil-Vásquez
---@license MIT 2024

local M = {}

---@param opts Afuera.Configuration
M.setup = function(opts)
  if opts.fix_colorscheme then vim.cmd("hi! link EndOfBuffer Normal") end
end

return M
