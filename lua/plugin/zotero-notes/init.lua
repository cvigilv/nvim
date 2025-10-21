---@module "plugin.zotero.init"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local M = {}

function M.setup(opts)
  opts = require("plugin.zotero-notes.config").update_config(opts)
  _G.zotero_notes = { config = opts }

  -- Create user commands
  vim.api.nvim_create_user_command(
    "ZoteroNotes",
    function() require("plugin.zotero-notes.sync").picker(opts) end,
    {}
  )
end

return M
