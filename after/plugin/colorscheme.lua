local function sync_theme()
  vim.cmd("silent !tmux source ~/.config/tmux/tmux_" .. vim.o.background .. ".conf")
end

vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "background",
  callback = function()
    vim.cmd("silent !tmux source ~/.config/tmux/tmux_" .. vim.o.background .. ".conf")
  end,
})

vim.cmd("colorscheme personal")
sync_theme()
