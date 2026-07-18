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

---@class Correo.Mailbox.State
---@field account string|nil Account of this mailbox (nil → Himalaya's default)
---@field folder string Folder shown in this mailbox
---@field page integer Current page of the envelope listing
---@field envelopes Correo.Himalaya.Envelope[] Envelopes currently rendered
---@field marks table<integer, string> Identity extmark id → envelope id

-- Per-buffer state, keyed by buffer number
---@type table<integer, Correo.Mailbox.State>
local State = {}

local M = {}

--- Find or create the buffer for a given mailbox name
---@param name string Buffer name, e.g. "correo://work/INBOX"
---@return integer bufnr Buffer handle
---@return boolean is_new Whether the buffer was just created
local ensure_buffer = function(name)
  for _, _bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(_bufnr) == name then return _bufnr, false end
  end
  local _bufnr = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_name(_bufnr, name)
  return _bufnr, true
end

--- Configure buffer options, keymaps and cleanup for a mailbox buffer
---@param bufnr integer Buffer handle
---@param keymaps Correo.Keymaps.Configuration Keymap configuration
local configure_buffer = function(bufnr, keymaps)
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].filetype = "correo"

  vim.keymap.set("n", keymaps.refresh, function() M.refresh(bufnr) end, {
    buffer = bufnr,
    desc = "correo: refresh mailbox",
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

  -- Swap in the new lines (buffer is kept non-modifiable for the user)
  vim.bo[bufnr].modifiable = true
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.tbl_map(function(l) return l.text end, _lines))
  vim.bo[bufnr].modifiable = false

  -- Reset namespace: highlight spans plus one identity extmark per line
  vim.api.nvim_buf_clear_namespace(bufnr, NS, 0, -1)
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
      local _id = vim.api.nvim_buf_set_extmark(bufnr, NS, _lnum - 1, 0, {})
      _marks[_id] = _envelope.id
    end
  end
  State[bufnr].marks = _marks
end

--- Fetch envelopes for a mailbox buffer and redraw it
---@param bufnr integer Buffer handle of the mailbox
M.refresh = function(bufnr)
  local _state = State[bufnr]
  if _state == nil then
    log.warn("refresh called on a non-mailbox buffer: " .. bufnr)
    return
  end

  local _opts = vim.g.correo.opts
  himalaya.list_envelopes({
    account = _state.account,
    folder = _state.folder,
    page = _state.page,
    page_size = _opts.page_size,
  }, function(_envelopes, _err)
    if not vim.api.nvim_buf_is_valid(bufnr) then return end
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

  local _name = ("correo://%s/%s"):format(_account or "default", _folder)
  local _bufnr, _is_new = ensure_buffer(_name)
  if _is_new then
    State[_bufnr] = { account = _account, folder = _folder, page = 1, envelopes = {}, marks = {} }
    configure_buffer(_bufnr, _cfg.keymaps)
    -- Placeholder so a slow first fetch doesn't show an empty buffer
    vim.bo[_bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(_bufnr, 0, -1, false, { ("Loading %s..."):format(_folder) })
    vim.bo[_bufnr].modifiable = false
  end

  vim.api.nvim_set_current_buf(_bufnr)
  vim.wo.wrap = false
  vim.wo.cursorline = true
  M.refresh(_bufnr)
end

--- Get the envelope rendered on a given line of a mailbox buffer
---@param bufnr integer Buffer handle of the mailbox
---@param lnum integer 1-indexed line number
---@return Correo.Himalaya.Envelope|nil envelope Envelope on that line, if any
M.get_envelope_at = function(bufnr, lnum)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  local _state = State[bufnr]
  return _state and _state.envelopes[lnum] or nil
end

return M
