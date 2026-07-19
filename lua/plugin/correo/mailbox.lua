---@module "plugin.correo.mailbox"
---@author Carlos Vigil-Vásquez
---@license MIT 2026

-- Mailbox-as-a-buffer UI. A mailbox is a `correo://<account>/<folder>` buffer
-- where each line is one envelope. Envelope identity is tracked per-line with
-- extmarks so later slices can reconcile buffer edits into mail operations.

local himalaya = require("plugin.correo.himalaya")
local render = require("plugin.correo.render")
local log = require("plugin.correo.log")

-- Namespace for both identity extmarks and highlight spans
local NS = vim.api.nvim_create_namespace("correo.mailbox")
-- Namespace for staged-operation virtual text
local STAGE_NS = vim.api.nvim_create_namespace("correo.mailbox.stage")

---@class Correo.Mailbox.StagedOp
---@field op "archive"|"move" Kind of staged operation
---@field target string Folder the envelope will be moved to
---@field mark integer Extmark id of the staged-op virtual text

---@class Correo.Mailbox.State
---@field account string|nil Account of this mailbox (nil → Himalaya's default)
---@field folder string Folder shown in this mailbox
---@field page integer Current page of the envelope listing
---@field envelopes Correo.Himalaya.Envelope[] Envelopes currently rendered
---@field marks table<integer, string> Identity extmark id → envelope id
---@field staged table<string, Correo.Mailbox.StagedOp> Staged ops, keyed by envelope id
---@field query string|nil Active filter/sort query (nil → unfiltered listing)

-- Per-buffer state, keyed by buffer number
---@type table<integer, Correo.Mailbox.State>
local State = {}

local M = {}

--- Compose the display name of a mailbox buffer, including any active query
---@param state Correo.Mailbox.State Mailbox state
---@return string name Buffer name, e.g. "correo://work/INBOX [subject foo]"
local mailbox_name = function(state)
  local _base = ("correo://%s/%s"):format(state.account or "default", state.folder)
  return state.query and (_base .. " [" .. state.query .. "]") or _base
end

--- Rename a buffer without leaving stale name-holding buffers around:
--- a rename parks the old name on an unlisted buffer (which would then block
--- renaming back with "buffer name already in use"), and any buffer already
--- holding the target name blocks the rename the same way
---@param bufnr integer Buffer handle to rename
---@param name string New buffer name
local rename_buffer = function(bufnr, name)
  local _wipe_others_named = function(_name)
    for _, _other in ipairs(vim.api.nvim_list_bufs()) do
      if _other ~= bufnr and vim.api.nvim_buf_get_name(_other) == _name then
        vim.api.nvim_buf_delete(_other, { force = true })
      end
    end
  end
  local _old = vim.api.nvim_buf_get_name(bufnr)
  _wipe_others_named(name)
  vim.api.nvim_buf_set_name(bufnr, name)
  _wipe_others_named(_old)
  -- Buffer renames don't trigger a statusline update on their own
  vim.cmd("redrawstatus!")
end

--- Find (by account/folder) or create the buffer for a mailbox
---@param account string|nil Account of the mailbox
---@param folder string Folder of the mailbox
---@return integer bufnr Buffer handle
---@return boolean is_new Whether the buffer was just created
local ensure_buffer = function(account, folder)
  -- Match on state, not name: an active query changes the buffer's name
  for _bufnr, _state in pairs(State) do
    if
      vim.api.nvim_buf_is_valid(_bufnr)
      and _state.account == account
      and _state.folder == folder
    then
      return _bufnr, false
    end
  end
  local _bufnr = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(_bufnr, ("correo://%s/%s"):format(account or "default", folder))
  return _bufnr, true
end

--- Configure buffer options, keymaps and cleanup for a mailbox buffer
---@param bufnr integer Buffer handle
---@param keymaps Correo.Keymaps.Configuration Keymap configuration
local configure_buffer = function(bufnr, keymaps)
  -- `acwrite` routes `:w` to our BufWriteCmd, which commits staged operations
  vim.bo[bufnr].buftype = "acwrite"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].filetype = "correo"

  local _map = function(lhs, rhs, desc)
    vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = "correo: " .. desc })
  end
  _map(keymaps.refresh, function() M.reload(bufnr) end, "refresh mailbox")
  _map(keymaps.open, function() M.open_message_at_cursor(bufnr) end, "open message")
  _map(keymaps.toggle_seen, function() M.toggle_seen_at_cursor(bufnr) end, "toggle seen flag")
  _map(keymaps.mark_unseen, function() M.mark_unseen_at_cursor(bufnr) end, "mark as unseen")
  _map(keymaps.archive, function() M.stage_archive_at_cursor(bufnr) end, "stage archive")
  _map(keymaps.move, function() M.stage_move_at_cursor(bufnr) end, "stage move to folder")
  _map(keymaps.reply, function() M.compose_at_cursor(bufnr, "reply", false) end, "reply")
  _map(keymaps.reply_all, function() M.compose_at_cursor(bufnr, "reply", true) end, "reply all")
  _map(keymaps.forward, function() M.compose_at_cursor(bufnr, "forward", false) end, "forward")
  _map(keymaps.next_page, function() M.change_page(bufnr, 1) end, "next page")
  _map(keymaps.prev_page, function() M.change_page(bufnr, -1) end, "previous page")
  _map(keymaps.select_folder, function() M.select_folder(bufnr) end, "open folder")
  _map(keymaps.select_account, function() M.select_account(bufnr) end, "open account")

  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = bufnr,
    callback = function() M.commit(bufnr) end,
  })

  -- Drop per-buffer state when the buffer goes away
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = bufnr,
    callback = function() State[bufnr] = nil end,
  })
