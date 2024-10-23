---@module "zk.config"
---@author Carlos Vigil-Vásquez
---@license MIT 2024

---@class Zk.Config
---@field path string Directory of notes to use

---@type Zk.Config
local defaults = {
  path = os.getenv("ZETTELDIR") --[[@as string]],
  media = os.getenv("ZETTELDIR") .. "/meta/media" --[[@as string]],
}

local M = {}

--- Update default configuration table by merging with user's configuration table
---@param config Zk.Config|nil User configuration table
---@return Zk.Config
M.update_config = function(config)
  config = vim.tbl_deep_extend("force", defaults, config or {})
  vim.validate({ config = { config, "table", true } })

  -- Validate setup
  vim.validate({
    ["path"] = { config.path, "string" },
    ["media"] = { config.media, "string" },
  })

  return config
end

return M
