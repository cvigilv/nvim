---@module "zk.excmd"
---@author Carlos Vigil Vásquez
---@license MIT

local factory = require("plugin.zk.factory")
local finders = require("plugin.zk.finders")

local M = {}

M.create_excmds = function(opts)
  -- Notes creation
  vim.api.nvim_create_user_command(
    "ZkNewTodayNote",
    function() factory.create_today_note(opts) end,
    { desc = "Create a new daily note" }
  )

  vim.api.nvim_create_user_command(
    "ZkNewDatedNote",
    function() factory.create_dated_note(opts) end,
    { desc = "Create a new dated note" }
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

  -- Misc
end

return M
