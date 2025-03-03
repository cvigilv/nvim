---@module "after.plugin.ui.colorscheme"
---@author Carlos Vigil-Vásquez
---@license MIT 2024-2025

local augroup_colorscheme = vim.api.nvim_create_augroup("carlos::colorscheme", { clear = true })

local theme = vim.fn.system("defaults read -g AppleInterfaceStyle"):gsub("\n", "")
if theme == "Dark" then
  vim.o.background = "dark"
else
  vim.o.background = "light"
end

vim.cmd("colorscheme tempano")
