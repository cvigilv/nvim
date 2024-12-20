---@module "${lua-module-modname}"
---@author Carlos Vigil-Vásquez
---@license MIT ${year}

---@class ${lua-module-name}.Configuration
---@field field_name type description

--@type ${lua-module-name}.Configuration
local defaults = {}

local M = {}

--- Update defaults with user configuration
---@param opts ${lua-module-name}.Configuration User provided configuration table
---@return ${lua-module-name}.Configuration opts Updated default configuration table with user configuration
M.updateconfig = function(opts)
  -- Merge-in user configuration to default configuration
  opts = opts and vim.tbl_deep_extend("force", {}, defaults, opts) or defaults

  -- Validate setup
  vim.validate({
    -- NOTE: This is an example of how to validate the configuration table
    -- ["field"] = { opts.field, "type"},
    -- ["complex_field"] = { opts.complex_field, {"string", "type"}}
  })

  return opts
end

return M
