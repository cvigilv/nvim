---@module 'carlos.helpers.colors'
---@author Carlos Vigil-Vásquez
---@license MIT

local M = {}

--- Retrieves the color values of a specified highlight group.
-- @param hl_group string The name of the highlight group.
-- @return table|nil A table containing the color values of the highlight group, or nil if the
--                   group doesn't exist.
M.get_hlgroup_table = function(hl_group)
  -- Get highlight group colors
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = hl_group, link = true, create = false })
  if ok then
    ---@diagnostic disable-next-line: undefined-field
    hl = { fg = hl.fg or hl.guifg, bg = hl.bg or hl.guibg }
    return vim.tbl_map(function(e) return string.format("#%06x", e) end, hl)
  else
    vim.notify(
      "[ERROR] Highlight group `" .. hl_group .. "` doesn't exist!",
      vim.log.levels.ERROR
    )
    return nil
  end
end

--- Overrides highlight groups with the specified options.
-- @param hlgroups table Table containing highlight groups and their options.
M.override_hlgroups = function(hlgroups)
  for group, opts in pairs(hlgroups) do
    if opts ~= nil then vim.api.nvim_set_hl(0, group, opts) end
  end
end

---Modifies a highlight group with specified overrides.
---@param hlgroup string The name of the highlight group to modify
---@param overrides table A table of highlight attributes to override
M.modify_hlgroup = function(hlgroup, overrides)
  local ok, hldef =
    pcall(vim.api.nvim_get_hl, 0, { name = hlgroup, link = true, create = false })
  if ok then
    hldef = vim.tbl_deep_extend("force", hldef, overrides)
    vim.api.nvim_set_hl(0, hlgroup, hldef --[[@as table]])
  end
end

return M
