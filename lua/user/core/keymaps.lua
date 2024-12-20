local map = vim.keymap.set

-- Quickfix
map("n", "]Q", ":cnewer<CR>", { silent = false, desc = "Next quickfix list" })
map("n", "[Q", ":colder<CR>", { silent = false, desc = "Previous quickfix list" })
