---@module 'user.helpers.statusline.helpers'
---@author Carlos Vigil-Vásquez
---@license MIT

local pad = require("user.helpers.string")

M = {}

--- Return content if condition is met
---@param condition boolean Condition to test
---@param content string|nil Content
---@return string|nil Content
M.ifttt = function(condition, content, fallback)
	if content ~= nil and condition then
		return content
	else
		return fallback or nil
	end
end

--- Center content using padding
---@param content string Content
---@param length integer|nil Padded text length
---@param char string|nil Padding character
---@return string
M.center = function(content, length, char)
	length = length or 24
	char = char or " "

	if #content > length then
		content = string.sub(content, -length + 2, -1)
	end

	return pad.pad(content, length, char)
end

return M
