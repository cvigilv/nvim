(vim.lsp.log.set_format_func vim.inspect)
(vim.lsp.enable [:fennel-ls])
(vim.api.nvim_create_user_command
  :LspStart
  (fn [args]
    (vim.lsp.enable args.args)
    (vim.wait 500)
    (vim.cmd.edit))
  {:desc "Start an LS client"
   :nargs 1})
