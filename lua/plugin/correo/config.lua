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

---@class Correo.Configuration
---@field field_name type description
---@field logging Correo.Logging.Configuration Logging options

--@type Correo.Configuration
local defaults = {
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
---@param opts Correo.Configuration User provided configuration table
---@return Correo.Configuration opts Updated default configuration table with user configuration
M.updateconfig = function(opts)
  -- Merge-in user configuration to default configuration
  opts = opts and vim.tbl_deep_extend("force", {}, defaults, opts) or defaults

  -- Validate setup
  vim.validate({
    -- ["field"] = { opts.field, "type"},
    -- ["complex_field"] = { opts.complex_field, {"string", "type"}}

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
