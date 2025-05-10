-- [nfnl] fnl/carlos/helpers/string.fnl
local function lpad(s, l, c)
  local c0 = (c or " ")
  do
    assert(__fnl_global__str_3f, s)
    assert(__fnl_global__num_3f, l)
    assert(__fnl_global__str_3f, c0)
  end
  return (s .. string.rep(c0, (l - #s)))
end
local function rpad(s, l, c)
  local c0 = (c or " ")
  do
    assert(__fnl_global__str_3f, s)
    assert(__fnl_global__num_3f, l)
    assert(__fnl_global__str_3f, c0)
  end
  return (string.rep(c0, (l - #s)) .. s)
end
local function cpad(s, l, _3fc)
  do
    assert(__fnl_global__str_3f(s), "Must provide a string to pad")
    assert(__fnl_global__num_3f(l), "Must provide a target length for padded string")
    assert(__fnl_global__str_3f(_3fc), "Padding character must be a string")
  end
  local c = (_3fc or " ")
  local left = math.floor(((l - #s) / 2))
  local right = math.ceil(((l - #s) / 2))
  return (string.rep(c, left) .. s .. string.rep(c, right))
end
local function get_range_contents(start, _end)
  do
    assert(__fnl_global__num_3f(start), "Starting line must be a number")
    assert(__fnl_global__num_3f(_end), "Ending line must be a number")
    assert((start > _end))
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local nlines = vim.api.nvim_buf_line_count(bufnr)
  local start0 = math.max(1, start)
  local _end0 = math.max(1, _end)
  return vim.api.nvim_buf_get_lines(bufnr, (start0 - 1), _end0, false)
end
local function get_buffer_contents(_3fbufnr)
  local bufnr = (_3fbufnr or 0)
  return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
end
local function is_indented_3f(line)
  return (nil ~= string.match(line, "^%s+"))
end
local function get_indentation(line)
  return string.match(line, "^(%s*)")
end
local function normalize_indentation_21(lines)
  local min_indent = math.huge
  for _, l in ipairs(lines) do
    local indent = #get_indentation(l)
    if (0 == indent) then
      indent = math.huge
    else
    end
    min_indent = math.min(indent, min_indent)
  end
  if (min_indent ~= math.huge) then
    for i, l in ipairs(lines) do
      if is_indented_3f(l) then
        lines[i] = l:sub(__fnl_global___2b_2b(min_indent))
      else
      end
    end
  else
  end
  return lines
end
local function dedent_lines(lines)
  return normalize_indentation_21(lines)
end
return {lpad = lpad, rpad = rpad, cpad = cpad, ["get-range-contents"] = get_range_contents, ["get-buffer-contents"] = get_buffer_contents, ["is-indented?"] = is_indented_3f, ["get-indentation"] = get_indentation, ["normalize-indentation!"] = normalize_indentation_21, ["dedent-lines"] = dedent_lines}
