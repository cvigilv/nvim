---@module "zk.excmd"
---@author Carlos Vigil Vásquez
---@license MIT

local factory = require("plugin.zk.factory")
local finders = require("plugin.zk.finders")
local ui = require("plugin.zk.ui")

local M = {}

---Creates user commands for managing Zettelkasten notes in Neovim.
---@param opts Zk.Config User configuration
M.create_excmds = function(opts)
  -- Notes creation
  vim.api.nvim_create_user_command(
    "ZkNewNote",
    function() factory.create_new_note(opts) end,
    { desc = "Create a new daily note" }
  )

  -- Note searching
  vim.api.nvim_create_user_command(
    "ZkSearchNotes",
    function() finders.search_headings(opts) end,
    { desc = "Search notes by heading" }
  )

  vim.api.nvim_create_user_command(
    "ZkSearchTags",
    function() finders.search_tags(opts) end,
    { desc = "Search notes by heading" }
  )

  -- UI
  vim.api.nvim_create_user_command(
    "ZkLinks",
    function() ui.show_links(nil, opts) end,
    { desc = "Show links to file." }
  )
end

return M
