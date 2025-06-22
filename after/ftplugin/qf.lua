-- Load Cfilter(!) command
vim.cmd.packadd("cfilter")

-- Automatically quit if quickscope window is the last window
vim.api.nvim_create_autocmd("WinEnter", {
  pattern = "*",
  desc = "Automatically quit if quickfix window is the last window",
  command = [[if winnr('$') == 1 && &buftype == "quickfix"|q|endif]],
})

vim.keymap.set("n", "?", ":Cfilter ")
