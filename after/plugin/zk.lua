---@module 'plugin.zk'
---@author Carlos Vigil-Vásquez
---@license MIT

---@diagnostic disable-next-line: missing-parameter
require("plugin.zk").setup()

vim.keymap.set("n", "<leader>zc", ":ZkNewNote<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>zf", ":ZkSearchNotes<CR>", { noremap = true, silent = false })
vim.keymap.set("n", "<leader>zt", ":ZkSearchTags<CR>", { noremap = true, silent = false })

--- Bind ,zl to create a link from current visual selection
--- TODO: Add second step where a Telescope prompt appears and I can easily select a note from
---       its title.
vim.keymap.set(
  { "x", "v" },
  "<leader>zl",
  [[c[<C-r>"]()<C-c>i]],
  vim.tbl_extend("keep", { noremap = true, silent = false }, { desc = "Create new link" })
)
