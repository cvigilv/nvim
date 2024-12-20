---@module "plugin.afuera.helpers"
---@author Carlos Vigil-Vásquez
---@license MIT 2024

local M = {}

M.activate_oob_mode = function(winnr, opts)
  -- Activate colorcolumn OOB area
  local cols = {}
  for i = tonumber(opts.defaults.colorcolumn) or 96, 256, 1 do
    table.insert(cols, i)
  end
  vim.api.nvim_set_option_value(
    "colorcolumn",
    table.concat(cols, ","),
    { scope = "local", win = winnr }
  )
  vim.api.nvim_set_option_value("winhighlight", "", { scope = "local", win = winnr })
end

M.deactivate_oob_mode = function(winnr, opts)
  vim.api.nvim_set_option_value(
    "colorcolumn",
    tostring(opts.defaults.colorcolumn),
    { scope = "local", win = winnr }
  )

  vim.api.nvim_set_option_value(
    "winhighlight",
    "EndOfBuffer:Normal",
    { scope = "local", win = winnr }
  )
end

M.set_oob_mode = function(bufnr, winnr, opts)
  if opts.state[tostring(bufnr)] then
    M.activate_oob_mode(winnr, opts)
  else
    M.deactivate_oob_mode(winnr, opts)
  end
end

return M
