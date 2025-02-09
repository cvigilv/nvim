local map = vim.keymap.set

-- Quickfix
map("n", "]Q", ":cnewer<CR>", { silent = false, desc = "Next quickfix list" })
map("n", "[Q", ":colder<CR>", { silent = false, desc = "Previous quickfix list" })

-- Execution
map("n", "<leader>x", ":source %<CR>", { silent = false, desc = "Source current file" })
map("v", "<leader>x", ":source<CR>", { silent = false, desc = "Source selected file" })