end

--- Replace buffer contents with rendered envelopes and (re)apply extmarks
---@param bufnr integer Buffer handle
---@param envelopes Correo.Himalaya.Envelope[] Envelopes to draw
local draw = function(bufnr, envelopes)
  local _ui = vim.g.correo.opts.ui
  local _lines = {} ---@type Correo.Render.Line[]
  for _, _envelope in ipairs(envelopes) do
    table.insert(_lines, render.render_envelope(_envelope, _ui))
  end
  if #_lines == 0 then _lines = { { text = "-- empty folder --", spans = {} } } end

  -- Render with undo disabled so `u` can never revert past a draw (which
  -- would invalidate every identity mark and read as "delete everything")
  local _undolevels = vim.bo[bufnr].undolevels
  vim.bo[bufnr].undolevels = -1
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.tbl_map(function(l) return l.text end, _lines))
  vim.bo[bufnr].undolevels = _undolevels

  -- Reset namespaces: highlight spans plus one identity extmark per line.
  -- Identity marks use `invalidate` so deleting a line (dd) marks its
  -- envelope for deletion; undo restores the mark's validity.
  vim.api.nvim_buf_clear_namespace(bufnr, NS, 0, -1)
  vim.api.nvim_buf_clear_namespace(bufnr, STAGE_NS, 0, -1)
  local _marks = {}
  for _lnum, _line in ipairs(_lines) do
    for _, _span in ipairs(_line.spans) do
      vim.api.nvim_buf_set_extmark(bufnr, NS, _lnum - 1, _span.first, {
        end_col = _span.last,
        hl_group = _span.hl,
      })
    end
    local _envelope = envelopes[_lnum]
    if _envelope then
      local _id = vim.api.nvim_buf_set_extmark(bufnr, NS, _lnum - 1, 0, {
        invalidate = true,
        undo_restore = true,
        right_gravity = false,
      })
      _marks[_id] = _envelope.id
    end
  end
  State[bufnr].marks = _marks
  State[bufnr].staged = {}
  -- A freshly drawn mailbox has no pending operations
  vim.bo[bufnr].modified = false

  -- Surface non-default listing context (active query, page > 1) above line 1
  local _state = State[bufnr]
  if _state.query ~= nil or _state.page > 1 then
    local _info = {}
    if _state.query then table.insert(_info, "query: " .. _state.query) end
    if _state.page > 1 then table.insert(_info, "page " .. _state.page) end
    vim.api.nvim_buf_set_extmark(bufnr, NS, 0, 0, {
      virt_lines = { { { "≡ " .. table.concat(_info, " · "), "CorreoListingInfo" } } },
      virt_lines_above = true,
    })
  end
