-- Keymaps
vim.keymap.set("n", ",sw", ":Escritura<CR>", { desc = "Toggle writing mode" })
vim.keymap.set("n", ",sc", ":setlocal spell!<CR>", { desc = "Toggle spell checker" })
vim.keymap.set("n", ",fz", ":Telescope zotero<CR>", { desc = "Find Zotero" })

-- Statuscolumn
require("plugin.headercolumn").setup(12)

-- Writing mode
require("plugin.escritura").setup()
