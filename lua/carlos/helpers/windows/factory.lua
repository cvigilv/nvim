---@module "carlos.helpers.windows.factory"
---@author Carlos Vigil-Vásquez
---@license MIT 2024

local M = {}

---@class UI.FloatingWindow.Opts
---@field height number|function|"auto"
---@field width number|function|"auto"
---@field border table|string
---@field title string|"auto"
---@field modifiable boolean
---@field win_opts table

---Creates a new floating window with the given contents and options.
---@param contents string|table The content to display in the floating window
---@param opts table Optional settings for the floating window
---@return number float_win Floating window number
---@return number float_buf Floating buffer number
function M.new_floating_win(contents, opts)
  local defaults = {
    height = function(editor_height) return editor_height - 8 end,
    width = function(editor_width) return math.max(96, math.ceil(editor_width * 0.45)) end,
    row = 3,
    col = -2,
    border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
    title = vim.fn.expand("%:t"),
    footer = "",
    modifiable = false,
    win_opts = {
      winblend = 5,
      colorcolumn = "",
      cursorline = false,
      wrap = true,
      linebreak = true,
    },
  }
  opts = opts or {}
  opts = vim.tbl_extend("force", defaults, opts)

  -- Get editor dimensions
  local editor = vim.api.nvim_list_uis()[1]

  -- Calculate position for the floating window
  local height = opts.height(editor.height)
  local width = opts.width(editor.width)
  local row = opts.row
  local col = opts.col < 1 and editor.width + opts.col or opts.col

  -- Create a new buffer for the floating window
  local float_buf = vim.api.nvim_create_buf(false, true)

  -- Set the content of the buffer
  if type(contents) == "string" then contents = vim.split(contents, "\n") end
  vim.api.nvim_buf_set_lines(float_buf, 0, -1, false, contents)

  -- Set buffer options
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = float_buf })
  vim.api.nvim_set_option_value("modifiable", false, { buf = float_buf })

  -- Configure floating window options
  local float_opts = {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = opts.border,
    anchor = "NE",
    title = " " .. opts.title .. " ",
    footer = opts.footer,
    footer_pos = "right",
  }

  -- Create the floating window and configure
  local float_win = vim.api.nvim_open_win(float_buf, false, float_opts)
  for opt, val in pairs(opts.win_opts) do
    vim.api.nvim_set_option_value(opt, val, { win = float_win })
  end

  local hl_overrides = {
    "Normal:CodeBlock",
    "FloatNormal:CodeBlock",
    "NormalFloat:CodeBlock",
    "FloatBorder:CodeBlock",
    "FloatTitle:CodeBlock",
    "FloatFooter:CodeBlock",
    "EndOfBuffer:CodeBlock",
  }
  vim.api.nvim_set_option_value(
    "winhighlight",
    table.concat(hl_overrides, ","),
    { win = float_win }
  )

  -- Set keymaps
  vim.api.nvim_buf_set_keymap(float_buf, "n", "q", ":q<CR>", { noremap = true, silent = true })

  -- Focus on floating window
  vim.api.nvim_set_current_win(float_win)

  return float_win, float_buf
end

return M
