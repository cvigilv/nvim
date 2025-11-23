---@module "lib.tables"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local M = {}

---Counts occurrences of elements in a table.
---@param tbl table The input table to count elements from
---@return table counts A table with elements as keys and their counts as values
M.counter = function(tbl)
  local counts = {}
  for _, v in ipairs(tbl) do
    if vim.tbl_contains(vim.tbl_keys(counts), v) then
      counts[v] = counts[v] + 1
    else
      counts[v] = 1
    end
  end
  return counts
end

return M
