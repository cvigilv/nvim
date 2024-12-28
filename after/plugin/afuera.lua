require("plugin.afuera").setup({
  defaults = {
    state = true,
    colorcolumn = "",
  },
  ignored_filetypes = { "log" },
})

vim.keymap.set("n", ",,o", ":AfueraToggle<CR>")
vim.keymap.set("n", ",,O", ":AfueraStatus<CR>")
