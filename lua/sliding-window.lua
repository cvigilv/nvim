vim.keymap.set("n", ",,f", function()
  -- Get current window information
  local current_win = vim.api.nvim_get_current_win()
  local win_width = vim.api.nvim_win_get_width(current_win)
  local win_height = vim.api.nvim_win_get_height(current_win)

  -- Animation params
  local max_height = 16
  local min_height = 4
  local animation_ms = 150
  local steps = 10
  local step_ms = math.floor(animation_ms / steps)
  local width = win_width - 8

  -- Create buffer and window
  local buf = vim.api.nvim_create_buf(false, true)
  local sliding_window = vim.api.nvim_open_win(buf, false, {
    relative = "win",
    win = current_win,
    border = { "┌", "─", "┐", "│", "", "", "", "│" },
    focusable = true,
    col = 4,
    row = win_height - min_height - 3,
    height = min_height,
    width = width,
  })

  -- Setup content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Type here..." })

  -- Group for our autocmds
  local augroup = vim.api.nvim_create_augroup("SlidingWindow", { clear = true })

  -- Animate the window height
  local function animate_height(start_height, end_height)
    local height_diff = end_height - start_height
    local current_height = start_height
    local step_height = height_diff / steps

    for i = 1, steps do
      vim.defer_fn(function()
        if not vim.api.nvim_win_is_valid(sliding_window) then
          return
        end
        current_height = current_height + step_height
        vim.api.nvim_win_set_config(sliding_window, {
          relative = "win",
          win = current_win,
          height = math.floor(current_height),
          row = win_height - math.floor(current_height) - 2,
          col = 4,
        })
      end, i * step_ms)
    end
  end

  -- WinEnter animation (expand)
  vim.api.nvim_create_autocmd("WinEnter", {
    group = augroup,
    callback = function()
      if vim.api.nvim_get_current_win() == sliding_window then
        animate_height(min_height, max_height)
      end
    end,
  })

  -- WinLeave animation (shrink)
  vim.api.nvim_create_autocmd("WinLeave", {
    group = augroup,
    callback = function()
      if vim.api.nvim_get_current_win() == sliding_window then
        animate_height(max_height, min_height)
      end
    end,
  })

  -- Clean up when the window is closed
  vim.api.nvim_create_autocmd("WinClosed", {
    group = augroup,
    pattern = tostring(sliding_window),
    callback = function()
      vim.api.nvim_del_augroup_by_id(augroup)
    end,
    once = true,
  })

  -- Focus the window to trigger initial animation
  vim.api.nvim_set_current_win(sliding_window)
end)
