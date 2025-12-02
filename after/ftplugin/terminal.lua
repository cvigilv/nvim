vim.notify("[ftplugin] Activated terminal-mode")

-- Plugins
vim.b.miniindentscope_disable = true

-- Options
vim.opt_local.number = false
vim.opt_local.relativenumber = false
vim.opt_local.signcolumn = "no"
vim.opt_local.stc = " "
vim.opt_local.winhighlight = "Normal:OutOfBounds"

-- Keymaps
vim.api.nvim_buf_set_keymap(
  0,
  "t",
  "<Esc><Esc>",
  "<C-\\><C-n>",
  { noremap = true, silent = true }
)
