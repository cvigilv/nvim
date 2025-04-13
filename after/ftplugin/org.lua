_G.carlos.org = {}


-- Contact management
require("plugin.org-contact").init()

-- Pretty statuscolumn gutter

local S = require("carlos.helpers.string")
local function asterisk_count(line_number, maxstars)
  maxstars = maxstars or 16
  -- Get the content of the specific line
  local line = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]

  if line then
    local asterisk_pattern = "^%*+ "
    local asterisks = line:match(asterisk_pattern)

    if asterisks then
      local count = #asterisks-1
        return "%#@org.headline.level"
          .. count
          .. "#"
          .. S.lpad(string.rep("*", count --[[@as number]]), maxstars, " ")
          .. "%#OrgStc#"
    end
  end

  return "    "
end


local function setup_asterisk_conceal()
  local ns_id = vim.api.nvim_create_namespace("asterisk_conceal")

  -- Clear existing syntax for this namespace
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)

  -- Function to add conceal
  local function add_conceal(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    for i, line in ipairs(lines) do
      local start, end_col = line:find("^%*+ ")
      if start then
        vim.api.nvim_buf_set_extmark(bufnr, ns_id, i - 1, start - 1, {
          end_col = end_col,
          conceal = "", -- or use a character like "●" instead of "" to replace asterisks
        })
      end
    end
  end

  -- Set conceal options
  vim.wo.conceallevel = 2
  vim.wo.concealcursor = "nc"

  -- Initial conceal
  add_conceal(0)

  -- Update conceal on buffer change
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    buffer = 0,
    callback = function()
      add_conceal(0)
    end,
  })
end

setup_asterisk_conceal()

local C = require("carlos.helpers.colors")

local normal = C.get_hlgroup_table("Normal") or "#ffffff"
local comment = C.get_hlgroup_table("Whitespace") or "#000000"

vim.cmd("hi! OrgStc guibg=" .. normal.bg .. " guifg=" .. comment.fg .. " gui=italic")

_G.carlos.org.statuscolumn = function()
  local components = {
    "%#OrgStc#",
    asterisk_count(vim.v.lnum, 16),
    " ",
  }

  return table.concat(components, "")
end

vim.api.nvim_set_option_value(
  "statuscolumn",
  "%{%v:lua.carlos.org.statuscolumn()%}",
  { scope = "local" }
)

vim.b.minihipatterns_disable=true
