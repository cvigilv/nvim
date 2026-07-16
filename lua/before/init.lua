---@module "before"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

-- Setup leader key
vim.g.mapleader = ","

-- Setup personal global table
_G.carlos = {}

vim.g.orgmode = {
  directory = "/Users/carlos/org/",
}

require("before.settings")
