require("plugin.afuera").setup({
  defaults = {
    state = true,
    colorcolumn = "",
  },
})

vim.keymap.set("n", ",,o", ":AfueraToggle<CR>")
vim.keymap.set("n", ",,O", ":AfueraStatus<CR>")
