-- Tabulate behaviour
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true

-- Fold
vim.opt.foldmethod="expr"
vim.opt.foldexpr="v:lua.vim.treesitter.foldexpr()"

-- Keymaps
vim.keymap.set("n", "<Tab>", "za", { noremap = true})
vim.keymap.set("n", "<S-Tab>", "zA", { noremap = true })

-- REPL
vim.keymap.set("n", "<leader>R", ":Luapad<CR>", { noremap = true, desc = "REPL" })
