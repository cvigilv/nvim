---@module 'carlos.helpers.statusline.modifiers'
---@author Carlos Vigil-Vásquez
---@license MIT

M = {}

--- Highlight component contents
---@param content string|nil Component contents
---@return string|nil hlcontents Highlighted component contents
M.important = function(content)
  if content ~= nil then
    return "%#StatusLine#" .. content .. "%#StatusLineNC#"
  else
    return nil
  end
end

return M
