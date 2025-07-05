-- Plugin
vim.cmd("TSEnable highlight")
vim.b.miniindentscope_disable = true

-- Options
vim.api.nvim_set_option_value(
  "winhighlight",
  "Normal:OutOfBounds",
  { win = 0, scope = "local" }
)
