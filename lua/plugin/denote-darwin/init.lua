---@module "plugin.denote-darwin"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

vim.keymap.set("n", "<leader>zg", require("plugin.denote-darwin.graph").modelize_silo)
