---@module "lib.tables"
---@author Carlos Vigil-Vásquez
---@license MIT 2026

local M = {}

M.tbl_slice = function(tbl, first, last, step)
    local sliced = {}
    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced+1] = tbl[i]
    end
    return sliced
end

return M
