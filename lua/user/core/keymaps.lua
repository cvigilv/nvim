local map = vim.keymap.set

-- Quickfix
map("n", "]q", ":cnext<CR>", { silent = false, desc = "Next quickfix entry" })
map("n", "[q", ":cprev<CR>", { silent = false, desc = "Previous quickfix entry" })
map("n", "]Q", ":cnewer<CR>", { silent = false, desc = "Next quickfix list" })
map("n", "[Q", ":colder<CR>", { silent = false, desc = "Previous quickfix list" })
map("n", "<leader>q", ":copen<CR>", { silent = true, desc = "Open quickfix list" })
map("n", "<leader>Q", ":Cfilter ", { silent = true, desc = "Filter quickfix list" })

-- Find
map("n", "<leader>ff", ":find *", { silent = true, desc = "Find file" })
map("n", "<leader>fF", ":sfind *", { silent = true, desc = "Find file in split" })
map("n", "<leader>fs", ":vimgrep /", { silent = true, desc = "Find string" })
