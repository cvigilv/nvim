-- [nfnl] after/ftplugin/fennel.fnl
vim.lsp.log.set_format_func(vim.inspect)
vim.lsp.enable({"fennel-ls"})
local function _1_(args)
  vim.lsp.enable(args.args)
  vim.wait(500)
  return vim.cmd.edit()
end
return vim.api.nvim_create_user_command("LspStart", _1_, {desc = "Start an LS client", nargs = 1})
