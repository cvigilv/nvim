---@module "plugin.correo.help"
---@author Carlos Vigil-Vásquez
---@license MIT 2026

-- `g?` help overlay: a small floating window listing the keymaps that apply
-- to the current buffer kind, resolved live from the user's configuration.

local M = {}

-- Keymap descriptions per buffer kind; first field is the `keymaps` config key
local SECTIONS = {
  mailbox = {
    { "open", "open message under cursor (in drafts: edit draft)" },
    { "refresh", "reload default view (unfiltered, page 1)" },
    { "toggle_seen", "toggle seen flag" },
    { "mark_unseen", "mark as unseen" },
    { "archive", "stage/unstage archive" },
    { "move", "stage/unstage move to folder" },
    { "reply", "reply" },
    { "reply_all", "reply to all" },
    { "forward", "forward" },
    { "next_page", "next page" },
    { "prev_page", "previous page" },
    { "select_folder", "pick and open folder" },
    { "select_account", "pick and open account" },
    { "help", "show this help" },
  },
  message = {
    { "quit", "back to mailbox" },
    { "toggle_seen", "toggle seen flag" },
    { "mark_unseen", "mark as unseen" },
    { "reply", "reply" },
    { "reply_all", "reply to all" },
    { "forward", "forward" },
    { "help", "show this help" },
  },
}

-- Extra non-keymap hints appended per buffer kind
local FOOTERS = {
  mailbox = {
    "",
    "  dd     stage deletion (u to unstage)",
    "  :w     commit staged operations (with confirmation)",
  },
  message = {},
}

--- Build the help lines for a buffer kind from the live keymap configuration
---@param kind "mailbox"|"message" Buffer kind
---@return string[] lines Renderable help lines
local build_lines = function(kind)
  local _keymaps = vim.g.correo.opts.keymaps
  local _lines = { (" correo · %s"):format(kind), "" }
  for _, _entry in ipairs(SECTIONS[kind]) do
    table.insert(_lines, ("  %-6s %s"):format(_keymaps[_entry[1]] or "?", _entry[2]))
  end
  vim.list_extend(_lines, FOOTERS[kind])
  return _lines
end

--- Show the keymap help for a buffer kind in a floating window
---@param kind "mailbox"|"message" Buffer kind to document
M.show = function(kind)
  local _lines = build_lines(kind)
  local _width = 0
  for _, _line in ipairs(_lines) do
    _width = math.max(_width, vim.fn.strdisplaywidth(_line))
  end

  local _bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(_bufnr, 0, -1, false, _lines)
  vim.bo[_bufnr].modifiable = false
  vim.bo[_bufnr].bufhidden = "wipe"

  local _win = vim.api.nvim_open_win(_bufnr, true, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = _width + 2,
    height = #_lines,
    style = "minimal",
    border = "rounded",
    title = " g? ",
  })
  vim.wo[_win].winhighlight = "Normal:NormalFloat"

  -- Any of q/<Esc>/g? dismisses the overlay
  for _, _lhs in ipairs({ "q", "<Esc>", "g?" }) do
    vim.keymap.set("n", _lhs, function()
      if vim.api.nvim_win_is_valid(_win) then vim.api.nvim_win_close(_win, true) end
    end, { buffer = _bufnr, desc = "correo: close help" })
  end
end

return M
