---@module "zk"
---@author Carlos Vigil Vasquez
---@license MIT 2024

local M = {}

--- Setup `zk.nvim`
---@param opts Zk.Config User configuration table
M.setup = function(opts)
  local config = require("plugin.zk.config")

  -- update defaults
  opts = config.update_config(opts)

  -- Module functionality
  require("plugin.zk.excmd").create_excmds(opts)
  require("plugin.zk.autocmd").setup(opts)
  require("plugin.zk.cmp").setup(opts)

  _G.carlos.zk = {}
end

return M
