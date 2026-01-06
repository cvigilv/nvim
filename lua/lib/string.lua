---@module 'lib.string'
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local srep = string.rep

local M = {}

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
        matrix[i - 1][j] + 1, -- deletion
        matrix[i][j - 1] + 1, -- insertion
        matrix[i - 1][j - 1] + cost -- substitution
      )
    end
  end

  return matrix[m][n]
end

return M