local map = vim.keymap.set

-- Quickfix
map("n", "]q", ":cnext<CR>", { silent = false, desc = "Next quickfix entry" })
map("n", "[q", ":cprev<CR>", { silent = false, desc = "Previous quickfix entry" })
map("n", "]Q", ":cnewer<CR>", { silent = false, desc = "Next quickfix list" })
map("n", "[Q", ":colder<CR>", { silent = false, desc = "Previous quickfix list" })
