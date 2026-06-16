---@module "plugin.escritura"
---@author Carlos Vigil-Vásquez
---@license MIT 2025
-- A small plugin to toggle a distraction-free, centered writing mode

local M = {}

---Center the current window by padding it with empty side splits
---@param max_stc_width number Maximum statuscolumn width
local function center_window(max_stc_width)
  -- Get the current window and buffer
  local win = vim.api.nvim_get_current_win()

  -- Get the window width
  local win_width = vim.api.nvim_win_get_width(win)

  -- Get the statuscolumn width
  local statuscolumn_width = math.ceil(max_stc_width * 1.1)

  -- Get the textwidth or colorcolumn
  local text_width = vim.bo.textwidth
  if text_width == 0 then
    local colorcolumn = vim.wo.colorcolumn
    if colorcolumn ~= "" then
      text_width = tonumber(colorcolumn:match("%d+")) --[[@as integer]]
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

local function enable_writing_mode(max_stc_width)
  center_window(max_stc_width)
  vim.api.nvim_set_option_value("spell", true, { scope = "local" })
  vim.api.nvim_set_option_value("number", false, { scope = "local" })
  vim.api.nvim_set_option_value("relativenumber", false, { scope = "local" })
  vim.api.nvim_set_option_value("showtabline", 0, { scope = "local" })
  vim.api.nvim_set_option_value("laststatus", 0, { scope = "local" })
  vim.api.nvim_set_option_value("winbar", "", { scope = "global" })
  vim.api.nvim_set_option_value("statusline", "", { scope = "global" })
end

local function disable_writing_mode()
  vim.cmd("only")
  vim.api.nvim_set_option_value("spell", false, { scope = "local" })
  vim.api.nvim_set_option_value("number", true, { scope = "local" })
  vim.api.nvim_set_option_value("relativenumber", true, { scope = "local" })
  vim.api.nvim_set_option_value("showtabline", 2, { scope = "local" })
  vim.api.nvim_set_option_value("laststatus", 2, { scope = "local" })
end

---Set up writing mode for the current buffer
---@param max_stc_width number? Maximum statuscolumn width, defaults to 12
function M.setup(max_stc_width)
  max_stc_width = max_stc_width or 12

  vim.b.carlos_writing_mode_enabled = false

  local function toggle_writing_mode()
    if vim.b.carlos_writing_mode_enabled then
      disable_writing_mode()
    else
      enable_writing_mode(max_stc_width)
    end
    vim.b.carlos_writing_mode_enabled = not vim.b.carlos_writing_mode_enabled
  end

  vim.api.nvim_buf_create_user_command(0, "Escritura", toggle_writing_mode, {})
end

return M
