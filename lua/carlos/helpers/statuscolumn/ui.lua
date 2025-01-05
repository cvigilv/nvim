---@module 'carlos.helpers.statuscolumn.ui'
---@author Carlos Vigil-Vásquez
---@license MIT

M = {}

M.aligner = function() return [[%=]] end
M.highlighter = function(hlgroup) return "%#" .. hlgroup .. "#" end

return M