end

--- Check whether a mailbox has pending (uncommitted) operations
---@param bufnr integer Buffer handle of the mailbox
---@return boolean pending True if deletes or moves are staged
M.has_pending_changes = function(bufnr)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  if State[bufnr] == nil then return false end
  local _ops = M.gather_operations(bufnr)
  return #_ops.deletes > 0 or next(_ops.moves) ~= nil
end

--- Fetch envelopes for a mailbox buffer and redraw it
---
--- A redraw would wipe staged operations, so refreshes are "soft" by default:
--- they are skipped while the buffer has pending changes. Pass `force` from
--- flows where losing the staging is intended (commit, explicit reload).
---@param bufnr integer Buffer handle of the mailbox
---@param force boolean|nil Redraw even if operations are staged
M.refresh = function(bufnr, force)
  local _state = State[bufnr]
  if _state == nil then
    log.warn("refresh called on a non-mailbox buffer: " .. bufnr)
    return
  end
  if not force and M.has_pending_changes(bufnr) then
    log.debug("refresh skipped: mailbox has pending operations")
    return
  end

  local _opts = vim.g.correo.opts
  himalaya.list_envelopes({
    account = _state.account,
    folder = _state.folder,
    page = _state.page,
    page_size = _opts.page_size,
    query = _state.query,
  }, function(_envelopes, _err)
    if not vim.api.nvim_buf_is_valid(bufnr) then return end
    -- Paged past the end (IMAP errors, maildir returns []): step back to the
    -- last valid page instead of surfacing an error or drawing empty
    local _past_end = (_err ~= nil and _err:find("out of bounds", 1, true) ~= nil)
      or (_err == nil and #_envelopes == 0)
    if _past_end and _state.page > 1 then
      _state.page = _state.page - 1
      vim.notify("[correo] no more pages", vim.log.levels.INFO)
      M.refresh(bufnr, true)
      return
    end
    if _err then
      vim.notify("[correo] " .. _err, vim.log.levels.ERROR)
      log.error(_err)
      return
    end
    State[bufnr].envelopes = _envelopes
    draw(bufnr, _envelopes)
    log.fmt_debug("refreshed %s: %d envelopes", vim.api.nvim_buf_get_name(bufnr), #_envelopes)
  end)
end

--- Open (or focus) the mailbox buffer for a folder
---@param opts { account?: string, folder?: string }|nil Mailbox to open (defaults from config)
M.open = function(opts)
  opts = opts or {}
  local _cfg = vim.g.correo.opts
  local _account = opts.account or _cfg.account
  local _folder = opts.folder or _cfg.folder

  local _bufnr, _is_new = ensure_buffer(_account, _folder)
  if _is_new then
    State[_bufnr] =
      { account = _account, folder = _folder, page = 1, envelopes = {}, marks = {}, staged = {} }
    configure_buffer(_bufnr, _cfg.keymaps)
    -- Placeholder so a slow first fetch doesn't show an empty buffer (kept
    -- out of undo history, same as draws)
    local _undolevels = vim.bo[_bufnr].undolevels
    vim.bo[_bufnr].undolevels = -1
    vim.api.nvim_buf_set_lines(_bufnr, 0, -1, false, { ("Loading %s..."):format(_folder) })
    vim.bo[_bufnr].undolevels = _undolevels
    vim.bo[_bufnr].modified = false
  end

  vim.api.nvim_set_current_buf(_bufnr)
  vim.wo.wrap = false
  vim.wo.cursorline = true
  M.refresh(_bufnr)
end

--- Set (or clear) the filter/sort query of a mailbox and reload it
---@param bufnr integer Mailbox buffer handle (0 for the current buffer)
---@param query string|nil Himalaya query (nil or "" clears the filter)
M.set_query = function(bufnr, query)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  local _state = State[bufnr]
  if _state == nil then return end
  if M.has_pending_changes(bufnr) then
    vim.notify("[correo] commit or discard pending operations first", vim.log.levels.WARN)
    return
  end
  _state.query = query ~= "" and query or nil
  _state.page = 1
  -- Reflect the active filter in the buffer name
  rename_buffer(bufnr, mailbox_name(_state))
  M.refresh(bufnr, true)
end

--- Move `delta` pages through the mailbox listing (staying at page >= 1)
---@param bufnr integer Mailbox buffer handle (0 for the current buffer)
---@param delta integer Page offset (1 = next page, -1 = previous page)
M.change_page = function(bufnr, delta)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  local _state = State[bufnr]
  if _state == nil then return end
  if M.has_pending_changes(bufnr) then
    vim.notify("[correo] commit or discard pending operations first", vim.log.levels.WARN)
    return
  end
  local _page = math.max(1, _state.page + delta)
  if _page == _state.page then return end
  _state.page = _page
  M.refresh(bufnr, true)
end

--- Pick a folder of the current account and open its mailbox
---@param bufnr integer Mailbox buffer handle (0 for the current buffer)
M.select_folder = function(bufnr)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  local _state = State[bufnr]
  if _state == nil then return end
  himalaya.list_folders({ account = _state.account }, function(_folders, _err)
    if _err or _folders == nil then
      vim.notify("[correo] " .. (_err or "no folders"), vim.log.levels.ERROR)
      return
    end
    local _names = vim.tbl_map(function(f) return f.name end, _folders)
    vim.ui.select(_names, { prompt = "Open folder:" }, function(_choice)
      if _choice then M.open({ account = _state.account, folder = _choice }) end
    end)
  end)
end

--- Pick an account and open its default-folder mailbox
---@param bufnr integer Mailbox buffer handle (0 for the current buffer)
M.select_account = function(bufnr)
  local _ = bufnr -- Present for keymap symmetry; accounts are global
  himalaya.list_accounts(function(_accounts, _err)
    if _err or _accounts == nil then
      vim.notify("[correo] " .. (_err or "no accounts"), vim.log.levels.ERROR)
      return
    end
    local _names = vim.tbl_map(function(a) return a.name end, _accounts)
    vim.ui.select(_names, { prompt = "Open account:" }, function(_choice)
      if _choice then M.open({ account = _choice }) end
    end)
  end)
end

--- Reload the mailbox back to its default view (no filter, first page),
--- asking first if staged operations would be lost
---@param bufnr integer Buffer handle of the mailbox (0 for the current buffer)
M.reload = function(bufnr)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  if M.has_pending_changes(bufnr) then
    if vim.fn.confirm("Discard pending operations?", "&Yes\n&No", 2) ~= 1 then return end
  end
  local _state = State[bufnr]
  if _state ~= nil and (_state.query ~= nil or _state.page > 1) then
    _state.query = nil
    _state.page = 1
    rename_buffer(bufnr, mailbox_name(_state))
  end
  M.refresh(bufnr, true)
end

--- Open the message of the envelope under the cursor
---
--- In the drafts folder (per `drafts_folder` config) this resumes editing the
--- draft as a compose buffer instead of opening a read-only view.
---@param bufnr integer Mailbox buffer handle (0 for the current buffer)
M.open_message_at_cursor = function(bufnr)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  local _lnum = vim.api.nvim_win_get_cursor(0)[1]
  local _envelope = M.get_envelope_at(bufnr, _lnum)
  local _state = State[bufnr]
  if _envelope == nil or _state == nil then
    log.warn("no envelope under cursor")
    return
  end
  if _state.folder == vim.g.correo.opts.drafts_folder then
    require("plugin.correo.compose").open_draft({
      account = _state.account,
      folder = _state.folder,
      kind = "draft",
      envelope = _envelope,
      mailbox_bufnr = bufnr,
    })
    return
  end
  require("plugin.correo.message").open({
    account = _state.account,
    folder = _state.folder,
    envelope = _envelope,
    mailbox_bufnr = bufnr,
  })
end

--- Set the "Seen" flag of an envelope and refresh the mailbox
---@param bufnr integer Mailbox buffer handle
---@param envelope Correo.Himalaya.Envelope Envelope to update
---@param seen boolean Desired "Seen" state
local set_envelope_seen = function(bufnr, envelope, seen)
  local _state = State[bufnr]
  himalaya.change_flags(seen and "add" or "remove", {
    account = _state.account,
    folder = _state.folder,
    ids = { envelope.id },
    flags = { "seen" },
  }, function(_, _err)
    if _err then
      vim.notify("[correo] " .. _err, vim.log.levels.ERROR)
      log.error(_err)
      return
    end
    if vim.api.nvim_buf_is_valid(bufnr) then M.refresh(bufnr) end
  end)
end

--- Compose a reply/forward for the envelope under the cursor
---@param bufnr integer Mailbox buffer handle (0 for the current buffer)
---@param kind "reply"|"forward" Compose flavour
---@param reply_all boolean Whether a reply targets all recipients
M.compose_at_cursor = function(bufnr, kind, reply_all)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  local _envelope = M.get_envelope_at(bufnr, vim.api.nvim_win_get_cursor(0)[1])
  local _state = State[bufnr]
  if _envelope == nil or _state == nil then
    log.warn("no envelope under cursor")
    return
  end
  require("plugin.correo.compose").open({
    account = _state.account,
    folder = _state.folder,
    kind = kind,
    envelope = _envelope,
    reply_all = reply_all,
  })
end

--- Guard flag toggles against running on a mailbox with pending operations:
--- the redraw they need would either wipe the staging or show stale state
---@param bufnr integer Mailbox buffer handle
---@return boolean blocked True (with a hint to the user) if pending changes exist
local blocked_by_pending_changes = function(bufnr)
  if not M.has_pending_changes(bufnr) then return false end
  vim.notify(
    "[correo] pending operations: commit with :w or discard with reload first",
    vim.log.levels.WARN
  )
  return true
end

--- Toggle the "Seen" flag of the envelope under the cursor
---@param bufnr integer Mailbox buffer handle (0 for the current buffer)
M.toggle_seen_at_cursor = function(bufnr)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  local _envelope = M.get_envelope_at(bufnr, vim.api.nvim_win_get_cursor(0)[1])
  if _envelope == nil or State[bufnr] == nil then return end
  if blocked_by_pending_changes(bufnr) then return end
  set_envelope_seen(bufnr, _envelope, not vim.tbl_contains(_envelope.flags, "Seen"))
end

--- Mark the envelope under the cursor as unseen/unread
---@param bufnr integer Mailbox buffer handle (0 for the current buffer)
M.mark_unseen_at_cursor = function(bufnr)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  local _envelope = M.get_envelope_at(bufnr, vim.api.nvim_win_get_cursor(0)[1])
  if _envelope == nil or State[bufnr] == nil then return end
  if blocked_by_pending_changes(bufnr) then return end
  set_envelope_seen(bufnr, _envelope, false)
end

--- Toggle a staged operation on a mailbox line
---@param bufnr integer Mailbox buffer handle
---@param lnum integer 1-indexed line of the envelope
---@param op "archive"|"move" Kind of operation to stage
---@param target string Target folder of the operation
local toggle_staged = function(bufnr, lnum, op, target)
  local _envelope = M.get_envelope_at(bufnr, lnum)
  local _state = State[bufnr]
  if _envelope == nil or _state == nil then return end

  -- Restaging the same op unstages it; a different op replaces the current one
  local _current = _state.staged[_envelope.id]
  if _current ~= nil then
    vim.api.nvim_buf_del_extmark(bufnr, STAGE_NS, _current.mark)
    _state.staged[_envelope.id] = nil
    if _current.op == op and _current.target == target then return end
  end

  local _mark = vim.api.nvim_buf_set_extmark(bufnr, STAGE_NS, lnum - 1, 0, {
    virt_text = { { "→ " .. target, "CorreoStaged" } },
    virt_text_pos = "eol",
  })
  _state.staged[_envelope.id] = { op = op, target = target, mark = _mark }
  -- Pending operations count as unsaved changes (`:q` warns, `:w` commits)
  vim.bo[bufnr].modified = true
end

--- Stage/unstage archiving the envelope under the cursor
---@param bufnr integer Mailbox buffer handle (0 for the current buffer)
M.stage_archive_at_cursor = function(bufnr)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  local _lnum = vim.api.nvim_win_get_cursor(0)[1]
  toggle_staged(bufnr, _lnum, "archive", vim.g.correo.opts.archive_folder)
end

--- Stage/unstage moving the envelope under the cursor (folder picked via vim.ui.select)
---@param bufnr integer Mailbox buffer handle (0 for the current buffer)
M.stage_move_at_cursor = function(bufnr)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  local _lnum = vim.api.nvim_win_get_cursor(0)[1]
  local _envelope = M.get_envelope_at(bufnr, _lnum)
  local _state = State[bufnr]
  if _envelope == nil or _state == nil then return end

  -- Already staged as a move: plain unstage, no folder prompt needed
  local _current = _state.staged[_envelope.id]
  if _current ~= nil and _current.op == "move" then
    toggle_staged(bufnr, _lnum, "move", _current.target)
    return
  end

  himalaya.list_folders({ account = _state.account }, function(_folders, _err)
    if _err or _folders == nil then
      vim.notify("[correo] " .. (_err or "no folders"), vim.log.levels.ERROR)
      return
    end
    local _names = vim.tbl_map(function(f) return f.name end, _folders)
    vim.ui.select(_names, { prompt = "Move to folder:" }, function(_choice)
      if _choice then toggle_staged(bufnr, _lnum, "move", _choice) end
    end)
  end)
end

--- Collect the operations implied by buffer edits and staged keymap ops
---@param bufnr integer Mailbox buffer handle
---@return { deletes: Correo.Himalaya.Envelope[], moves: table<string, Correo.Himalaya.Envelope[]> } ops Moves are grouped by target folder
M.gather_operations = function(bufnr)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  local _state = State[bufnr]
  local _by_id = {}
  for _, _envelope in ipairs(_state.envelopes) do
    _by_id[_envelope.id] = _envelope
  end

  -- Envelopes whose identity extmark was invalidated (line deleted) are deletes
  local _deleted = {}
  for _mark, _id in pairs(_state.marks) do
    local _info = vim.api.nvim_buf_get_extmark_by_id(bufnr, NS, _mark, { details = true })
    if #_info == 0 or (_info[3] and _info[3].invalid) then _deleted[_id] = true end
  end

  local _ops = { deletes = {}, moves = {} }
  for _id in pairs(_deleted) do
    table.insert(_ops.deletes, _by_id[_id])
  end
  -- A delete wins over a staged move on the same envelope
  for _id, _staged in pairs(_state.staged) do
    if not _deleted[_id] then
      _ops.moves[_staged.target] = _ops.moves[_staged.target] or {}
      table.insert(_ops.moves[_staged.target], _by_id[_id])
    end
  end
  return _ops
end

--- Describe operations as human-readable lines for the confirmation prompt
---@param ops { deletes: Correo.Himalaya.Envelope[], moves: table<string, Correo.Himalaya.Envelope[]> }
---@return string[] lines One line per operation
local describe_operations = function(ops)
  local _lines = {}
  for _, _envelope in ipairs(ops.deletes) do
    table.insert(_lines, ("  delete       %s"):format(_envelope.subject))
  end
  for _target, _envelopes in pairs(ops.moves) do
    for _, _envelope in ipairs(_envelopes) do
      table.insert(_lines, ("  move → %s  %s"):format(_target, _envelope.subject))
    end
  end
  return _lines
end

--- Build one asynchronous CLI task per operation group
---@param state Correo.Mailbox.State Mailbox state (account/folder context)
---@param ops { deletes: Correo.Himalaya.Envelope[], moves: table<string, Correo.Himalaya.Envelope[]> }
---@return fun(next: fun(err: string|nil))[] tasks Tasks to run sequentially
local build_tasks = function(state, ops)
  local _ids = function(envelopes)
    return vim.tbl_map(function(e) return e.id end, envelopes)
  end
  local _tasks = {}
  if #ops.deletes > 0 then
    table.insert(_tasks, function(_next)
      himalaya.delete_messages({
        account = state.account,
        folder = state.folder,
        ids = _ids(ops.deletes),
      }, function(_, _err) _next(_err) end)
    end)
  end
  for _target, _envelopes in pairs(ops.moves) do
    table.insert(_tasks, function(_next)
      himalaya.move_messages({
        account = state.account,
        folder = state.folder,
        target = _target,
        ids = _ids(_envelopes),
      }, function(_, _err) _next(_err) end)
    end)
  end
  return _tasks
end

--- Run tasks one after another, stopping at the first error
---@param tasks fun(next: fun(err: string|nil))[] Remaining tasks
---@param on_done fun(err: string|nil) Callback once all tasks ran (or one failed)
local run_sequentially
run_sequentially = function(tasks, on_done)
  local _task = table.remove(tasks, 1)
  if _task == nil then
    on_done(nil)
    return
  end
  _task(function(_err)
    if _err then
      on_done(_err)
      return
    end
    run_sequentially(tasks, on_done)
  end)
end

--- Commit pending operations: confirm with the user, run them, refresh
---@param bufnr integer Mailbox buffer handle (0 for the current buffer)
M.commit = function(bufnr)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  local _state = State[bufnr]
  if _state == nil then return end

  local _ops = M.gather_operations(bufnr)
  local _description = describe_operations(_ops)
  if #_description == 0 then
    vim.notify("[correo] no operations to apply", vim.log.levels.INFO)
    M.refresh(bufnr, true) -- Restore any stray text edits
    return
  end

  local _prompt = ("correo will apply %d operation(s) on %s/%s:\n%s"):format(
    #_description,
    _state.account or "default",
    _state.folder,
    table.concat(_description, "\n")
  )
  if vim.fn.confirm(_prompt, "&Yes\n&No", 2) ~= 1 then
    -- Keep the staged operations: aborting the commit is not discarding work
    vim.notify("[correo] aborted, staged operations kept", vim.log.levels.INFO)
    return
  end

  run_sequentially(build_tasks(_state, _ops), function(_err)
    if _err then
      vim.notify("[correo] " .. _err, vim.log.levels.ERROR)
      log.error(_err)
    else
      vim.notify(("[correo] applied %d operation(s)"):format(#_description), vim.log.levels.INFO)
    end
    if vim.api.nvim_buf_is_valid(bufnr) then M.refresh(bufnr, true) end
  end)
end

--- Get the account/folder context of a mailbox buffer
---@param bufnr integer Buffer handle (0 for the current buffer)
---@return { account: string|nil, folder: string }|nil context Context, or nil if not a mailbox
M.get_context = function(bufnr)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  local _state = State[bufnr]
  return _state and { account = _state.account, folder = _state.folder } or nil
end

--- Get the envelope rendered on a given line of a mailbox buffer
---
--- Identity is resolved through the line's identity extmark, never by line
--- number: after edits (e.g. `dd`) lines shift but extmarks follow their
--- content. Invalid marks (from deleted lines) are skipped, so a just-deleted
--- envelope can never be resolved from the line that took its place.
---@param bufnr integer Buffer handle of the mailbox
---@param lnum integer 1-indexed line number
---@return Correo.Himalaya.Envelope|nil envelope Envelope on that line, if any
M.get_envelope_at = function(bufnr, lnum)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  local _state = State[bufnr]
  if _state == nil then return nil end

  -- Find the valid identity mark on this line (highlight-span marks share the
  -- namespace but are filtered out by the `_state.marks` lookup)
  local _marks =
    vim.api.nvim_buf_get_extmarks(bufnr, NS, { lnum - 1, 0 }, { lnum - 1, -1 }, { details = true })
  for _, _mark in ipairs(_marks) do
    local _envelope_id = _state.marks[_mark[1]]
    if _envelope_id ~= nil and not (_mark[4] and _mark[4].invalid) then
      for _, _envelope in ipairs(_state.envelopes) do
        if _envelope.id == _envelope_id then return _envelope end
      end
    end
  end
  return nil
end

return M
