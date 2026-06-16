-- Options
vim.opt_local.textwidth = 96

-- Keymaps
vim.keymap.set("n", ",sw", ":Escritura<CR>", { desc = "Toggle writing mode" })
vim.keymap.set("n", ",sc", ":setlocal spell!<CR>", { desc = "Toggle spell checker" })

-- Extra
require("plugin.headercolumn").setup(12)
require("plugin.escritura").setup(12)
