---@module "plugin.zk.autocmd"
---@author Carlos Vigil-Vásquez
---@license MIT 2024

local M = {}

local augroup = vim.api.nvim_create_augroup("zk", { clear = true })

M.setup = function(opts)
  -- vim.api.nvim_create_autocmd("BufWritePre", {
  --   group = augroup,
  --   pattern = vim.fs.joinpath(opts.path, "*"),
  --   callback = function()
  --     local utils = require("plugin.zk.utils")
  --     local h1 = utils.get_title()
  --     local properties = utils.get_yaml_header()
  --
  --     if h1 ~= properties.title then
  --       properties = vim.tbl_deep_extend("force", properties, { title = h1 })
  --       utils.write_yaml_header_to_buffer(properties)
  --     elseif properties == nil then
  --       utils.write_yaml_header_to_buffer({ title = h1 })
  --     end
  --   end,
  -- })
end

return M
