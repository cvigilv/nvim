---@module 'user.helpers.statusline.modifiers'
---@author Carlos Vigil-Vásquez
---@license MIT

M = {}

--- Highlight component contents using StatusLineImportant Highlight group
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
