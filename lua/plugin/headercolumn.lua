---@module "plugin.headercolumn"
---@author Carlos Vigil-Vásquez
---@license MIT 2025
-- A small plugin to put header characters on the statuscolumn

local M = {}

---Pad string to left
---@param s string String to pad
---@param l number String length
---@param c string Character to pad with, defaults to space
local function lpad(s, l, c) return string.rep(c or " ", l - #s) .. s end

--- NOTE: the objective of this custom status line is so we can partially conceal the headings stars, such
--- that the stars are placed in the status column, making them stay aligned with the rest of the text.
local function asterisk_count(line_number, maxwidth)
  -- Get the content of the specific line
  local line = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]

  -- Check if line has header of any level
  if line then
    local asterisk_pattern = "^%*+ "
    local asterisks = line:match(asterisk_pattern)
    if asterisks then
      local count = #asterisks - 1
      return "%#@org.headline.level"
        .. count
        .. "#"
        .. lpad(string.rep("*", count --[[@as number]]), maxwidth, " ")
        .. "%*"
    end
  end
  return string.rep(" ", maxwidth)
end

function M.setup(width)
  local ns_id = vim.api.nvim_create_namespace("headercolumn")
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)

  local function add_conceal(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    for i, line in ipairs(lines) do
      local start, end_col = line:find("^%*+ ")
      if start then
        vim.api.nvim_buf_set_extmark(bufnr, ns_id, i - 1, start - 1, {
          end_col = end_col,
          conceal = "",
        })
      end
    end
  end

  -- Initial conceal
  add_conceal(0)

  -- Update conceal on buffer change
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    buffer = 0,
    callback = function() add_conceal(0) end,
  })

  _G.headercolumn_stc = function()
    local components = {
      " ",
      asterisk_count(vim.v.lnum, width - 2),
      " ",
    }

    return table.concat(components, "")
  end
  vim.api.nvim_set_option_value(
    "statuscolumn",
    "%{%v:lua.headercolumn_stc()%}",
    { scope = "local" }
  )
end

return M
