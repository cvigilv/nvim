---@module "plugin.escritura"
---@author Carlos Vigil-Vásquez
---@license MIT 2026
-- A reversible distraction-free writing mode

local M = {}

local active
local configured = false

local function restore_buffer()
  if not active then return end
  if vim.api.nvim_buf_is_valid(active.bufnr) then
    vim.bo[active.bufnr].textwidth = active.textwidth
    vim.b[active.bufnr].carlos_writing_mode_enabled = false
  end
  active = nil
end

local function configure()
  if configured then return end
  configured = true

  require("twilight").setup({
    context = 0,
    expand = {
      "paragraph",
      "latex_env",
      "inline_math_block",
      "display_math_block",
    },
  })

  require("zen-mode").setup({
    window = {
      backdrop = 1,
      width = 120,
      height = 1,
      options = {
        breakindent = true,
        cursorcolumn = false,
        cursorline = false,
        linebreak = true,
        list = false,
        number = true,
        relativenumber = false,
        spell = true,
        wrap = true,
      },
    },
    plugins = {
      options = {
        enabled = true,
        laststatus = 0,
        ruler = false,
        showcmd = false,
        showtabline = 0,
      },
      twilight = { enabled = true },
    },
    on_open = function()
      if active and vim.api.nvim_buf_is_valid(active.bufnr) then
        vim.b[active.bufnr].carlos_writing_mode_enabled = true
      end
    end,
    on_close = restore_buffer,
  })
end

local function enable(bufnr)
  -- Issue #5: writing mode must leave the user's split layout and options intact.
  active = {
    bufnr = bufnr,
    textwidth = vim.bo[bufnr].textwidth,
  }
  vim.bo[bufnr].textwidth = 0
  require("zen-mode").open()

  if not require("zen-mode.view").is_open() then restore_buffer() end
end

---Toggle writing mode for the current buffer.
function M.toggle()
  local bufnr = vim.api.nvim_get_current_buf()
  if active then
    require("zen-mode").close()
  else
    enable(bufnr)
  end
end

---Set up writing mode for the current buffer.
function M.setup()
  configure()

  vim.b.carlos_writing_mode_enabled = false
  vim.opt_local.spelllang = { "en_us", "es_mx" }
  require("plugin.thesaurus").setup_buffer()

  vim.api.nvim_buf_create_user_command(0, "Escritura", M.toggle, {
    desc = "Toggle distraction-free writing mode",
  })
end

return M
