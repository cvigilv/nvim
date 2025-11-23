---@module 'lib.tabline.components'
---@author Carlos Vigil-Vásquez
---@license MIT

M = {}

M.fileicon = function(bufname)
  local extension = vim.fn.fnamemodify(bufname, ":e")
  local icon, _ = require("nvim-web-devicons").get_icon(bufname, extension)
  if icon ~= nil then
    return icon .. " "
  else
    return ""
  end
end

return M
