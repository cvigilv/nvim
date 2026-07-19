---@module "plugin.correo.excmd"
---@author Carlos Vigil-Vásquez
---@license MIT 2026

-- User commands. `:Correo [account]` opens an account's mailbox at the default
-- folder; `:CorreoFolder <name>` switches folder within the current account.
-- Completion candidates come from caches primed lazily in the background,
-- since completion callbacks must be synchronous.

local himalaya = require("plugin.correo.himalaya")
local log = require("plugin.correo.log")

-- Account names for `:Correo` completion (nil until first primed)
---@type string[]|nil
local Account_cache = nil

-- Folder names for `:CorreoFolder` completion, keyed by account label
---@type table<string, string[]>
local Folder_cache = {}

local M = {}

--- Resolve the cache key for an account value
---@param account string|nil Account name (nil → Himalaya's default account)
---@return string key Account name or "default"
local account_key = function(account) return account or "default" end

--- Fetch account names in the background to feed `:Correo` completion
local prime_account_cache = function()
  if Account_cache ~= nil then return end
  Account_cache = {} -- Reserve the slot so we only fetch once
  himalaya.list_accounts(function(_accounts, _err)
    if _err or _accounts == nil then
      log.warn("could not prime account cache: " .. (_err or "no accounts"))
      return
    end
    Account_cache = vim.tbl_map(function(a) return a.name end, _accounts)
  end)
end

--- Fetch an account's folder names in the background to feed `:CorreoFolder` completion
---@param account string|nil Account whose folders should be cached
local prime_folder_cache = function(account)
  local _key = account_key(account)
  if Folder_cache[_key] ~= nil then return end
  Folder_cache[_key] = {} -- Reserve the slot so we only fetch once
  himalaya.list_folders({ account = account }, function(_folders, _err)
    if _err or _folders == nil then
      log.warn("could not prime folder cache: " .. (_err or "no folders"))
      return
    end
    Folder_cache[_key] = vim.tbl_map(function(f) return f.name end, _folders)
  end)
end

--- Filter candidates by case-insensitive prefix
---@param candidates string[] Candidate strings
---@param arglead string Leading portion of the argument being completed
---@return string[] matches Candidates starting with `arglead`
local match_prefix = function(candidates, arglead)
  return vim.tbl_filter(
    function(_name) return vim.startswith(_name:lower(), arglead:lower()) end,
    candidates
  )
end

--- Resolve the account in scope: current mailbox's account, else configured default
---@return string|nil account Account name (nil → Himalaya's default account)
local current_account = function()
  local _ctx = require("plugin.correo.mailbox").get_context(0)
  return _ctx and _ctx.account or vim.g.correo.opts.account
end

--- Dispatch a buffer action to the mailbox or message implementation
---@param mailbox_fn fun(bufnr: integer) Action for mailbox buffers
---@param message_fn fun(bufnr: integer)|nil Action for message buffers (nil → mailbox only)
local dispatch = function(mailbox_fn, message_fn)
  if require("plugin.correo.mailbox").get_context(0) ~= nil then
    mailbox_fn(0)
    return
  end
  if message_fn ~= nil and require("plugin.correo.message").get_context(0) ~= nil then
    message_fn(0)
    return
  end
  vim.notify("[correo] not in a correo buffer", vim.log.levels.WARN)
end

--- Create the buffer-action user commands (command counterparts of the keymaps)
local setup_action_commands = function()
  local _command = vim.api.nvim_create_user_command
  local _mailbox = function(fn) return require("plugin.correo.mailbox")[fn] end
  local _message = function(fn) return require("plugin.correo.message")[fn] end

  _command("CorreoOpen", function()
    dispatch(function(b) _mailbox("open_message_at_cursor")(b) end)
  end, { desc = "Open the message under the cursor" })

  _command("CorreoSeen", function()
    dispatch(
      function(b) _mailbox("toggle_seen_at_cursor")(b) end,
      function(b) _message("toggle_seen")(b) end
    )
  end, { desc = "Toggle the seen flag" })

  _command("CorreoUnseen", function()
    dispatch(
      function(b) _mailbox("mark_unseen_at_cursor")(b) end,
      function(b) _message("set_seen")(b, false) end
    )
  end, { desc = "Mark as unseen/unread" })

  _command("CorreoArchive", function()
    dispatch(function(b) _mailbox("stage_archive_at_cursor")(b) end)
  end, { desc = "Stage/unstage archiving the envelope under the cursor" })

  _command("CorreoMove", function(_cmd)
    -- Folder names may contain spaces, so rejoin fargs; no args → picker
    local _target = #_cmd.fargs > 0 and table.concat(_cmd.fargs, " ") or nil
    dispatch(function(b) _mailbox("stage_move_at_cursor")(b, _target) end)
  end, {
    nargs = "*",
    complete = function(_arglead)
      local _account = current_account()
      prime_folder_cache(_account)
      return match_prefix(Folder_cache[account_key(_account)] or {}, _arglead)
    end,
    desc = "Stage moving the envelope under the cursor (no args: pick a folder)",
  })

  _command("CorreoReply", function(_cmd)
    dispatch(
      function(b) _mailbox("compose_at_cursor")(b, "reply", _cmd.bang) end,
      function(b) _message("compose")(b, "reply", _cmd.bang) end
    )
  end, { bang = true, desc = "Reply to the current message (! replies to all)" })

  _command("CorreoForward", function()
    dispatch(
      function(b) _mailbox("compose_at_cursor")(b, "forward", false) end,
      function(b) _message("compose")(b, "forward", false) end
    )
  end, { desc = "Forward the current message" })
end

--- Create the plugin's user commands
---@param opts Correo.Configuration Plugin configuration
M.setup = function(opts)
  local _ = opts -- Commands read live config through `vim.g.correo`
  setup_action_commands()

  vim.api.nvim_create_user_command("Correo", function(_cmd)
    local _account = _cmd.fargs[1] or vim.g.correo.opts.account
    prime_account_cache()
    prime_folder_cache(_account)
    require("plugin.correo.mailbox").open({ account = _account })
  end, {
    nargs = "?",
    complete = function(_arglead)
      prime_account_cache()
      return match_prefix(Account_cache or {}, _arglead)
    end,
    desc = "Open an account's mailbox (defaults to the configured account)",
  })

  vim.api.nvim_create_user_command("CorreoSearch", function(_cmd)
    local _mailbox = require("plugin.correo.mailbox")
    if _mailbox.get_context(0) == nil then
      vim.notify("[correo] open a mailbox first (:Correo)", vim.log.levels.WARN)
      return
    end
    -- No argument clears the active filter
    _mailbox.set_query(0, table.concat(_cmd.fargs, " "))
  end, {
    nargs = "*",
    desc = "Filter/sort the current mailbox with a Himalaya query (no args to clear)",
  })

  vim.api.nvim_create_user_command("CorreoWrite", function(_cmd)
    local _account = _cmd.fargs[1] or current_account()
    require("plugin.correo.compose").open({ account = _account, kind = "write" })
  end, {
    nargs = "?",
    complete = function(_arglead)
      prime_account_cache()
      return match_prefix(Account_cache or {}, _arglead)
    end,
    desc = "Compose a new message (defaults to the account in scope)",
  })

  vim.api.nvim_create_user_command("CorreoFolder", function(_cmd)
    local _account = current_account()
    prime_folder_cache(_account)
    -- Folder names may contain spaces ("Science/Tapia Lab"), so rejoin fargs
    local _folder = table.concat(_cmd.fargs, " ")
    require("plugin.correo.mailbox").open({ account = _account, folder = _folder })
  end, {
    nargs = "+",
    complete = function(_arglead)
      local _account = current_account()
      prime_folder_cache(_account)
      return match_prefix(Folder_cache[account_key(_account)] or {}, _arglead)
    end,
    desc = "Open a folder of the current account's mailbox",
  })
end

return M
