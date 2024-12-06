---@module "zk"
---@author Carlos Vigil Vasquez
---@license MIT 2024

local M = {}

--- Setup `zk.nvim`
---@param opts Zk.Config User configuration table
M.setup = function(opts)
  local config = require("plugin.zk.config")
  local excmd = require("plugin.zk.excmd")
  local autocmd = require("plugin.zk.autocmd")

  -- update defaults
  opts = config.update_config(opts)

  -- Module functionality
  excmd.create_excmds(opts)
  autocmd.setup(opts)
end

return M
