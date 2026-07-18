---@module "plugin.correo.excmd"
---@author Carlos Vigil-Vásquez
---@license MIT 2026

-- User commands. `:Correo [folder]` opens a mailbox buffer; folder names are
-- completed from a cache primed lazily on first use (completion callbacks must
-- be synchronous, so we can't fetch folders on the fly).

local himalaya = require("plugin.correo.himalaya")
local log = require("plugin.correo.log")

-- Folder-name cache for command completion, keyed by account label
---@type table<string, string[]>
local Folder_cache = {}

local M = {}

--- Resolve the cache key for the currently configured account
---@return string key Account name or "default"
local account_key = function() return vim.g.correo.opts.account or "default" end

--- Fetch folder names in the background to feed command completion
local prime_folder_cache = function()
  if Folder_cache[account_key()] ~= nil then return end
  Folder_cache[account_key()] = {} -- Reserve the slot so we only fetch once
  himalaya.list_folders({ account = vim.g.correo.opts.account }, function(_folders, _err)
    if _err or _folders == nil then
      log.warn("could not prime folder cache: " .. (_err or "no folders"))
      return
    end
    Folder_cache[account_key()] = vim.tbl_map(function(f) return f.name end, _folders)
  end)
end

--- Complete folder names for `:Correo`
---@param arglead string Leading portion of the argument being completed
---@return string[] candidates Matching folder names
local complete_folder = function(arglead)
  local _folders = Folder_cache[account_key()] or {}
  return vim.tbl_filter(
    function(_name) return vim.startswith(_name:lower(), arglead:lower()) end,
    _folders
  )
end

--- Create the plugin's user commands
---@param opts Correo.Configuration Plugin configuration
M.setup = function(opts)
  local _ = opts -- Commands read live config through `vim.g.correo`
  vim.api.nvim_create_user_command("Correo", function(_cmd)
    prime_folder_cache()
    local _folder = _cmd.fargs[1]
    require("plugin.correo.mailbox").open({ folder = _folder })
  end, {
    nargs = "?",
    complete = complete_folder,
    desc = "Open a mailbox as a buffer (defaults to the configured folder)",
  })
end

return M
