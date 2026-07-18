---@module "plugin.correo.render"
---@author Carlos Vigil-Vásquez
---@license MIT 2026

-- Pure formatting: turn a Himalaya envelope into a buffer line plus highlight
-- spans. No buffer manipulation happens here, `mailbox.lua` applies the spans.

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

--- Render an envelope as a single mailbox line with highlight spans
---@param envelope Correo.Himalaya.Envelope Envelope to render
---@param ui Correo.UI.Configuration UI options (column widths, icons)
---@return Correo.Render.Line line Renderable line
M.render_envelope = function(envelope, ui)
  local _seen = vim.tbl_contains(envelope.flags, "Seen")
  local _flagged = vim.tbl_contains(envelope.flags, "Flagged")
  local _from = envelope.from.name or envelope.from.addr or "?"
  local _subject = envelope.subject ~= "" and envelope.subject or "(no subject)"

  -- Column layout: status icons | date | sender | subject
  local _pieces = {
    { fit(_seen and " " or ui.icons.unread, 2), "CorreoUnread" },
    { fit(_flagged and ui.icons.flagged or " ", 2), "CorreoFlagged" },
    { fit(envelope.has_attachment and ui.icons.attachment or " ", 2), "CorreoAttachment" },
    { fit(format_date(envelope.date), 8), "CorreoDate" },
    { fit(_from, ui.from_width) .. "  ", "CorreoFrom" },
    { _subject, _seen and "CorreoSubject" or "CorreoSubjectUnread" },
  }

  -- Concatenate pieces while tracking byte offsets for the highlight spans
  local _text, _spans, _col = "", {}, 0
  for _, _piece in ipairs(_pieces) do
    table.insert(_spans, { hl = _piece[2], first = _col, last = _col + #_piece[1] })
    _text = _text .. _piece[1]
    _col = _col + #_piece[1]
  end

  return { text = _text, spans = _spans }
end

return M
