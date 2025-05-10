local M = {}

-- Get all floating windows
local function get_float_wins()
  local float_wins = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then
      table.insert(float_wins, {
        id = win,
        row = config.row,
        col = config.col,
        width = vim.api.nvim_win_get_width(win),
        height = vim.api.nvim_win_get_height(win)
      })
    end
  end
  return float_wins
end

-- Get current window position
local function get_current_position()
  local curr_win = vim.api.nvim_get_current_win()
  local config = vim.api.nvim_win_get_config(curr_win)
  
  -- If current window is floating
  if config.relative ~= "" then
    return {
      row = config.row,
      col = config.col,
      width = vim.api.nvim_win_get_width(curr_win),
      height = vim.api.nvim_win_get_height(curr_win),
      is_float = true
    }
  else
    -- For normal windows, use window position
    local curr_win_pos = vim.api.nvim_win_get_position(curr_win)
    return {
      row = curr_win_pos[1],
      col = curr_win_pos[2],
      width = vim.api.nvim_win_get_width(curr_win),
      height = vim.api.nvim_win_get_height(curr_win),
      is_float = false
    }
  end
end

-- Find the closest floating window in a direction
local function find_closest_float(direction)
  local curr_pos = get_current_position()
  local floats = get_float_wins()
  
  if #floats == 0 then
    return nil
  end
  
  local curr_win = vim.api.nvim_get_current_win()
  local closest_win = nil
  local closest_dist = math.huge
  
  -- Calculate center points
  local curr_center_row = curr_pos.row + curr_pos.height / 2
  local curr_center_col = curr_pos.col + curr_pos.width / 2
  
  for _, float in ipairs(floats) do
    if float.id ~= curr_win then
      local float_center_row = float.row + float.height / 2
      local float_center_col = float.col + float.width / 2
      
      -- Check if window is in the right direction
      local is_candidate = false
      if direction == "h" and float_center_col < curr_center_col then
        is_candidate = true
      elseif direction == "j" and float_center_row > curr_center_row then
        is_candidate = true
      elseif direction == "k" and float_center_row < curr_center_row then
        is_candidate = true
      elseif direction == "l" and float_center_col > curr_center_col then
        is_candidate = true
      end
      
      if is_candidate then
        -- Calculate distance (Euclidean)
        local dist = math.sqrt(
          (float_center_row - curr_center_row)^2 + 
          (float_center_col - curr_center_col)^2
        )
        
        if dist < closest_dist then
          closest_dist = dist
          closest_win = float.id
        end
      end
    end
  end
  
  return closest_win
end

-- Focus a floating window in the specified direction
function M.focus_float(direction)
  local target_win = find_closest_float(direction)
  
  if target_win then
    vim.api.nvim_set_current_win(target_win)
    return true
  else
    -- If no floating window found, use the default navigation
    vim.cmd("wincmd " .. direction)
    return false
  end
end

-- Set up mappings
function M.setup()
  for _, dir in ipairs({"h", "j", "k", "l"}) do
    vim.keymap.set("n", "<C-w>" .. dir, function()
      M.focus_float(dir)
    end, { noremap = true, silent = true })
  end
end

-- return M
