-- Load Cfilter(!) command
vim.cmd.packadd("cfilter")

-- Whenever a quickfix window is opened...
vim.opt.laststatus = 2
vim.g.user_qf_open = true

vim.api.nvim_create_autocmd("WinEnter", {
  group = augroup,
  desc = "Setup for quickfix window",
  pattern = "*",
  callback = function()
    if vim.o.buftype == "quickfix" then
      vim.opt.laststatus = 2
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.opt_local.fillchars = { -- Characters used for UI things
        eob = " ",
        fold = "·",
        foldopen = "",
        foldsep = "|",
        foldclose = "",
        stl = " ",
        stlnc = " ",
      }
      vim.opt_local.colorcolumn = nil
    end
  end,
})

-- Whenever a quickfix window is closed...
vim.api.nvim_create_autocmd("QuitPre", {
  group = augroup,
  desc = "Restore setup for quickfix window",
  callback = function()
    vim.opt.laststatus = 3
    vim.g.user_qf_open = false
  end,
  once = true,
})

-- Automatically quit if quickscope window is the last window
vim.api.nvim_create_autocmd("WinEnter", {
  group = augroup,
  pattern = "*",
  desc = "Automatically quit if quickfix window is the last window",
  command = [[if winnr('$') == 1 && &buftype == "quickfix"|q|endif]],
})
