---@module "plugin.denote-darwin.stats"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local Naming = require("denote.naming")

local M = {}

--- Count the number of times a value appear in a given Denote field
---@param field string
---@param split boolean? Whether to split the field values before counting
---@return table|nil counts Table with count or nil if denote.nvim is not setup
M.count_field_values = function(field, split)
  -- Get denote directory
  local dir = _G.denote.config.directory
  if dir == nil then
    error("[denote-darwin] denote.nvim not setup.")
    return nil
  end
  -- Get field counts
  local files = vim.fn.glob(dir .. "*", false, true, true)
  local counts = (
    vim
      .iter(files)
      :map(function(f) return f:gsub(dir, "") end)
      :map(function(f)
        local fields = nil
        if Naming.is_denote(f) then fields = Naming.parse_filename(f, split)[field] end
        return fields
      end)
      :filter(function(f) return f ~= { "" } and f ~= "" and f ~= nil end)
      :flatten(math.huge)
      :fold({}, function(acc, v)
        if acc[v] == nil then acc[v] = 0 end
        acc[v] = acc[v] + 1
        return acc
      end)
  )
  return counts
end

--- Plot counts table using ASCII characters
---@param counts table<string, number>
---@param max_cols number
---@param char string
---@return table<string> plot
M.counts_plot = function(counts, max_cols, char)
  max_cols = max_cols or 32
  char = char or "▒"

  -- Find longest key for alignment
  local max_key_len = 0
  local max_count = 0
  for k, v in pairs(counts) do
    if #k > max_key_len then max_key_len = #k end
    if v > max_count then max_count = v end
  end

  -- Determine if scaling is needed
  local scale = 1
  if max_count > max_cols then scale = max_cols / max_count end

  local bars = {}
  for k, v in pairs(counts) do
    local bar_len = math.max(1, math.floor(v * scale + 0.5))
    local bar = string.rep(char, bar_len)
    local key_str = string.format("%" .. max_key_len .. "s", k)
    table.insert(bars, string.format("%s %s %d", key_str, bar, v))
  end

  -- Sort lines by counts in decreasing order
  table.sort(
    bars,
    function(a, b)
      local bycount = tonumber(a:match(" (%d+)$")) > tonumber(b:match(" (%d+)$"))
      local byalphabet = a:match("^(%a+) %*") > b:match("^(%a+) %*")
      return bycount and byalphabet
    end
  )
  return bars
end

return M
