-- Plugins
vim.b.miniindentscope_disable = true
vim.b.minihipatterns_disable = true

-- Options
_G.carlos.org = {}
vim.api.nvim_set_option_value("textwidth", 96, { scope = "local" })
vim.api.nvim_set_option_value("conceallevel", 2, { scope = "local" })

-- Keymaps
vim.keymap.set("n", ",sw", ":Writing<CR>", {desc = "Toggle writing mode"})
vim.keymap.set("n", ",sc", ":setlocal spell!<CR>", {desc = "Toggle spell checker"})

-- Extra
--- Status column
--- NOTE: the objective of this custom status line is so we can partially conceal the headings stars, such
--- that the stars are placed in the status column, making them stay aligned with the rest of the text.
local C = require("carlos.helpers.colors")
local S = require("carlos.helpers.string")
local max_stc_width = 12

local function asterisk_count(line_number, maxstars)
  maxstars = maxstars or max_stc_width
  -- Get the content of the specific line
  local line = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]

  if line then
    local asterisk_pattern = "^%*+ "
    local asterisks = line:match(asterisk_pattern)

    if asterisks then
      local count = #asterisks - 1
      return "%#@org.headline.level"
        .. count
        .. "#"
        .. S.lpad(string.rep("*", count --[[@as number]]), maxstars, " ")
        .. "%*"
    end
  end

  return string.rep(" ", max_stc_width)
end

---- Define status column custom highlight group
local normal = C.get_hlgroup_table("Normal") or { bg = "#ffffff" }
local comment = C.get_hlgroup_table("Comment") or { bg = "#000000" }
vim.cmd("hi! OrgStc guibg=" .. normal.bg .. " guifg=" .. comment.fg .. " gui=italic")

---- Set status column
_G.carlos.org.statuscolumn = function()
  local components = {
    " ",
    -- "%#OrgStc#",
    asterisk_count(vim.v.lnum, max_stc_width - 2),
    " ",
  }

  return table.concat(components, "")
end
vim.api.nvim_set_option_value(
  "statuscolumn",
  "%{%v:lua.carlos.org.statuscolumn()%}",
  { scope = "local" }
)

---- Conceal heading stars
local function conceal_heading_stars()
  local ns_id = vim.api.nvim_create_namespace("carlos::org::conceal_heading_stars")

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
end
conceal_heading_stars()

--- Writing mode
vim.b.carlos_writing_mode_enabled = false
local function center_window()
  -- Get the current window and buffer
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()

  -- Get the window width
  local win_width = vim.api.nvim_win_get_width(win)

  -- Get the statuscolumn width
  local statuscolumn_width = math.ceil(max_stc_width * 1.1)

  -- Get the textwidth or colorcolumn
  local text_width = vim.bo.textwidth
  if text_width == 0 then
    local colorcolumn = vim.wo.colorcolumn
    if colorcolumn ~= "" then
      text_width = tonumber(colorcolumn:match("%d+"))
    else
      text_width = 80 -- Default if neither textwidth nor colorcolumn is set
    end
  end

  -- Calculate the width of the center split
  local center_width = math.ceil((text_width + statuscolumn_width) * 1.1)

  -- Calculate the width of the side splits
  local side_width = math.floor((win_width - center_width) / 2)

  -- Create the left split
  vim.cmd(string.format("leftabove %dvnew", side_width))
  vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(false, true))

  -- Move back to the original window
  vim.api.nvim_set_current_win(win)

  -- Create the right split
  vim.cmd(string.format("rightbelow %dvnew", side_width))
  vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(false, true))

  -- Move back to the center window
  vim.api.nvim_set_current_win(win)

  -- -- Adjust the width of the center window if necessary
  local new_center_width = vim.api.nvim_win_get_width(win)
  if new_center_width > center_width then vim.api.nvim_win_set_width(win, center_width) end
end
local function enable_writing_mode(bufnr)
  center_window()
  vim.api.nvim_set_option_value("spell", true, { scope = "local" })
  vim.api.nvim_set_option_value("number", false, { scope = "local" })
  vim.api.nvim_set_option_value("relativenumber", false, { scope = "local" })
  vim.api.nvim_set_option_value("showtabline", 0, { scope = "local" })
  vim.api.nvim_set_option_value("laststatus", 0, { scope = "local" })
  vim.api.nvim_set_option_value("winbar", "", { scope = "global" })
  vim.api.nvim_set_option_value("statusline", "", { scope = "global" })
end
local function disable_writing_mode(bufnr)
  vim.cmd("only")
  vim.api.nvim_set_option_value("spell", false, { scope = "local" })
  vim.api.nvim_set_option_value("number", true, { scope = "local" })
  vim.api.nvim_set_option_value("relativenumber", true, { scope = "local" })
  vim.api.nvim_set_option_value("showtabline", 2, { scope = "local" })
  vim.api.nvim_set_option_value("laststatus", 2, { scope = "local" })
  vim.api.nvim_set_option_value("winbar", "%{%v:lua.carlos.winbar()%}", { scope = "global" })
  vim.api.nvim_set_option_value(
    "statusline",
    "%{%v:lua.carlos.statusline()%}",
    { scope = "global" }
  )
end
local function toggle_writing_mode(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if vim.b.carlos_writing_mode_enabled then
    disable_writing_mode(bufnr)
    print("Writing mode disabled!")
  elseif not vim.b.carlos_writing_mode_enabled then
    enable_writing_mode(bufnr)
    print("Writing mode enabled!")
  end
  vim.b.carlos_writing_mode_enabled = not vim.b.carlos_writing_mode_enabled
end
vim.api.nvim_create_user_command("Writing", toggle_writing_mode, {})
