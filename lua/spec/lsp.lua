---@module "spec.lsp"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

return {
  { -- LSP {{{
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim", config = true }, -- LSP installer
      { "folke/lazydev.nvim", ft = "lua", config = true }, -- Neovim development
      "j-hui/fidget.nvim", -- UI extras
      "williamboman/mason-lspconfig.nvim", -- LSP-installer compatibility layer
      "hrsh7th/nvim-cmp", -- Completion engine
      "hrsh7th/cmp-nvim-lsp", -- Completion engine compatibility with LSP
    },
    enabled = true,
    config = function()
      -- Setup fidget
      require("fidget").setup({ notification = { window = { relative = "win" } } })

      -- Define LSPs for each filetype
      local languages = { -- {{{
        julia = {
          julials = { -- {{{
            settings = {
              julia = {
                symbolCacheDownload = true,
                lint = {
                  missingrefs = "all",
                  iter = true,
                  lazy = true,
                  modname = true,
                },
              },
            },
          }, -- }}}
        },
        lua = {
          lua_ls = { -- {{{
            settigs = {
              Lua = {
                runtime = { version = "LuaJIT" },
                completion = { callSnippet = "Replace" },
                format = { enable = false },
                hint = {
                  enable = true,
                  arrayIndex = "Disable",
                },
                telemetry = { enable = false },
                workspace = {
                  checkThirdParty = false,
                  library = { vim.env.VIMRUNTIME },
                },
              },
            },
          }, -- }}}
        },
        json = { jsonls = {} },
        markdown = {
          marksman = {},
          ["harper_ls"] = { -- {{{
            settings = {
              ["harper-ls"] = {
                userDictPath = "",
                fileDictPath = "",
                linters = {
                  SpellCheck = (function()
                    return "markdown"
                      == vim.api.nvim_get_option_value(
                        "filetype",
                        { buf = vim.api.nvim_get_current_buf() }
                      )
                  end)(),
                  SpelledNumbers = true,
                  AnA = true,
                  SentenceCapitalization = true,
                  UnclosedQuotes = true,
                  WrongQuotes = false,
                  LongSentences = true,
                  RepeatedWords = true,
                  Spaces = true,
                  Matcher = true,
                  CorrectNumberSuffix = true,
                },
                codeActions = {
                  ForceStable = false,
                },
                markdown = {
                  IgnoreLinkTitle = false,
                },
                diagnosticSeverity = "hint",
                isolateEnglish = false,
              },
            },
          }, -- }}}
        },
        python = { pyright = {} },
        sh = { bashls = {} },
        typst = { tinymist = {} },
      } -- }}}

      -- Ensure all servers are installed
      require("mason-lspconfig").setup({
        automatic_installation = true,
        ensure_installed = vim
          .iter(vim.tbl_values(languages))
          :map(vim.tbl_keys)
          :flatten()
          :totable(),
      })

      -- Setup all servers
      for _, servers in pairs(languages) do
        for name, config in pairs(servers) do
          local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            require("cmp_nvim_lsp").default_capabilities(),
            config or {}
          )
          require("lspconfig")[name].setup(capabilities)
        end
      end

      -- Setup behaviour whenever LSP is attached to current buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("carlos::lsp", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end


          -- Lightbulb
          require('lightbulb').attach_lightbulb(args.buf, client.id)

          -- Keymap helper
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = args.buf, desc = desc })
          end

          if client:supports_method("textDocument/codeAction") then
            map("<leader>la", vim.lsp.buf.code_action, "Code Action")
            map("gra", vim.lsp.buf.code_action, "Code Action")
          end

          if client:supports_method("textDocument/rename") then
            map("<leader>ln", vim.lsp.buf.rename, "Rename")
            map("grn", vim.lsp.buf.rename, "Rename")
          end

          if client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable()
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
    end,
  }, -- }}}
}
