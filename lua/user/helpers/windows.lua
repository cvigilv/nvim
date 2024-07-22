---@module 'user.helpers.windows'
---@author Carlos Vigil-Vásquez
---@license MIT

M = {}

M.is_floating = function(win_id)
  local cfg = vim.api.nvim_win_get_config(win_id)
  ---@diagnostic disable-next-line: undefined-field
  if cfg.relative > "" or cfg.external then return nil end
  return win_id
end

return M
