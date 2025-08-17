-- Plugins
vim.b.miniindentscope_disable = true

-- Options
vim.opt_local.textwidth = 96
vim.api.nvim_set_option_value("cc", "", { scope = "local" })
vim.api.nvim_set_option_value("statuscolumn", "%#Normal#   ", { scope = "local" })
vim.api.nvim_set_option_value("conceallevel", 3, { scope = "local" })
vim.api.nvim_set_option_value("concealcursor", "nvc", { scope = "local" })

-- Contacts
require("plugin.pkm.contacto").setup()
