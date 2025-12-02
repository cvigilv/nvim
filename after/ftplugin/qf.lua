vim.notify("[ftplugin] Activated quickfix-mode")

-- Plugins
vim.cmd.packadd("cfilter")
vim.b.miniindentscope_disable = true

-- Keymaps
vim.keymap.set("n", "?", ":Cfilter ")

-- Extras
--- Automatically quit if quickscope window is the last window
vim.api.nvim_create_autocmd("WinEnter", {
  pattern = "*",
  desc = "Automatically quit if quickfix window is the last window",
  command = [[if winnr('$') == 1 && &buftype == "quickfix"|q|endif]],
})
