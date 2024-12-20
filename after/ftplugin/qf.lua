-- Load Cfilter(!) command
vim.cmd.packadd("cfilter")

-- Whenever a quickfix window is opened...
vim.opt.laststatus = 2

vim.api.nvim_create_autocmd("WinEnter", {
  desc = "Setup for quickfix window",
  pattern = "*",
  callback = function()
    if vim.o.buftype == "quickfix" then vim.opt.laststatus = 2 end
  end,
})

-- Whenever a quickfix window is closed...
vim.api.nvim_create_autocmd("QuitPre", {
  desc = "Restore setup for quickfix window",
  callback = function() vim.opt.laststatus = 3 end,
  once = true,
})

-- Automatically quit if quickscope window is the last window
vim.api.nvim_create_autocmd("WinEnter", {
  pattern = "*",
  desc = "Automatically quit if quickfix window is the last window",
  command = [[if winnr('$') == 1 && &buftype == "quickfix"|q|endif]],
})
