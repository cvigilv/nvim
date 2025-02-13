local M = {}

--- Get the hexadecimal value for a given highlight group and entry.
---@param hl_group string NeoVim highlight group name
---@param entry string|nil Entry name to extract. Any of "foreground", "background", "fg" or "bg".
---@return table|string|nil Hexadecimal value of highlight group entry
M.get_hl_group_hex = function(hl_group, entry)
  -- Fix invalid entry names
  if entry == "foreground" then
    entry = "fg"
  elseif entry == "background" then
    entry = "bg"
  end

  -- Get highlight group colors
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = hl_group, link = true, create = false })
  if ok then
    if entry ~= nil then
      return string.format("#%06x", hl[entry])
    else
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

--- Swap foreground and background hex values in highlight group color table
---@param color_table table Color table
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

--- Override colorscheme highlight groups based on color table
---@param color_table table<string,table> Color group table
M.override_highlights = function(color_table)
  for k, v in pairs(color_table) do
    local hlstr = {}
    for g, hex in pairs(v) do
      table.insert(hlstr, g .. "=" .. hex)
    end
    vim.cmd("hi " .. k .. " " .. table.concat(hlstr, " "))
  end
end

--- Link colorscheme highlight groups in table
---@param links table<string,string> Link mapper
M.link_highlights = function(links)
  for k, v in pairs(links) do
    vim.cmd("hi! link " .. k .. " " .. v)
  end
end

return M
