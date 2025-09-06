-- Setup available LSPs
vim.lsp.enable({
  "bashls",
  "harper_ls",
  "jsonls",
  "julials",
  "lua_ls",
  "marksman",
  "pyright",
  "tinymist",
})

-- Setup behavior whenever LSP is attached to current buffer
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("carlos::lsp", { clear = true }),
  callback = function(args)
    -- Get current client
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    -- Keymaps
    local map = function(keys, func, desc, mode)
      mode = mode or "n"
      vim.keymap.set(mode, keys, func, { buffer = args.buf, desc = desc })
    end

    if client:supports_method("textDocument/codeAction") then
      map("<leader>la", vim.lsp.buf.code_action, "Code Action")
      map("gra", vim.lsp.buf.code_action, "Code Action")
    end
    if client:supports_method("textDocument/rename") then
      map("<leader>ln", vim.lsp.buf.rename, "Rename symbol")
      map("grn", vim.lsp.buf.rename, "Rename symbol")
    end
    if client:supports_method("textDocument/inlayHint") then
      map(
        "<leader>lh",
        function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
        "Toggle Inlay Hints"
      )
    end
    if client:supports_method("textDocument/references") then
      map("grr", vim.lsp.buf.references, "Go to References")
      map("<leader>lr", vim.lsp.buf.references, "Go to References")
    end
    if client:supports_method("textDocument/definition") then
      map("gd", vim.lsp.buf.definition, "Go to Definition")
    end
    if client:supports_method("textDocument/declaration") then
      map("gD", vim.lsp.buf.declaration, "Go to Declaration")
    end
    if client:supports_method("textDocument/typeDefinition") then
      map("<leader>lt", vim.lsp.buf.type_definition, "Go to Type definition")
    end
    if client:supports_method("textDocument/implementation") then
      map("<leader>li", vim.lsp.buf.implementation, "Go to Implementation")
      map("gri", vim.lsp.buf.implementation, "Go to Implementation")
    end
    if client:supports_method("textDocument/documentSymbol") then
      map("<leader>ls", vim.lsp.buf.document_symbol, "See Document Symbols")
    end
    if client:supports_method("textDocument/workspaceSymbol") then
      map("<leader>lS", vim.lsp.buf.workspace_symbol, "See Workspace Symbols")
    end
  end,
})
