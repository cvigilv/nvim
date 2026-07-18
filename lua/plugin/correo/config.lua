---@module "plugin.correo"
---@author Carlos Vigil-Vásquez
---@license MIT 2026

---@class Correo.Logging.Configuration
---@field enabled boolean Whether logging should be activated
---@field level string Any messages above this level will be logged
---@field highlights boolean Should highlighting be used in console (using echohl)
---@field use_console string|boolean Should print the output to neovim while running
---@field use_file boolean Should write to a file (found at `stdpath("cache")/correo.nvim`)
---@field use_quickfix boolean Should write to the quickfix list

---@class Correo.UI.Icons
---@field unread string Icon shown for unread envelopes
---@field flagged string Icon shown for flagged envelopes
---@field attachment string Icon shown for envelopes with attachments

---@class Correo.UI.Message.Configuration
---@field open "replace"|"split" How to open a message: replace the mailbox window, or open a
---horizontal split (20% mailbox / 80% message)

---@class Correo.UI.Configuration
---@field from_width integer Display width of the sender column
---@field icons Correo.UI.Icons Icons used in the mailbox listing
---@field message Correo.UI.Message.Configuration Message buffer behaviour

---@class Correo.Keymaps.Configuration
---@field refresh string Keymap to refresh the mailbox buffer
---@field open string Keymap to open the message under the cursor
---@field toggle_seen string Keymap to toggle the "Seen" flag (mailbox and message buffers)
---@field mark_unseen string Keymap to mark as unseen/unread (mailbox and message buffers)
---@field quit string Keymap to return from a message buffer to its mailbox
---@field archive string Keymap to stage/unstage archiving the envelope under the cursor
---@field move string Keymap to stage/unstage moving the envelope under the cursor
---@field reply string Keymap to reply (mailbox and message buffers)
---@field reply_all string Keymap to reply to all recipients (mailbox and message buffers)
---@field forward string Keymap to forward (mailbox and message buffers)

---@class Correo.Configuration
---@field binary string Name or path of the Himalaya executable
---@field account string|nil Account to use (nil → Himalaya's default account)
---@field folder string Folder opened by default
---@field archive_folder string Folder that "archive" moves messages to
---@field drafts_folder string Folder drafts are saved to ("drafts" resolves Himalaya's per-account alias)
---@field page_size integer Number of envelopes fetched per page
---@field ui Correo.UI.Configuration UI options
---@field keymaps Correo.Keymaps.Configuration Mailbox buffer keymaps
---@field logging Correo.Logging.Configuration Logging options

---@type Correo.Configuration
local defaults = {
  binary = "himalaya",
  account = nil,
  folder = "INBOX",
  archive_folder = "Archive",
  drafts_folder = "drafts",
  page_size = 100,
  ui = {
    from_width = 24,
    message = {
      open = "replace",
    },
    icons = {
      unread = "●",
      flagged = "⚑",
      attachment = "",
    },
  },
  keymaps = {
    refresh = "R",
    open = "<CR>",
    toggle_seen = "gs",
    mark_unseen = "gS",
    quit = "q",
    archive = "ga",
    move = "gm",
    reply = "gr",
    reply_all = "gR",
    forward = "gf",
  },
  logging = {
    enabled = true,
    level = "trace",
    highlights = true,
    use_console = false,
    use_file = false,
    use_quickfix = true,
  },
}

local M = {}

--- Update defaults with user configuration
---@param opts Correo.Configuration|nil User provided configuration table
---@return Correo.Configuration opts Updated default configuration table with user configuration
M.updateconfig = function(opts)
  -- Merge-in user configuration to default configuration
  opts = opts and vim.tbl_deep_extend("force", {}, defaults, opts) or defaults

  -- Validate setup
  vim.validate({
    ["binary"] = { opts.binary, "string" },
    ["account"] = { opts.account, "string", true },
    ["folder"] = { opts.folder, "string" },
    ["archive_folder"] = { opts.archive_folder, "string" },
    ["drafts_folder"] = { opts.drafts_folder, "string" },
    ["page_size"] = { opts.page_size, "number" },

    -- UI
    ["ui.from_width"] = { opts.ui.from_width, "number" },
    ["ui.message.open"] = {
      opts.ui.message.open,
      function(v) return v == "replace" or v == "split" end,
      '"replace" or "split"',
    },
    ["ui.icons.unread"] = { opts.ui.icons.unread, "string" },
    ["ui.icons.flagged"] = { opts.ui.icons.flagged, "string" },
    ["ui.icons.attachment"] = { opts.ui.icons.attachment, "string" },

    -- Keymaps
    ["keymaps.refresh"] = { opts.keymaps.refresh, "string" },
    ["keymaps.open"] = { opts.keymaps.open, "string" },
    ["keymaps.toggle_seen"] = { opts.keymaps.toggle_seen, "string" },
    ["keymaps.mark_unseen"] = { opts.keymaps.mark_unseen, "string" },
    ["keymaps.quit"] = { opts.keymaps.quit, "string" },
    ["keymaps.archive"] = { opts.keymaps.archive, "string" },
    ["keymaps.move"] = { opts.keymaps.move, "string" },
    ["keymaps.reply"] = { opts.keymaps.reply, "string" },
    ["keymaps.reply_all"] = { opts.keymaps.reply_all, "string" },
    ["keymaps.forward"] = { opts.keymaps.forward, "string" },

    -- Logging
    ["logging.enabled"] = { opts.logging.enabled, "boolean" },
    ["logging.level"] = { opts.logging.level, "string" },
    ["logging.highlights"] = { opts.logging.highlights, "boolean" },
    ["logging.use_console"] = { opts.logging.use_console, { "string", "boolean" } },
    ["logging.use_file"] = { opts.logging.use_file, "boolean" },
    ["logging.use_quickfix"] = { opts.logging.use_quickfix, "boolean" },
  })

  return opts
end

return M
