local sync = require("plugin.zotero.sync")

local M = {}

-- Setup function
function M.setup(opts)
  print("FOOOOO")
  sync.setup(opts)

  -- Create user commands
  vim.api.nvim_create_user_command("ZoteroSync", function() sync.sync() end, {
    desc = "Sync Zotero library to Denote files",
  })

  vim.api.nvim_create_user_command("ZoteroDebug", function(args)
    local arg = args.args:lower()
    if arg == "on" or arg == "true" or arg == "1" then
      sync.set_debug(true)
    elseif arg == "off" or arg == "false" or arg == "0" then
      sync.set_debug(false)
    else
      vim.notify("[zotero] Usage: ZoteroDebug on|off", vim.log.levels.ERROR)
    end
  end, {
    nargs = 1,
    complete = function() return { "on", "off" } end,
    desc = "Toggle Zotero sync debug mode",
  })
end

-- Expose sync functions for manual use
M.sync = sync.sync
M.set_debug = sync.set_debug

return M
