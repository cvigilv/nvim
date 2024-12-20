---@module "plugin.afuera.config"
---@author Carlos Vigil-Vásquez
---@license MIT 2024

---@class Afuera.Configuration
---@field defaults Afuera.Defaults.Configuration Default states for out-of-bounds mode
---@field state? table Current state of plugin

---@class Afuera.Defaults.Configuration
---@field state boolean Whether OOB mode should start when opening a new window
---@field colorcolumn string|nil Colorcolumn setting for when OOB mode is deactivated

--@type Plugin.Configuration
local defaults = {
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
}

local M = {}

--- Update defaults with user configuration
---@param opts Afuera.Configuration User provided configuration table
---@return Afuera.Configuration opts Updated default configuration table with user configuration
M.updateconfig = function(opts)
  -- Merge-in user configuration to default configuration
  opts = opts and vim.tbl_deep_extend("force", {}, defaults, opts) or defaults

  -- Validate setup
  vim.validate({
    ["defaults.state"] = { opts.defaults.state, "boolean" },
    ["defaults.colorcolumn"] = { opts.defaults.colorcolumn, { "string", nil } },
  })

  return opts
end

return M
