-- Group for our autocmds
local augroup = vim.api.nvim_create_augroup("SlidingWindow", { clear = true })

local function slide_up(height)
  -- Get current window information
  local current_win = vim.api.nvim_get_current_win()
  local win_width = vim.api.nvim_win_get_width(current_win)
  local win_height = vim.api.nvim_win_get_height(current_win)

  -- Animation params
  local max_height = height or math.floor(win_height * 0.5)
  local min_height = 4
  local animation_ms = 150
  local steps = 25
  local step_ms = math.floor(animation_ms / steps)
  local width = win_width - 8

  -- Create buffer and window
  local buf = vim.api.nvim_create_buf(false, true)
  local sliding_win = vim.api.nvim_open_win(buf, false, {
    relative = "win",
    win = current_win,
    border = { "┌", "─", "┐", "│", "", "", "", "│" },
    focusable = true,
    col = 4,
    row = win_height - min_height - 2,
    height = min_height,
    width = width,
  })

  -- Set winhighlight without overriding previous settings
  vim.api.nvim_set_option_value(
    "winhighlight",
    vim.api.nvim_get_option_value("winhighlight", { win = sliding_win }) ~= ""
        and vim.api.nvim_get_option_value("winhighlight", { win = sliding_win }) .. ",FloatBorder:SlidingBorder"
      or "FloatBorder:SlidingBorder",
    { win = sliding_win }
  )

  -- Animate the window height
  local function animate_height(start_height, end_height)
    local height_diff = end_height - start_height
    local current_height = start_height
    local step_height = height_diff / steps

    for i = 1, steps do
      vim.defer_fn(function()
        if not vim.api.nvim_win_is_valid(sliding_win) then return end
        current_height = current_height + step_height
        vim.api.nvim_win_set_config(sliding_win, {
          relative = "win",
          win = current_win,
          height = math.floor(current_height),
          row = win_height - math.floor(current_height) - 1,
          col = 4,
        })
      end, i * step_ms)
    end
  end

  -- WinEnter animation (expand)
  vim.api.nvim_create_autocmd("WinEnter", {
    group = augroup,
    callback = function()
      if vim.api.nvim_get_current_win() == sliding_win then
        animate_height(min_height, max_height)
      end
    end,
  })

  -- WinLeave animation (shrink)
  vim.api.nvim_create_autocmd("WinLeave", {
    group = augroup,
    callback = function()
      if vim.api.nvim_get_current_win() == sliding_win then
        animate_height(max_height, min_height)
      end
    end,
  })

  return sliding_win
end
local function slide_down(height)
  -- Get current window information
  local current_win = vim.api.nvim_get_current_win()
  local win_width = vim.api.nvim_win_get_width(current_win)
  local win_height = vim.api.nvim_win_get_height(current_win)

  -- Animation params
  local max_height = height or math.floor(win_height * 0.5)
  local min_height = 4
  local animation_ms = 150
  local steps = 25
  local step_ms = math.floor(animation_ms / steps)
  local width = win_width - 8

  -- Create buffer and window
  local buf = vim.api.nvim_create_buf(false, true)
  local sliding_win = vim.api.nvim_open_win(buf, false, {
    relative = "win",
    win = current_win,
    border = { "", "", "", "│", "┘", "─", "└", "│" },
    focusable = true,
    col = 4,
    row = 0,
    height = min_height,
    width = width,
  })

  vim.api.nvim_set_option_value(
    "winhighlight",
    vim.api.nvim_get_option_value("winhighlight", { win = sliding_win }) ~= ""
        and vim.api.nvim_get_option_value("winhighlight", { win = sliding_win }) .. ",FloatBorder:SlidingBorder"
      or "FloatBorder:SlidingBorder",
    { win = sliding_win }
  )

  -- Animate the window height
  local function animate_height(start_height, end_height)
    local height_diff = end_height - start_height
    local current_height = start_height
    local step_height = height_diff / steps

    for i = 1, steps do
      vim.defer_fn(function()
        if not vim.api.nvim_win_is_valid(sliding_win) then return end
        current_height = current_height + step_height
        vim.api.nvim_win_set_config(sliding_win, {
          relative = "win",
          win = current_win,
          height = math.floor(current_height),
          row = 0,
          col = 4,
        })
      end, i * step_ms)
    end
  end

  -- WinEnter animation (expand)
  vim.api.nvim_create_autocmd("WinEnter", {
    group = augroup,
    callback = function()
      if vim.api.nvim_get_current_win() == sliding_win then
        animate_height(min_height, max_height)
      end
    end,
  })

  -- WinLeave animation (shrink)
  vim.api.nvim_create_autocmd("WinLeave", {
    group = augroup,
    callback = function()
      if vim.api.nvim_get_current_win() == sliding_win then
        animate_height(max_height, min_height)
      end
    end,
  })
  return sliding_win
