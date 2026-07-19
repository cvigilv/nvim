---@module "plugin.correo.render"
---@author Carlos Vigil-Vásquez
---@license MIT 2026

-- Pure formatting: turn a Himalaya envelope into a buffer line plus highlight
-- spans, driven by the statusline-style `ui.mailbox.format` string. No buffer
-- manipulation happens here, `mailbox.lua` applies the spans.

---@class Correo.Render.Span
---@field hl string Highlight group name
---@field first integer 0-indexed byte column where the span starts
---@field last integer 0-indexed byte column where the span ends (exclusive)

---@class Correo.Render.Line
---@field text string Full text of the buffer line
---@field spans Correo.Render.Span[] Highlight spans covering the line

local M = {}

--- Truncate (with ellipsis) or pad `text` to an exact display width
---@param text string Text to fit
---@param width integer Target display width in cells
---@return string fitted Text of exactly `width` display cells
local fit = function(text, width)
  while vim.fn.strdisplaywidth(text) > width do
    text = vim.fn.strcharpart(text, 0, vim.fn.strchars(text) - 2) .. "…"
  end
  return text .. (" "):rep(width - vim.fn.strdisplaywidth(text))
end

--- Format a Himalaya timestamp ("YYYY-MM-DD HH:MM+TZ") as a short date
---@param date string Timestamp as reported by Himalaya
---@return string formatted Short date (e.g. "17 Jul"), or the input if unparseable
local format_date = function(date)
  local _y, _m, _d = date:match("^(%d+)%-(%d+)%-(%d+)")
  if not _y then return date end
  local _time = os.time({ year = tonumber(_y), month = tonumber(_m), day = tonumber(_d), hour = 12 })
  return os.date("%d %b", _time) --[[@as string]]
end

--- Check whether an envelope carries a flag
---@param envelope Correo.Himalaya.Envelope Envelope to inspect
---@param flag string Flag name (e.g. "Seen")
---@return boolean has True if the flag is present
local has_flag = function(envelope, flag) return vim.tbl_contains(envelope.flags, flag) end

-- Format specifiers: each maps a `%x` token to { text, highlight-or-nil }
---@type table<string, fun(e: Correo.Himalaya.Envelope, ui: Correo.UI.Configuration): string, string|nil>
local SPECS = {
  u = function(e, ui) return fit(has_flag(e, "Seen") and " " or ui.icons.unread, 2), "CorreoUnread" end,
  F = function(e, ui) return fit(has_flag(e, "Flagged") and ui.icons.flagged or " ", 2), "CorreoFlagged" end,
  a = function(e, ui) return fit(e.has_attachment and ui.icons.attachment or " ", 2), "CorreoAttachment" end,
  d = function(e) return fit(format_date(e.date), 8), "CorreoDate" end,
  f = function(e, ui) return fit(e.from.name or e.from.addr or "?", ui.from_width), "CorreoFrom" end,
  s = function(e)
    local _subject = e.subject ~= "" and e.subject or "(no subject)"
    return _subject, has_flag(e, "Seen") and "CorreoSubject" or "CorreoSubjectUnread"
  end,
}

--- Expand a format string into text/highlight pieces for one envelope
---@param fmt string Statusline-style format (e.g. "%u%F%a%d%f  %s")
---@param envelope Correo.Himalaya.Envelope Envelope being rendered
---@param ui Correo.UI.Configuration UI options
---@return { [1]: string, [2]: string|nil }[] pieces Ordered { text, hl } chunks
local expand_format = function(fmt, envelope, ui)
  local _pieces, _i = {}, 1
  while _i <= #fmt do
    if fmt:sub(_i, _i) == "%" and _i < #fmt then
      local _key = fmt:sub(_i + 1, _i + 1)
      local _spec = SPECS[_key]
      if _spec then
        table.insert(_pieces, { _spec(envelope, ui) })
      else
        table.insert(_pieces, { _key, nil }) -- Unknown specifier: keep it literally
      end
      _i = _i + 2
    else
      -- Copy the literal run up to the next specifier verbatim
      local _next = fmt:find("%%", _i) or (#fmt + 1)
      table.insert(_pieces, { fmt:sub(_i, _next - 1), nil })
      _i = _next
    end
  end
  return _pieces
end

--- Normalize a subject for thread grouping (strip Re:/Fwd: prefixes, case-fold)
---@param subject string Raw subject
---@return string key Normalized grouping key ("" if the subject is empty)
local normalize_subject = function(subject)
  local _s = vim.trim(subject:lower())
  while true do
    local _stripped = _s:gsub("^re%s*:%s*", ""):gsub("^fwd?%s*:%s*", "")
    if _stripped == _s then break end
    _s = _stripped
  end
  return _s
end

---@class Correo.Render.Fold
---@field first integer 1-indexed first line of the thread
---@field last integer 1-indexed last line of the thread

--- Group envelopes into subject threads, keeping members adjacent
---
--- Input is assumed newest-first (Himalaya's listing order); the first
--- occurrence of a subject anchors its thread's position, so threads are
--- ordered by their newest member and members stay newest-first within.
--- Envelopes with an empty subject never group.
---@param envelopes Correo.Himalaya.Envelope[] Envelopes in listing order
---@return Correo.Himalaya.Envelope[] ordered Envelopes reordered by thread
---@return Correo.Render.Fold[] folds One range per multi-message thread
M.thread_envelopes = function(envelopes)
  local _groups, _order = {}, {}
  for _, _envelope in ipairs(envelopes) do
    local _key = normalize_subject(_envelope.subject)
    if _key == "" then _key = "\0" .. _envelope.id end -- Unmergeable unique key
    if _groups[_key] == nil then
      _groups[_key] = {}
      table.insert(_order, _key)
    end
    table.insert(_groups[_key], _envelope)
  end

  local _ordered, _folds, _lnum = {}, {}, 1
  for _, _key in ipairs(_order) do
    local _members = _groups[_key]
    vim.list_extend(_ordered, _members)
    if #_members > 1 then
      table.insert(_folds, { first = _lnum, last = _lnum + #_members - 1 })
    end
    _lnum = _lnum + #_members
  end
  return _ordered, _folds
end

--- Render an envelope as a single mailbox line with highlight spans
---@param envelope Correo.Himalaya.Envelope Envelope to render
---@param ui Correo.UI.Configuration UI options (format, column widths, icons)
---@return Correo.Render.Line line Renderable line
M.render_envelope = function(envelope, ui)
  -- Concatenate pieces while tracking byte offsets for the highlight spans
  local _text, _spans, _col = "", {}, 0
  for _, _piece in ipairs(expand_format(ui.mailbox.format, envelope, ui)) do
    if _piece[2] ~= nil then
      table.insert(_spans, { hl = _piece[2], first = _col, last = _col + #_piece[1] })
    end
    _text = _text .. _piece[1]
    _col = _col + #_piece[1]
  end
  return { text = _text, spans = _spans }
end

return M
