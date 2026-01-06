---@module 'lib.colors'
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local M = {}

--- Retrieves the color values of a specified highlight group.
---@param hl_group string The name of the highlight group
---@param entry string|nil Optional entry name to extract ("fg", "bg", "foreground", "background")
---@return table|string|nil A table containing color values, specific hex value, or nil if group doesn't exist
M.get_hlgroup_table = function(hl_group, entry)
  -- Fix invalid entry names
  if entry == "foreground" then
    entry = "fg"
  elseif entry == "background" then
    entry = "bg"
  end

  -- Get highlight group colors
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = hl_group, link = true, create = false })
  if ok then
    ---@diagnostic disable-next-line: undefined-field
    hl = { fg = hl.fg or hl.guifg, bg = hl.bg or hl.guibg }
    
    if entry ~= nil then
      -- Return specific entry as hex string
      if hl[entry] then
        return string.format("#%06x", hl[entry])
      else
        return nil
      end
    else
      -- Return full table with hex values
      return vim.tbl_map(function(e) return string.format("#%06x", e) end, hl)
    end
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

---Swap foreground and background hex values in highlight group color table
---@param color_table table Color table with fg and bg keys
---@return table swapped_color_table Swapped color table
M.swap_colors = function(color_table)
  if
    vim.tbl_contains(vim.tbl_keys(color_table), "fg")
    and vim.tbl_contains(vim.tbl_keys(color_table), "bg")
  then
    local swapped_color_table = vim.deepcopy(color_table)
    swapped_color_table["fg"] = color_table["bg"]
    swapped_color_table["bg"] = color_table["fg"]
    return swapped_color_table
  end

  -- Return original table if keys not found
  vim.notify("[ERROR] `fg` and `bg` not found in table, not swapping", vim.log.levels.ERROR)
  return color_table
end

---Link highlight groups using modern API
---@param links table<string,string> Table mapping highlight groups to their links
M.link_highlights = function(links)
  for target, source in pairs(links) do
    vim.api.nvim_set_hl(0, target, { link = source })
  end
end

return M
