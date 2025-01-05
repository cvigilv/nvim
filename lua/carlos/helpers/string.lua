---@module 'carlos.helpers.string'
---@author Carlos Vigil-Vásquez
---@license MIT

local srep = string.rep

M = {}

-- all of these functions return their result and a boolean
-- to notify the caller if the string was even changed

-- pad the left side
M.lpad = function(s, l, c)
  local res = srep(c or " ", l - #s) .. s

  return res
end

-- pad the right side
M.rpad = function(s, l, c)
  local res = s .. srep(c or " ", l - #s)

  return res
end

-- pad on both sides (centering with left justification)
M.pad = function(s, l, c)
  local left = math.floor((l - #s) / 2)
  local right = math.ceil((l - #s) / 2)
  local res = srep(c or " ", left) .. s .. srep(c or " ", right)

  return res
end

return M
