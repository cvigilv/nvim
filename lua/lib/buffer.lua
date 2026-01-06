---@module 'lib.buffer'
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local M = {}

---Retrieves the contents of a specified range of lines from the current buffer
---@param start_line number The starting line number of the range
---@param end_line number The ending line number of the range
---@return string[]|nil contents The contents of the specified range
M.get_range_contents = function(start_line, end_line)
  -- Validate input
  start_line = tonumber(start_line) --[[@as number]]
  end_line = tonumber(end_line) --[[@as number]]
  if not start_line or not end_line then
    vim.notify(
      "Both start_line and end_line must be numbers, returning empty string.",
      vim.log.levels.ERROR
    )
    return nil
  end
  -- Get the lines from the buffer
  local bufnr = vim.api.nvim_get_current_buf()
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  start_line = math.max(1, start_line)
  end_line = math.min(end_line, line_count)
  if start_line > end_line then
    -- Swap start_line and end_line if they're in the wrong order
    start_line, end_line = end_line, start_line
  end
  return vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
end

---Gets the contents of the current buffer as a single string
---@return string[] contents The contents of the current buffer
M.get_buffer_contents = function()
  -- Concatenate all lines of the current buffer (0) from start (0) to end (-1)
  -- with newline characters ("\n") as separators
  return vim.api.nvim_buf_get_lines(0, 0, -1, false)
end

---Dedent array of lines based on minimum common indentation
---@param lines string[] Array of lines to detent
---@return string[] dedented_lines Dedented array of lines to detent
M.dedent_lines = function(lines)
  -- Find the minimum indentation
  local min_indent = math.huge
  for _, line in ipairs(lines) do
    -- Skip empty lines
    if line:match("%S") then
      local indent = line:match("^%s*"):len()
      min_indent = math.min(min_indent, indent)
    end
  end

  -- If no indentation found, return the original lines
  if min_indent == math.huge then return lines end

  -- Remove the common indentation from each line
  local dedented = {}
  for _, line in ipairs(lines) do
    if line:match("%S") then
      table.insert(dedented, line:sub(min_indent + 1))
    else
      table.insert(dedented, line)
    end
  end

  return dedented
end

return M