---@module "plugin.contacto.highlights"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local M = {}

local function get_hlgroup_bg(hl_group)
  -- Get highlight group information for current buffer (0)
  local ok, hl_info = pcall(vim.api.nvim_get_hl, 0, { name = hl_group })

  -- Return nil if highlight group doesn't exist or has no background
  if not ok or not hl_info or not hl_info.bg then return nil end
  local bg = hl_info.bg

  -- Convert to hex
  return string.format("#%06x", bg)
end

---@param opts Contacto.Configuration User provided configuration table
M.setup = function(opts)
  local logger = require("plugin.contacto.logging").new(opts.logging, true)

  logger.info("Setting contact highlight group as " .. opts.hlgroup)
  vim.fn.matchadd("@contacto.contact", [[@[a-zA-Z0-9][a-zA-Z0-9_.-]*]])
  vim.api.nvim_set_hl(0, "@contacto.contact", { link = opts.hlgroup })
  vim.api.nvim_set_hl(
    0,
    "@contacto.cap",
    { bg = get_hlgroup_bg("Normal"), fg = get_hlgroup_bg(opts.hlgroup) }
  )
  logger.info("Set up contact highlighting")
end

return M
