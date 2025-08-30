---@module 'carlos.helpers.string'
---@author Carlos Vigil-Vásquez
---@license MIT

local srep = string.rep

M = {}

---Pad string to left
---@param s string String to pad
---@param l number String length
---@param c string Character to pad with, defaults to space
M.lpad = function(s, l, c) return srep(c or " ", l - #s) .. s end

---Pad string to right
---@param s string String to pad
---@param l number String length
---@param c string Character to pad with, defaults to space
M.rpad = function(s, l, c) return s .. srep(c or " ", l - #s) end

---Pad string on both sides, centering with left justification
---@param s string String to pad
---@param l number String length
---@param c string Character to pad with, defaults to space
M.pad = function(s, l, c)
  c = c or " "
  local left = math.floor((l - #s) / 2)
  local right = math.ceil((l - #s) / 2)
  local res = srep(c, left) .. s .. srep(c, right)
  return res
end

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

---Compute Levenshtein edit distance between string
---@param s string
---@param t string
---@return integer dist
M.levenshtein = function(s, t)
    local m, n = #s, #t
    if m == 0 then return n end
    if n == 0 then return m end

    -- Initialize matrix
    local matrix = {}
    for i = 0, m do
        matrix[i] = {}
        matrix[i][0] = i
    end
    for j = 0, n do
        matrix[0][j] = j
    end

    -- Compute distances
    for i = 1, m do
        for j = 1, n do
            local cost = (s:sub(i, i) == t:sub(j, j)) and 0 or 1
            matrix[i][j] = math.min(
                matrix[i-1][j] + 1,      -- deletion
                matrix[i][j-1] + 1,      -- insertion
                matrix[i-1][j-1] + cost  -- substitution
            )
        end
    end

    return matrix[m][n]
end

return M
