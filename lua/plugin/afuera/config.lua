---@module "plugin.afuera.config"
---@author Carlos Vigil-Vásquez
---@license MIT 2024

---@class Afuera.Configuration
---@field defaults Afuera.Defaults.Configuration Default states for out-of-bounds mode
---@field fix_colorscheme boolean Whether to fix some highlight groups to make them work with plugin
---@field oob_char_hl string Highlight group for characters out-of-bounds
---@field ignored_buftypes string[]
---@field ignored_filetypes string[]
---@field state? table Current state of plugin
---@field logging Afuera.Logging.Configuration Logging configuration

---@class Afuera.Defaults.Configuration
---@field state boolean Whether OOB mode should start when opening a new window
---@field colorcolumn string|nil Colorcolumn setting for when OOB mode is deactivated

---@class Afuera.Logging.Configuration
---@field enabled boolean Whether logging should be activated
---@field level string Any messages above this level will be logged
---@field highlights boolean Should highlighting be used in console (using echohl)
---@field use_console string|boolean Should print the output to neovim while running
---@field use_file boolean Should write to a file (found at `stdpath("cache")/afuera.nvim`)
---@field use_quickfix boolean Should write to the quickfix list

---@type Afuera.Configuration
local defaults = {
  fix_colorscheme = true,
  oob_char_hl = "Error",
  defaults = {
    state = true,
    colorcolumn = vim.api.nvim_get_option_value("colorcolumn", { scope = "local" }),
  },
  ignored_buftypes = {
    "acwrite",
    "help",
    "nofile",
    "nowrite",
    "quickfix",
    "terminal",
    "prompt",
  },
  ignored_filetypes = {},
  state = {},
  logging = {
    enabled = true,
    level = "trace",
    highlights = false,
    use_console = false,
    use_file = true,
    use_quickfix = false,
  },
}

local M = {}

--- Update defaults with user configuration
---@param opts Afuera.Configuration User provided configuration table
---@return Afuera.Configuration opts Updated default configuration table with user configuration
M.updateconfig = function(opts)
  -- Merge-in user configuration to default configuration
  opts = opts and vim.tbl_deep_extend("force", defaults, opts) or defaults

  -- Validate options
  vim.validate({
    ["defaults.state"] = { opts.defaults.state, "boolean" },
    ["defaults.colorcolumn"] = { opts.defaults.colorcolumn, { "string", nil } },
    ["ignored_buftypes"] = { opts.ignored_buftypes, "table" },
    ["ignored_filetypes"] = { opts.ignored_filetypes, "table" },
    ["state"] = { opts.state, "table" },
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
