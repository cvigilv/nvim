-- HACK: Sticky shift commands
vim.api.nvim_create_user_command("Q", ":quit", {})
vim.api.nvim_create_user_command("Wq", ":wq", {})
vim.api.nvim_create_user_command("Wqa", ":wqa", {})
