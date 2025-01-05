require("afuera").setup({
  defaults = {
    state = true,
    colorcolumn = "96",
  },
  oob_char_hl = "Removed",
  ignored_filetypes = { "log" },
  logging = { enabled = true },
})

vim.keymap.set("n", ",,o", ":AfueraToggle<CR>")
vim.keymap.set("n", ",,O", ":AfueraStatus<CR>")
