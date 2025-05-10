-- [nfnl] fnl/carlos/helpers/tables.fnl
local function counter(tbl)
  local counts = {}
  for _, v in ipairs(tbl) do
    local vcount = (counts[tostring(v)] or 0)
    counts[tostring(v)] = (vcount + 1)
    counts = counts
  end
  return counts
end
local function reverse(tbl)
  local rev = {}
  for k, v in pairs(tbl) do
    rev[v] = k
    rev = rev
  end
  return rev
end
return {counter = counter, reverse = reverse}
