-- Plugins
local cmp = require("cmp")
cmp.setup.filetype("markdown", {
  sources = cmp.config.sources({
    { name = "nvim_lsp", group_index = 1 },
  }),
})

-- Options
vim.opt_local.textwidth = 96

-- Keymaps
vim.keymap.set("n", ",sw", ":Writing<CR>", {desc = "Toggle writing mode"})
vim.keymap.set("n", ",sc", ":setlocal spell!<CR>", {desc = "Toggle spell checker"})

-- Extra
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

vim.api.nvim_creat_user_command("Writing", toggle_writing_mode, {})
