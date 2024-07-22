---@module 'user.helpers.statusline.ui'
---@author Carlos Vigil-Vásquez
---@license MIT

M = {}

M.leftcap = function() return "%#StatusLineCap#%#StatusLineNormal#" end
M.rightcap = function() return "%#StatusLineCap#%#StatusLine#" end
M.align = function() return "%=" end

return M