end
local function slide_right(width)
  -- Get current window information
  local current_win = vim.api.nvim_get_current_win()
  local win_height = vim.api.nvim_win_get_height(current_win)

  -- Animation params
  local max_width = width or 96
  local min_width = 4
  local animation_ms = 150
  local steps = 25
  local step_ms = math.floor(animation_ms / steps)
  local height = win_height - 4

  -- Create buffer and window
  local buf = vim.api.nvim_create_buf(false, true)
  local sliding_win = vim.api.nvim_open_win(buf, false, {
    relative = "win",
    win = current_win,
    border = { "─", "─", "┐", "│", "┘", "─", "─", "" },
    focusable = true,
    col = 0,
    row = 1,
    height = height,
    width = min_width,
  })

  vim.api.nvim_set_option_value(
    "winhighlight",
    vim.api.nvim_get_option_value("winhighlight", { win = sliding_win }) ~= ""
        and vim.api.nvim_get_option_value("winhighlight", { win = sliding_win }) .. ",FloatBorder:SlidingBorder"
      or "FloatBorder:SlidingBorder",
    { win = sliding_win }
  )

  -- Animate the window width
  local function animate_width(start_width, end_width)
    local width_diff = end_width - start_width
    local current_width = start_width
    local step_width = width_diff / steps

    for i = 1, steps do
      vim.defer_fn(function()
        if not vim.api.nvim_win_is_valid(sliding_win) then
          return
        end
        current_width = current_width + step_width
        vim.api.nvim_win_set_config(sliding_win, {
          relative = "win",
          win = current_win,
          height = height,
          width = math.floor(current_width),
          row = 1,
          col = 0,
        })
      end, i * step_ms)
    end
  end

  -- WinEnter animation (expand)
  vim.api.nvim_create_autocmd("WinEnter", {
    group = augroup,
    callback = function()
      if vim.api.nvim_get_current_win() == sliding_win then
        animate_width(min_width, max_width)
      end
    end,
  })

  -- WinLeave animation (shrink)
  vim.api.nvim_create_autocmd("WinLeave", {
    group = augroup,
    callback = function()
      if vim.api.nvim_get_current_win() == sliding_win then
        animate_width(max_width, min_width)
      end
    end,
  })
  return sliding_win
end
local function slide_left(width)
  -- Get current window information
  local current_win = vim.api.nvim_get_current_win()
  local win_height = vim.api.nvim_win_get_height(current_win)
  local win_width = vim.api.nvim_win_get_width(current_win)

  -- Animation params
  local max_width = width or 96
  local min_width = 4
  local animation_ms = 150
  local steps = 25
  local step_ms = math.floor(animation_ms / steps)
  local height = win_height - 4

  -- Create buffer and window
  local buf = vim.api.nvim_create_buf(false, true)
  local sliding_win = vim.api.nvim_open_win(buf, false, {
    relative = "win",
    win = current_win,
    border = { "┌", "─", "─", "", "─", "─", "└", "│" },
    focusable = true,
    col = win_width-4,
    row = 1,
    height = height,
    width = min_width,
  })

  vim.api.nvim_set_option_value(
    "winhighlight",
    vim.api.nvim_get_option_value("winhighlight", { win = sliding_win }) ~= ""
        and vim.api.nvim_get_option_value("winhighlight", { win = sliding_win }) .. ",FloatBorder:SlidingBorder"
      or "FloatBorder:SlidingBorder",
    { win = sliding_win }
  )

  -- Animate the window width
  local function animate_width(start_width, end_width)
    local width_diff = end_width - start_width
    local current_width = start_width
    local step_width = width_diff / steps

    for i = 1, steps do
      vim.defer_fn(function()
        if not vim.api.nvim_win_is_valid(sliding_win) then
          return
        end
        current_width = current_width + step_width
        vim.api.nvim_win_set_config(sliding_win, {
          relative = "win",
          win = current_win,
          height = height,
          width = math.floor(current_width),
          row = 1,
          col = win_width-math.floor(current_width),
        })
      end, i * step_ms)
    end
  end

  -- WinEnter animation (expand)
  vim.api.nvim_create_autocmd("WinEnter", {
    group = augroup,
    callback = function()
      if vim.api.nvim_get_current_win() == sliding_win then
        animate_width(min_width, max_width)
      end
    end,
  })

  -- WinLeave animation (shrink)
  vim.api.nvim_create_autocmd("WinLeave", {
    group = augroup,
    callback = function()
      if vim.api.nvim_get_current_win() == sliding_win then
        animate_width(max_width, min_width)
      end
    end,
  })
  return sliding_win
end

vim.keymap.set("n", "<leader>C", function()
  local win = slide_up()
  vim.api.nvim_set_current_win(win)
  vim.cmd("CodeCompanionChat")
end)
vim.keymap.set("n", "<leader>t", function()
  local win = slide_up()
  vim.api.nvim_set_current_win(win)
  vim.cmd("term")
end)
vim.keymap.set("n", "<leader>T", function()
  local win = slide_down(12)
  vim.api.nvim_set_current_win(win)
  vim.cmd("term htop")
end)

-- Add keymaps to open sliding windows for all directions
vim.keymap.set("n", "<leader>wj", function()
  vim.api.nvim_set_current_win(slide_up())
  vim.defer_fn(function() vim.fn.feedkeys(":") end, 250)
end)
vim.keymap.set("n", "<leader>wk", function()
  vim.api.nvim_set_current_win(slide_down())
  vim.defer_fn(function() vim.fn.feedkeys(":") end, 250)
end)
vim.keymap.set("n", "<leader>wh", function()
  vim.api.nvim_set_current_win(slide_right())
  vim.defer_fn(function() vim.fn.feedkeys(":") end, 250)
end)
vim.keymap.set("n", "<leader>wl", function()
  vim.api.nvim_set_current_win(slide_left())
  vim.defer_fn(function() vim.fn.feedkeys(":") end, 250)
end)
