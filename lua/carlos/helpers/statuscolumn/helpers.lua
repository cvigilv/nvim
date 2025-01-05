---@module 'carlos.helpers.statuscolumn.helpers'
---@author Carlos Vigil-Vásquez
---@license MIT

M = {}

--- Get all signs seen in current buffer
---@return table Signs
M.get_signs = function()
  return vim.api.nvim_buf_get_extmarks(
    0,
    -1,
    { vim.v.lnum - 1, 0 },
    { vim.v.lnum - 1, -1 },
    { type = "sign", details = true }
  )
end

return M
