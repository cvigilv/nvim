---@module "plugin.correo"
---@author Carlos Vigil-Vásquez
---@license MIT 2026

local M = {}

--- Setup correo.nvim
---@param opts Correo.Configuration|nil User provided configuration table
M.setup = function(opts)
  -- Update options with user options
  opts = require("plugin.correo.config").updateconfig(opts)
  vim.g.correo = { opts = opts }

  -- Setup plugin behaviours
  require("plugin.correo.log").new(opts.logging, true)
  require("plugin.correo.highlights").setup(opts)
  require("plugin.correo.excmd").setup(opts)
end

--- Open (or focus) a mailbox buffer
---@param opts { account?: string, folder?: string }|nil Mailbox to open (defaults from config)
M.open = function(opts) require("plugin.correo.mailbox").open(opts) end

return M
