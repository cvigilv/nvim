---@module "user.winbar.components"
---@author Carlos Vigil-Vásquez
---@license MIT

M = {}

---Checks if the current file is harpooned.
---@return string|nil "󰛢 " if the file is harpooned, nil otherwise
M.is_harpooned = function()
  local current_file = vim.fn.expand("%:p:.")

  local ok, harpoon = pcall(require, "harpoon")
  if not ok then return "" end -- no harpoon, no harpoon status

  local list = harpoon:list()

  for _, item in ipairs(list.items) do
    if item.value == current_file then return "󰛢 " end
  end

  return nil
end

return M
