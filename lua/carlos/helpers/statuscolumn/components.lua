---@module 'carlos.helpers.statuscolumn.components'
---@author Carlos Vigil-Vásquez
---@license MIT 2024-2025

---Filters and formats signs based on a condition and highlighting preference.
---@param signs table Array of sign data
---@param condition function|nil Optional function to filter signs
---@param highlighted boolean|nil Whether to return highlighted sign text (default: true)
---@return string sign Formatted sign text or empty space
local get_filtered_signs = function(signs, condition, highlighted)
  if highlighted == nil then highlighted = true end

  local cond = function(data)
    if condition ~= nil then return condition(data) end
    return true
  end

  for _, sign in ipairs(signs) do
    local data = sign[4]
    if data and data.sign_hl_group and cond(data) and highlighted then
      local current_line = vim.v.relnum == 0
      return "%#"
        .. data.sign_hl_group
        .. (current_line and "Current" or "Gutter")
        .. "#"
        .. data.sign_text
        .. "%*"
    end
    if data and data.sign_hl_group and cond(data) and not highlighted then
      return data.sign_text
    end
  end

  return "  "
end

M = {}

---Determines the fold indicator for a given line number.
---@param lnum number The line number to check for folding
---@return string sign The fold indicator character
M.fold = function(lnum)
  ---@diagnostic disable-next-line: undefined-field
  local fcs = vim.opt.fillchars:get()
  if vim.fn.foldlevel(lnum) <= vim.fn.foldlevel(lnum - 1) then return " " end
  return (vim.fn.foldclosed(lnum) == -1 and fcs.foldopen or fcs.foldclose) .. ""
end

---Git-related signs component
---@param signs table A table of signs to be filtered
---@return string sign A table containing only Git-related signs
M.git = function(signs)
  return get_filtered_signs(
    signs,
    function(data) return data.sign_hl_group:find("GitSigns") end
  )
end

---Other signs component
---@param signs table A table of signs to be filtered
---@return string sign A table containing only Git-related signs
M.other = function(signs, group)
  return get_filtered_signs(
    signs,
    function(data) return not data.sign_hl_group:find(group) end,
    false
  )
end

---Line numbering component
---@return string component Smart line numbering
M.linenumber = function() return "%{v:relnum?v:relnum:v:lnum}" end

return M
