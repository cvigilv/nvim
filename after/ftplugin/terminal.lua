-- Local options
vim.opt_local.number = false
vim.opt_local.relativenumber = false
vim.opt_local.signcolumn = "no"
vim.opt_local.stc = " "
vim.opt_local.winhighlight = "Normal:OutOfBounds"

-- Keymaps
vim.api.nvim_buf_set_keymap(
  0,
  "t",
  "<Leader><Esc>",
  "<C-\\><C-n>",
  { noremap = true, silent = true }
)
