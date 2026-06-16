-- Plugins
vim.b.miniindentscope_disable = true
vim.b.minihipatterns_disable = true

-- Options
_G.carlos.org = {}
vim.opt_local.textwidth = 96
vim.opt_local.conceallevel = 2
vim.opt_local.foldlevel = 99

-- Keymaps
vim.keymap.set("n", ",sw", ":Escritura<CR>", { desc = "Toggle writing mode" })
vim.keymap.set("n", ",sc", ":setlocal spell!<CR>", { desc = "Toggle spell checker" })
vim.keymap.set("n", ",fz", ":Telescope zotero<CR>", { desc = "Find Zotero" })
vim.keymap.set("n", "<leader>or", require("telescope").extensions.orgmode.refile_heading)

-- Extra
--- Statuscolumn
require("plugin.headercolumn").setup(12)

--- Writing mode
require("plugin.escritura").setup(12)

-- Contacts
require("plugin.contacto").setup()

--- Zotero
require("plugin.zotero-notes").setup({
  denote_silo_path = "/Users/carlos/org",
  -- zotero_db_path = "/Users/carlos/Zotero/zotero.sqlite",
  -- better_bibtex_db_path = "/Users/carlos/Zotero/better-bibtex.sqlite",
})
