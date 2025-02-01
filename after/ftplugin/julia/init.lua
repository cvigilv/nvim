vim.api.nvim_set_option_value("tw", 96, { scope = "local" })
vim.api.nvim_set_option_value(
  "formatexpr",
  "v:lua.require('conform').formatexpr()",
  { scope = "local" }
)
