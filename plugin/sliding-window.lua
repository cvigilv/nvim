---@module 'plugin.sliding-window'
---@author Carlos Vigil-Vásquez
---@license MIT

-- Group for our autocmds
local augroup = vim.api.nvim_create_augroup("carlos.sliding-window", { clear = true })

-- Shared animation/sizing parameters
local config = {
  min = 4,
  animation_ms = 150,
  steps = 25,
  -- What to do with a sliding window when its parent window is closed:
  --   "close"   -> close the sliding window too
  --   "replace" -> promote the sliding window's buffer into the parent's spot
  --   "prompt"  -> ask which of the two to do
  on_parent_close = "close",
}

-- Registry of live sliding windows: [sliding_win] = { parent = <win> }
local sliding = {}

-- Built-in border presets, expanded to the 8-cell form expected below:
-- { top-left, top, top-right, right, bottom-right, bottom, bottom-left, left }
local PRESETS = {
  none = { "", "", "", "", "", "", "", "" },
  single = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
  double = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
  rounded = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
  solid = { " ", " ", " ", " ", " ", " ", " ", " " },
}

--- Expand `vim.o.winborder` into an 8-cell border table.
---@param spec string The value of `winborder` (preset name or comma-separated chars)
---@return string[] border The 8-cell border array
local function expand_border(spec)
  spec = (spec == nil or spec == "") and "none" or spec
  if spec:find(",", 1, true) then return vim.split(spec, ",", { plain = true }) end
  return PRESETS[spec] or PRESETS.single
end

--- Open one edge of a border by blanking it, so the sliding window looks anchored
--- to that edge of the parent window.
---@param border string[] The 8-cell border array
---@param edge "top"|"bottom"|"left"|"right" The edge to open
---@return string[] border A new border array with the requested edge opened
local function open_edge(border, edge)
  local b = vim.deepcopy(border)
  if edge == "bottom" then
    b[5], b[6], b[7] = "", "", "" -- bottom-right, bottom, bottom-left
  elseif edge == "top" then
    b[1], b[2], b[3] = "", "", "" -- top-left, top, top-right
  elseif edge == "left" then
    b[8] = "" -- drop the left edge, extend top/bottom into the corners
    b[1], b[7] = b[2], b[6]
  elseif edge == "right" then
    b[4] = "" -- drop the right edge, extend top/bottom into the corners
    b[3], b[5] = b[2], b[6]
  end
  return b
end

--- Merge `FloatBorder:SlidingBorder` into a window's winhighlight without
--- clobbering existing settings.
---@param win integer Window handle
local function set_winhighlight(win)
  local existing = vim.wo[win].winhighlight
  local value = existing ~= "" and existing .. ",FloatBorder:SlidingBorder"
    or "FloatBorder:SlidingBorder"
  vim.api.nvim_set_option_value("winhighlight", value, { win = win })
end

-- Per-direction specification. Each entry describes the open (anchored) edge, the
-- axis it animates along, the target size, the initial float config and the
-- per-step geometry. `ctx` carries the parent window handle and its dimensions.
local DIRECTIONS = {
  up = {
    open = "bottom",
    max = function(ctx, size) return size or math.floor(ctx.h * 0.5) end,
    initial = function(ctx)
      return { col = 4, row = ctx.h - ctx.min - 2, height = ctx.min, width = ctx.w - 8 }
    end,
    step = function(ctx, v) return { col = 4, row = ctx.h - v - 1, height = v } end,
  },
  down = {
    open = "top",
    max = function(ctx, size) return size or math.floor(ctx.h * 0.5) end,
    initial = function(ctx) return { col = 4, row = 0, height = ctx.min, width = ctx.w - 8 } end,
    step = function(_, v) return { col = 4, row = 0, height = v } end,
  },
  right = {
    open = "left",
    max = function(_, size) return size or 96 end,
    initial = function(ctx) return { col = 0, row = 1, height = ctx.h - 4, width = ctx.min } end,
    step = function(ctx, v) return { col = 0, row = 1, height = ctx.h - 4, width = v } end,
  },
  left = {
    open = "right",
    max = function(_, size) return size or 96 end,
    initial = function(ctx)
      return { col = ctx.w - 4, row = 1, height = ctx.h - 4, width = ctx.min }
    end,
    step = function(ctx, v) return { col = ctx.w - v, row = 1, height = ctx.h - 4, width = v } end,
  },
}

--- Animate a window from one size to another, calling `step_fn` to compute the
--- geometry at each frame.
---@param win integer Window handle to animate
---@param from number Starting size
---@param to number Ending size
---@param ctx table Context with the parent window and dimensions
---@param step_fn fun(ctx: table, value: integer): table Per-step geometry
local function animate(win, from, to, ctx, step_fn)
  local steps = config.steps
  local step_ms = math.floor(config.animation_ms / steps)
  local delta = (to - from) / steps
  local value, i = from, 0
  local timer = (vim.uv or vim.loop).new_timer()

  timer:start(
    step_ms,
    step_ms,
    vim.schedule_wrap(function()
      i = i + 1
      if not vim.api.nvim_win_is_valid(win) then
        timer:stop()
        timer:close()
        return
      end
      value = value + delta
      local cfg = step_fn(ctx, math.floor(value))
      cfg.relative, cfg.win = "win", ctx.win
      vim.api.nvim_win_set_config(win, cfg)
      if i >= steps then
        timer:stop()
        timer:close()
      end
    end)
  )
