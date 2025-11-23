-- Options
vim.opt_local.expandtab = true
vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt_local.foldmethod = "expr"
vim.opt_local.formatexpr = "v:lua.require('conform').formatexpr()"
vim.opt_local.textwidth = 96

-- Keymaps
vim.keymap.set("n", "<Tab>", "za", { noremap = true })
vim.keymap.set("n", "<S-Tab>", "zA", { noremap = true })
