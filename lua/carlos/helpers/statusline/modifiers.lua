---@module 'carlos.helpers.statusline.modifiers'
---@author Carlos Vigil-Vásquez
---@license MIT

M = {}

--- Highlight component contents
---@param content string|nil Component contents
---@return string|nil hlcontents Highlighted component contents
M.highlight = function(content, hl_group)
  if content ~= nil then
    return "%#" .. hl_group .. "#" .. content .. "%*"
  else
    return nil
  end
end

---Make component contents bold
---@param content string|nil Component contents
---@return string|nil hlcontents Highlighted component contents
M.important = function(content)
  if content ~= nil then
    return "%#Bold#" .. content .. "%*"
  else
    return nil
  end
end

return M
