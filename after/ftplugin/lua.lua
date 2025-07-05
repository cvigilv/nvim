-- Options
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.tabstop = 2
vim.opt_local.expandtab = true
vim.opt_local.foldmethod = "expr"
vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- Keymaps
vim.keymap.set("n", "<Tab>", "za", { noremap = true })
vim.keymap.set("n", "<S-Tab>", "zA", { noremap = true })
vim.keymap.set("n", "<leader>R", ":Luapad<CR>", { noremap = true, desc = "Open REPL" })
