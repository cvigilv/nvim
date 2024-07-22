---@module 'user.helpers.tabline.components'
---@author Carlos Vigil-Vásquez
---@license MIT

M = {}

--- Get icon if bufname is "harpooned"
---@param bufname string Buffer ID from `vim.fn.bufname`
---@return string Harpooned icon
M.is_harpooned = function(bufname)
  local harpooned = ""
  local ok, harpoon = pcall(require, "harpoon")
  if ok then
    local list = harpoon:list()

    for _, item in ipairs(list.items) do
      if item.value == vim.fn.fnamemodify(bufname, "%:p:.") then
        harpooned = "󰛢 "
        break
      end
    end
  end
  return harpooned
end

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
