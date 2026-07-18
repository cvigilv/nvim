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
  if _ctx == nil or not vim.api.nvim_buf_is_valid(_ctx.mailbox_bufnr) then
    vim.cmd.bprevious()
    return
  end
  -- Mailbox visible in another window (split mode): close ours and focus it
  local _win = vim.fn.bufwinid(_ctx.mailbox_bufnr)
  if _win ~= -1 and _win ~= vim.api.nvim_get_current_win() then
    vim.api.nvim_win_close(vim.api.nvim_get_current_win(), false)
    vim.api.nvim_set_current_win(_win)
    return
  end
  vim.api.nvim_set_current_buf(_ctx.mailbox_bufnr)
end

--- Find a window in the current tab already showing a message of a mailbox
---@param mailbox_bufnr integer Mailbox buffer handle
---@return integer|nil win Window handle, or nil if none
local find_message_window = function(mailbox_bufnr)
  for _, _win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local _ctx = State[vim.api.nvim_win_get_buf(_win)]
    if _ctx and _ctx.mailbox_bufnr == mailbox_bufnr then return _win end
  end
  return nil
end

--- Display a message file according to `ui.message.open` ("replace" or "split")
---@param path string Path of the message file on disk
---@param mailbox_bufnr integer Mailbox buffer the message was opened from
local display = function(path, mailbox_bufnr)
  local _style = vim.g.correo.opts.ui.message.open
  local _reuse_win = find_message_window(mailbox_bufnr)
  if _style == "split" and _reuse_win ~= nil then
    -- A split for this mailbox is already open: reuse it
    vim.api.nvim_set_current_win(_reuse_win)
  elseif _style == "split" then
    -- 20% mailbox on top, 80% message below
    local _height = math.floor(vim.api.nvim_win_get_height(0) * 0.8)
    vim.cmd(("belowright %dsplit"):format(_height))
  end
  vim.cmd.edit({ vim.fn.fnameescape(path), bang = true })
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

    -- Materialize the message on disk, then display it (reload if already open)
    local _path = build_path(ctx.account, ctx.envelope.id)
    vim.fn.writefile(vim.split(_content:gsub("\r\n", "\n"), "\n"), _path)
    display(_path, ctx.mailbox_bufnr)

    local _bufnr = vim.api.nvim_get_current_buf()
    State[_bufnr] = ctx
    configure_buffer(_bufnr, vim.g.correo.opts.keymaps)
    log.fmt_debug("opened message %s from %s", _path, ctx.folder)
  end)
end

return M
