-- [nfnl] fnl/macros.fnl
local function nil_3f(x)
  return (nil == x)
end
local function tbl_3f(x)
  return ("table" == type(x))
end
local function str_3f(x)
  return ("string" == type(x))
end
local function num_3f(x)
  return ("number" == type(x))
end
local function bool_3f(x)
  return ("boolean" == type(x))
end
local function fn_3f(x)
  return ("function" == type(x))
end
local function executable_3f(...)
  return (1 == vim.fn.executable(...))
end
return {["nil?"] = nil_3f, ["tbl?"] = tbl_3f, ["str?"] = str_3f, ["bool?"] = bool_3f, ["num?"] = num_3f, ["fn?"] = fn_3f, ["executable?"] = executable_3f}
