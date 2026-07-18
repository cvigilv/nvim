---@module "plugin.correo.message"
---@author Carlos Vigil-Vásquez
---@license MIT 2026

-- Message reading. A message opens as a real file at /tmp/<account>.<id> with
-- `filetype=mail`, fetched with `--preview` so merely reading never mutates
-- the envelope's "Seen" flag; marking seen/unseen is an explicit keymap.

local himalaya = require("plugin.correo.himalaya")
local log = require("plugin.correo.log")

---@class Correo.Message.Context
---@field account string|nil Account the message belongs to
---@field folder string Folder the message lives in
---@field envelope Correo.Himalaya.Envelope Envelope of the opened message
---@field mailbox_bufnr integer Mailbox buffer to return to (and refresh)

-- Per-buffer context, keyed by buffer number
---@type table<integer, Correo.Message.Context>
local State = {}

local M = {}

--- Build the on-disk path for a message buffer
---@param account string|nil Account name (nil → "default")
---@param id string Envelope id
---@return string path Path shaped as /tmp/<account>.<id>
local build_path = function(account, id)
  return ("/tmp/%s.%s"):format(account or "default", id)
end

--- Jump back to the mailbox this message was opened from
---@param bufnr integer Message buffer handle
local return_to_mailbox = function(bufnr)
  local _ctx = State[bufnr]
  if _ctx and vim.api.nvim_buf_is_valid(_ctx.mailbox_bufnr) then
    vim.api.nvim_set_current_buf(_ctx.mailbox_bufnr)
  else
    vim.cmd.bprevious()
  end
end

--- Configure buffer options, keymaps and cleanup for a message buffer
---@param bufnr integer Message buffer handle
---@param keymaps Correo.Keymaps.Configuration Keymap configuration
local configure_buffer = function(bufnr, keymaps)
  vim.bo[bufnr].filetype = "mail"
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].bufhidden = "wipe"

  local _map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = "correo: " .. desc })
  end
  _map(keymaps.quit, function() return_to_mailbox(bufnr) end, "back to mailbox")
  _map(keymaps.toggle_seen, function() M.toggle_seen(bufnr) end, "toggle seen flag")

  -- Drop per-buffer context when the buffer goes away
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = bufnr,
    callback = function() State[bufnr] = nil end,
  })
end

--- Toggle the "Seen" flag of the message shown in a buffer
---@param bufnr integer Message buffer handle (0 for the current buffer)
M.toggle_seen = function(bufnr)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  local _ctx = State[bufnr]
  if _ctx == nil then return end

  local _seen = vim.tbl_contains(_ctx.envelope.flags, "Seen")
  local _action = _seen and "remove" or "add"
  himalaya.change_flags(_action, {
    account = _ctx.account,
    folder = _ctx.folder,
    ids = { _ctx.envelope.id },
    flags = { "seen" },
  }, function(_, _err)
    if _err then
      vim.notify("[correo] " .. _err, vim.log.levels.ERROR)
      log.error(_err)
      return
    end
    -- Update the local copy so repeated toggles keep alternating
    if _seen then
      _ctx.envelope.flags = vim.tbl_filter(function(f) return f ~= "Seen" end, _ctx.envelope.flags)
    else
      table.insert(_ctx.envelope.flags, "Seen")
    end
    vim.notify(("[correo] marked %sseen"):format(_seen and "un" or ""), vim.log.levels.INFO)
    -- Reflect the change in the originating mailbox
    if vim.api.nvim_buf_is_valid(_ctx.mailbox_bufnr) then
      require("plugin.correo.mailbox").refresh(_ctx.mailbox_bufnr)
    end
  end)
end

--- Fetch a message and display it in a /tmp-backed buffer
---@param ctx Correo.Message.Context Message to open and where it came from
M.open = function(ctx)
  himalaya.read_message({
    account = ctx.account,
    folder = ctx.folder,
    id = ctx.envelope.id,
    preview = true,
  }, function(_content, _err)
    if _err then
      vim.notify("[correo] " .. _err, vim.log.levels.ERROR)
      log.error(_err)
      return
    end

    -- Materialize the message on disk, then edit it (reload if already open)
    local _path = build_path(ctx.account, ctx.envelope.id)
    vim.fn.writefile(vim.split(_content:gsub("\r\n", "\n"), "\n"), _path)
    vim.cmd.edit({ vim.fn.fnameescape(_path), bang = true })

    local _bufnr = vim.api.nvim_get_current_buf()
    State[_bufnr] = ctx
    configure_buffer(_bufnr, vim.g.correo.opts.keymaps)
    log.fmt_debug("opened message %s from %s", _path, ctx.folder)
  end)
end

return M
