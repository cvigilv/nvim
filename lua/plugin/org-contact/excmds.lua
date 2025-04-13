---@module "plugin.org-contact.excmds"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local O = require("orgmode")

-- TODO: Implement capture template outside orgmode and load it only when running ContactoAdd
vim.api.nvim_create_user_command("ContactoAdd", function()
  O.capture:open_template_by_shortcut("x")
end, {})
