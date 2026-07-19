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

--- Filter/sort the current mailbox with a Himalaya query
---@param query string|nil Query string (nil or "" clears the filter)
M.search = function(query) require("plugin.correo.mailbox").set_query(0, query or "") end

--- Compose a new message from scratch
---@param opts { account?: string }|nil Account to write from (defaults from config)
M.write = function(opts)
  opts = opts or {}
  require("plugin.correo.compose").open({
    account = opts.account or vim.g.correo.opts.account,
    kind = "write",
  })
end

return M
