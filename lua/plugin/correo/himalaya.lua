---@module "plugin.correo.himalaya"
---@author Carlos Vigil-Vásquez
---@license MIT 2026

-- Himalaya CLI adapter. The single place that knows Himalaya's subcommands,
-- flags and JSON shapes. Every function builds an argv and delegates execution
-- to `cli.lua`, so a future backend only needs to reimplement this module.

local cli = require("plugin.correo.cli")

---@class Correo.Himalaya.Address
---@field name string|nil Display name of the contact
---@field addr string Email address of the contact

---@class Correo.Himalaya.Envelope
---@field id string Envelope identifier used by every other Himalaya command
---@field flags string[] IMAP flags (e.g. "Seen", "Flagged", "Answered")
---@field subject string Message subject
---@field from Correo.Himalaya.Address Sender
---@field to Correo.Himalaya.Address Recipient
---@field date string Timestamp formatted as "YYYY-MM-DD HH:MM+TZ"
---@field has_attachment boolean Whether the message carries attachments

---@class Correo.Himalaya.Account
---@field name string Account name as defined in Himalaya's configuration
---@field backend string Backend description (e.g. "IMAP, SMTP")
---@field default boolean Whether this is the default account

---@class Correo.Himalaya.Folder
---@field name string Folder name (e.g. "INBOX", "PhD/Cursos")
---@field desc string IMAP attributes of the folder (e.g. "\\HasNoChildren")

---@class Correo.Himalaya.ContextOpts
---@field account string|nil Account to use (nil → Himalaya's default account)
---@field folder string|nil Folder to target (nil → Himalaya's default folder)

local M = {}

--- Resolve the configured Himalaya binary
---@return string binary Path or name of the Himalaya executable
local resolve_binary = function()
  local _opts = vim.g.correo and vim.g.correo.opts or nil
  return _opts and _opts.binary or "himalaya"
end

--- Build a Himalaya argv with JSON output and optional account/folder flags
---@param subcmd string[] Subcommand parts, e.g. { "envelope", "list" }
---@param ctx Correo.Himalaya.ContextOpts|nil Account/folder context
---@param extra string[]|nil Extra positional arguments or flags
---@return string[] argv Full command ready for `cli.run_json`
local build_argv = function(subcmd, ctx, extra)
  ctx = ctx or {}
  local _argv = { resolve_binary() }
  vim.list_extend(_argv, subcmd)
  if ctx.account then vim.list_extend(_argv, { "--account", ctx.account }) end
  if ctx.folder then vim.list_extend(_argv, { "--folder", ctx.folder }) end
  if extra then vim.list_extend(_argv, extra) end
  vim.list_extend(_argv, { "--output", "json" })
  return _argv
end

--- List envelopes of a folder, newest first
---@param opts { account?: string, folder?: string, page?: integer, page_size?: integer }
---@param on_done fun(envelopes: Correo.Himalaya.Envelope[]|nil, err: string|nil)
M.list_envelopes = function(opts, on_done)
  local _extra = {}
  if opts.page then vim.list_extend(_extra, { "--page", tostring(opts.page) }) end
  if opts.page_size then vim.list_extend(_extra, { "--page-size", tostring(opts.page_size) }) end
  local _ctx = { account = opts.account, folder = opts.folder }
  cli.run_json(build_argv({ "envelope", "list" }, _ctx, _extra), on_done)
end

--- List all folders of an account
---@param opts { account?: string }
---@param on_done fun(folders: Correo.Himalaya.Folder[]|nil, err: string|nil)
M.list_folders = function(opts, on_done)
  cli.run_json(build_argv({ "folder", "list" }, { account = opts.account }), on_done)
end

--- List all configured accounts
---@param on_done fun(accounts: Correo.Himalaya.Account[]|nil, err: string|nil)
M.list_accounts = function(on_done)
  cli.run_json(build_argv({ "account", "list" }), on_done)
end

-- Headers shown at the top of a read message, in display order
local READ_HEADERS = { "From", "To", "Cc", "Subject", "Date" }

--- Read the rendered plain-text version of a message
---@param opts { account?: string, folder?: string, id: string, preview?: boolean }
---@param on_done fun(content: string|nil, err: string|nil) Callback with the message text
M.read_message = function(opts, on_done)
  -- `--preview` reads without applying the "Seen" flag to the envelope
  local _extra = opts.preview and { "--preview" } or {}
  for _, _header in ipairs(READ_HEADERS) do
    vim.list_extend(_extra, { "--header", _header })
  end
  table.insert(_extra, opts.id)
  local _ctx = { account = opts.account, folder = opts.folder }
  cli.run_json(build_argv({ "message", "read" }, _ctx, _extra), on_done)
end

--- Mark messages as deleted (moved to trash or expunged, per backend behaviour)
---@param opts { account?: string, folder?: string, ids: string[] }
---@param on_done fun(result: string|nil, err: string|nil) Callback with Himalaya's status message
M.delete_messages = function(opts, on_done)
  local _ctx = { account = opts.account, folder = opts.folder }
  cli.run_json(build_argv({ "message", "delete" }, _ctx, opts.ids), on_done)
end

--- Move messages to a target folder
---@param opts { account?: string, folder?: string, target: string, ids: string[] }
---@param on_done fun(result: string|nil, err: string|nil) Callback with Himalaya's status message
M.move_messages = function(opts, on_done)
  local _extra = { opts.target }
  vim.list_extend(_extra, opts.ids)
  local _ctx = { account = opts.account, folder = opts.folder }
  cli.run_json(build_argv({ "message", "move" }, _ctx, _extra), on_done)
end

--- Add or remove flags on envelopes
---@param action "add"|"remove" Whether to add or remove the flags
---@param opts { account?: string, folder?: string, ids: string[], flags: string[] }
---@param on_done fun(result: string|nil, err: string|nil) Callback with Himalaya's status message
M.change_flags = function(action, opts, on_done)
  -- Himalaya parses integers as ids and everything else as flags
  local _extra = {}
  vim.list_extend(_extra, opts.ids)
  vim.list_extend(_extra, opts.flags)
  local _ctx = { account = opts.account, folder = opts.folder }
  cli.run_json(build_argv({ "flag", action }, _ctx, _extra), on_done)
end

return M
