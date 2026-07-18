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

---@class Correo.UI.Configuration
---@field from_width integer Display width of the sender column
---@field icons Correo.UI.Icons Icons used in the mailbox listing

---@class Correo.Keymaps.Configuration
---@field refresh string Keymap to refresh the mailbox buffer

---@class Correo.Configuration
---@field binary string Name or path of the Himalaya executable
---@field account string|nil Account to use (nil → Himalaya's default account)
---@field folder string Folder opened by default
---@field page_size integer Number of envelopes fetched per page
---@field ui Correo.UI.Configuration UI options
---@field keymaps Correo.Keymaps.Configuration Mailbox buffer keymaps
---@field logging Correo.Logging.Configuration Logging options

---@type Correo.Configuration
local defaults = {
  binary = "himalaya",
  account = nil,
  folder = "INBOX",
  page_size = 100,
  ui = {
    from_width = 24,
    icons = {
      unread = "●",
      flagged = "⚑",
      attachment = "",
    },
  },
  keymaps = {
    refresh = "R",
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
    ["page_size"] = { opts.page_size, "number" },

    -- UI
    ["ui.from_width"] = { opts.ui.from_width, "number" },
    ["ui.icons.unread"] = { opts.ui.icons.unread, "string" },
    ["ui.icons.flagged"] = { opts.ui.icons.flagged, "string" },
    ["ui.icons.attachment"] = { opts.ui.icons.attachment, "string" },

    -- Keymaps
    ["keymaps.refresh"] = { opts.keymaps.refresh, "string" },

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
