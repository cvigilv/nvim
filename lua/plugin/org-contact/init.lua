---@module "plugin.org-contact"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local M = {}

M.init = function()
  -- Create excmds
  require("plugin.org-contact.excmds")

  -- Create autocommands for orgmode
  vim.api.nvim_create_autocmd("BufWritePost", {
    callback = function(ev)
      require("plugin.org-contact.core").update_references(ev.buf)
    end
  })

  -- Create conceal groups
end

return M
