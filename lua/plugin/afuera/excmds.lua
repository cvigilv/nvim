---@module "plugin.afuera.excmds"
---@author Carlos Vigil-Vásquez
---@license MIT 2024

local C = require("plugin.afuera.core")

local M = {}

M.setup = function(opts)
  vim.api.nvim_create_user_command("AfueraToggle", function()
    local winnr = vim.api.nvim_get_current_win()
    local bufnr = tostring(vim.api.nvim_get_current_buf())
    opts.state[bufnr] = not opts.state[bufnr]
    C.set_oob_mode(bufnr, winnr, opts)
  end, {})

  vim.api.nvim_create_user_command("AfueraOn", function()
    local winnr = vim.api.nvim_get_current_win()
    local bufnr = tostring(vim.api.nvim_get_current_buf())
    opts.state[bufnr] = true
    C.set_oob_mode(bufnr, winnr, opts)
  end, {})

  vim.api.nvim_create_user_command("AfueraOff", function()
    local winnr = vim.api.nvim_get_current_win()
    local bufnr = tostring(vim.api.nvim_get_current_buf())
    opts.state[bufnr] = false
    C.set_oob_mode(bufnr, winnr, opts)
  end, {})

  vim.api.nvim_create_user_command("AfueraStatus", function() vim.print(opts) end, {})
end

return M
