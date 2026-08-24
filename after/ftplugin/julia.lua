-- Options
vim.opt_local.expandtab = true
vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt_local.foldmethod = "expr"
vim.opt_local.formatexpr = "v:lua.require('conform').formatexpr()"
vim.opt_local.textwidth = 96

-- Keymaps
vim.keymap.set("n", "<Tab>", "za", { noremap = true })
vim.keymap.set("n", "<S-Tab>", "zA", { noremap = true })

-- JETLS diagnostics for this buffer, straight from the `jetls check` CLI: no
-- language server has to be running, and nothing stays resident afterwards.
vim.api.nvim_buf_create_user_command(
  0,
  "JetlsCheck",
  function() require("lib.jetls").check(0) end,
  { desc = "Check buffer with `jetls check`, into the quickfix list" }
)
vim.keymap.set(
  "n",
  "<leader>lc",
  function() require("lib.jetls").check(0) end,
  { buffer = true, desc = "Check buffer with JETLS" }
)