end

--- Promote a sliding window's buffer into a normal window in the parent's spot,
--- then close the float. Must run while `parent` is still valid (i.e. from inside
--- the `WinClosed` autocmd, before the parent is removed from the layout).
---@param win integer The sliding window handle
---@param parent integer The parent window being closed
local function replace_parent(win, parent)
  local buf = vim.api.nvim_win_get_buf(win)
  -- Split off the parent's area; once the parent closes the new window absorbs it.
  pcall(vim.api.nvim_open_win, buf, false, { win = parent, split = "above" })
  if vim.api.nvim_win_is_valid(win) then pcall(vim.api.nvim_win_close, win, true) end
end

--- React to a sliding window's parent being closed, per `config.on_parent_close`.
---@param win integer The sliding window handle
---@param parent integer The parent window being closed
local function handle_parent_close(win, parent)
  sliding[win] = nil
  if not vim.api.nvim_win_is_valid(win) then return end

  local action = config.on_parent_close
  if action == "prompt" then
    -- Synchronous so we can still grab the parent's spot for "replace".
    action = vim.fn.confirm("Sliding window's parent closed.", "&Close\n&Replace", 1) == 2
        and "replace"
      or "close"
  end

  if action == "replace" then
    replace_parent(win, parent)
  else
    pcall(vim.api.nvim_win_close, win, true)
  end
end

-- Expand a sliding window on enter, shrink it on leave. One autocmd each, driven
-- by the registry, instead of a fresh pair per `slide()` call.
vim.api.nvim_create_autocmd("WinEnter", {
  group = augroup,
  callback = function()
    local win = vim.api.nvim_get_current_win()
    local info = sliding[win]
    if info then animate(win, config.min, info.max, info.ctx, info.step) end
  end,
})
vim.api.nvim_create_autocmd("WinLeave", {
  group = augroup,
  callback = function()
    local win = vim.api.nvim_get_current_win()
    local info = sliding[win]
    if info then animate(win, info.max, config.min, info.ctx, info.step) end
  end,
})

-- Keep sliding windows in sync with their parents when windows close.
vim.api.nvim_create_autocmd("WinClosed", {
  group = augroup,
  callback = function(ev)
    local closed = tonumber(ev.match)
    -- A sliding window closed on its own: just forget it.
    if sliding[closed] then
      sliding[closed] = nil
      return
    end
    -- A parent closed: collect first (handlers mutate `sliding`), then react.
    local affected = {}
    for win, info in pairs(sliding) do
      if info.parent == closed then affected[#affected + 1] = win end
    end
    for _, win in ipairs(affected) do
      handle_parent_close(win, closed)
    end
  end,
})

--- Open a sliding window in the given direction.
---@param direction "up"|"down"|"left"|"right" Direction to slide
---@param size integer|nil Target height (up/down) or width (left/right)
---@return integer win The created window handle
local function slide(direction, size)
  local spec = DIRECTIONS[direction]
  assert(spec, "slide: unknown direction " .. tostring(direction))

  local parent = vim.api.nvim_get_current_win()
  local ctx = {
    win = parent,
    w = vim.api.nvim_win_get_width(parent),
    h = vim.api.nvim_win_get_height(parent),
    min = config.min,
  }
  local max = spec.max(ctx, size)

  -- Create buffer and window
  local buf = vim.api.nvim_create_buf(false, true)
  local win_config = spec.initial(ctx)
  win_config.relative, win_config.win = "win", parent
  win_config.focusable = true
  win_config.border = open_edge(expand_border(vim.o.winborder), spec.open)
  local sliding_win = vim.api.nvim_open_win(buf, false, win_config)
  sliding[sliding_win] = { parent = parent, max = max, ctx = ctx, step = spec.step }

  set_winhighlight(sliding_win)

  return sliding_win
end

-- Keymaps
vim.keymap.set("n", "<leader>C", function()
  vim.api.nvim_set_current_win(slide("up"))
  vim.cmd("CodeCompanionChat")
end)
vim.keymap.set("n", "<leader>t", function()
  vim.api.nvim_set_current_win(slide("up"))
  vim.cmd("term")
end)
vim.keymap.set("n", "<leader>T", function()
  vim.api.nvim_set_current_win(slide("down", 12))
  vim.cmd("term htop")
end)

-- Add keymaps to open sliding windows for all directions
vim.keymap.set("n", "<leader>wj", function()
  vim.api.nvim_set_current_win(slide("up"))
  vim.defer_fn(function() vim.fn.feedkeys(":") end, 250)
end)
vim.keymap.set("n", "<leader>wk", function()
  vim.api.nvim_set_current_win(slide("down"))
  vim.defer_fn(function() vim.fn.feedkeys(":") end, 250)
end)
vim.keymap.set("n", "<leader>wh", function()
  vim.api.nvim_set_current_win(slide("right"))
  vim.defer_fn(function() vim.fn.feedkeys(":") end, 250)
end)
vim.keymap.set("n", "<leader>wl", function()
  vim.api.nvim_set_current_win(slide("left"))
  vim.defer_fn(function() vim.fn.feedkeys(":") end, 250)
end)
