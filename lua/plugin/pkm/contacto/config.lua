---@module "plugin.pkm.contacto.config"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

---@class Contacto.Logging.Configuration
---@field enabled boolean Whether logging should be activated
---@field level string Any messages above this level will be logged
---@field highlights boolean Should highlighting be used in console (using echohl)
---@field use_console string|boolean Should print the output to neovim while running
---@field use_file boolean Should write to a file (found at `stdpath("cache")/afuera.nvim`)
---@field use_quickfix boolean Should write to the quickfix list

---@class Contacto.Configuration
---@field dbpath string Contacts JSON database path
---@field hlgroup string Highlight group to use for contacts highlighting
---@field logging Contacto.Logging.Configuration Logging options

---@type Contacto.Configuration
local defaults = {
  dbpath = vim.fn.stdpath("config") .. "/contacts.json",
  hlgroup = "DiagnosticVirtualTextHint",
  logging = {
    enabled = true,
    level = "trace",
    highlights = true,
    use_console = true,
    use_file = false,
    use_quickfix = false,
  },
}

local M = {}

--- Update defaults with user configuration
---@param opts Contacto.Configuration|nil User provided configuration table
---@return Contacto.Configuration opts Updated default configuration table with user configuration
M.update_config = function(opts)
  -- Merge-in user configuration to default configuration
  opts = opts and vim.tbl_deep_extend("force", {}, defaults, opts) or defaults

  -- Validate setup
  vim.validate({
    ["dbpath"] = { opts.dbpath, "string" },

    -- Logging
    ["logging.enabled"] = { opts.logging.enabled, "boolean" },
    ["logging.level"] = { opts.logging.level, "string" },
    ["logging.highlights"] = { opts.logging.highlights, "boolean" },
    ["logging.use_console"] = { opts.logging.use_console, { "string", "boolean" } },
    ["logging.use_file"] = { opts.logging.use_file, "boolean" },
    ["logging.use_quickfix"] = { opts.logging.use_quickfix, "boolean" },
  })

  -- Make opts globally available
  vim.g.contacto = {
    config = opts
  }

  return opts
end

return M
