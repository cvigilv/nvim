return {
  { -- Documentation generation {{{
    "danymat/neogen",
    dependencies = { "nvim-treesitter/nvim-treesitter", "L3MON4D3/LuaSnip" },
    keys = { "<Leader>ld", "<Leader>lD" },
    config = function()
      local neogen = require("neogen")

      -- Setup package
      neogen.setup({
        enabled = true,
        snippet_engine = "luasnip",
        languages = {
          lua = { template = { annotation_convention = "emmylua" } },
          python = { template = { annotation_convention = "numpydoc" } },
          julia = { template = { annotation_convention = "julia" } },
          sh = { template = { annotation_convention = "google_bash" } },
        },
      })

      -- Keymaps
      vim.keymap.set(
        "n",
        "<Leader>ld",
        function() require("neogen").generate({ type = "func" }) end,
        { desc = "Generate function docstring", noremap = true, silent = true }
      )

      vim.keymap.set(
        "n",
        "<Leader>lD",
        function()
          vim.ui.select(
            { "class", "func", "type", "file" },
            { prompt = "Select docstring to generate:" },
            function(choice) require("neogen").generate({ type = choice }) end
          )
        end,
        { desc = "Pick docstring to generate", noremap = true, silent = true } --
      )
    end,
  }, -- }}}
  { -- LSP & Co. {{{
    "neovim/nvim-lspconfig",
    dependencies = {
      -- LSP
      { "williamboman/mason.nvim", config = true }, -- LSP installer
      { "folke/lazydev.nvim", ft = "lua", config = true }, -- Neovim development
      { "j-hui/fidget.nvim", config = true }, -- UI extras

      -- Installers
      "williamboman/mason-lspconfig.nvim", -- LSP-installer compatibility layer
      "WhoIsSethDaniel/mason-tool-installer.nvim", -- Tool installer

      -- Tool managers
      "stevearc/conform.nvim", -- Formatting
      "mfussenegger/nvim-lint", -- Linting
    },

    config = function()
      ---Extracts tool names from a table of language configurations.
      ---@param langs table Table of language configurations
      ---@param entry string Key to access the tool name in each language configuration
      ---@return table tools List of extracted tool names
      local function get_tool_names(langs, entry)
        local tools = {}

        for _, v in pairs(langs) do
          table.insert(tools, (type(v[entry]) == "table") and v[entry][1] or v[entry])
        end

        return tools
      end

      ---@class User.LanguageTooling
      ---@field filetype string Filetype
      ---@field filetype.lsp string|table|nil LSP name (and configuration)
      ---@field filetype.formatter string|nil Filetype formatter
      ---@field filetype.linter string|nil Filetype linter
      local languages = { -- {{{
        bib = { lsp = nil, formatter = "bibtex-tidy", linter = nil },
        json = { lsp = "jsonls", formatter = "jq", linter = nil },
        julia = {
          lsp = {
            "julials",
            {
              on_new_config = function(new_config, _)
                local julia = vim.fn.expand("~/.julia/environments/nvim-lspconfig/bin/julia")
                if require("lspconfig").util.path.is_file(julia) then
                  new_config.cmd[1] = julia
                end
              end,
              root_dir = function(fname)
                local util = require("lspconfig.util")
                return util.root_pattern("Project.toml")(fname)
                  or util.find_git_ancestor(fname)
                  or util.path.dirname(fname)
              end,
              capabilities = (function()
                local cap = vim.lsp.protocol.make_client_capabilities()
                cap.textDocument.completion.completionItem.snippetSupport = true
                cap.textDocument.completion.completionItem.preselectSupport = true
                cap.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
                cap.textDocument.completion.completionItem.deprecatedSupport = true
                cap.textDocument.completion.completionItem.insertReplaceSupport = true
                cap.textDocument.completion.completionItem.labelDetailsSupport = true
                cap.textDocument.completion.completionItem.commitCharactersSupport = true
                cap.textDocument.completion.completionItem.resolveSupport = {
                  properties = { "documentation", "detail", "additionalTextEdits" },
                }
                cap.textDocument.completion.completionItem.documentationFormat = { "markdown" }
                cap.textDocument.codeAction = {
                  dynamicRegistration = true,
                  codeActionLiteralSupport = {
                    codeActionKind = {
                      valueSet = (function()
                        local res = vim.tbl_values(vim.lsp.protocol.CodeActionKind)
                        table.sort(res)
                        return res
                      end)(),
                    },
                  },
                }

                return cap
              end)(),
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
            },
          },
          formatter = nil,
          linter = nil,
        },
        lua = {
          lsp = {
            "lua_ls",
            {
              settings = {
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
                    -- library = vim.api.nvim_get_runtime_file("", true),
                  },
                },
              },
            },
          },
          formatter = "stylua",
          linter = "luacheck",
        },
        markdown = {
          lsp = "marksman",
          formatter = nil,
          linter = nil,
        },
        python = {
          lsp = {
            "pyright",
            {
              settings = {
                pyright = {
                  disableOrganizeImports = true,
                },
                python = {
                  analysis = {
                    ignore = { "*" }, -- Using Ruff
                    typeCheckingMode = "off", -- Using mypy
                  },
                },
              },
            },
          },
          formatter = "ruff",
          linter = nil,
        },
        sh = { lsp = "bashls", formatter = "shfmt", linter = "shellcheck" },
        typst = { lsp = "typst_lsp", formatter = "typstfmt", linter = nil },
      } -- }}}

      -- Setup tools
      local conform = require("conform")
      local lint = require("lint")

      -- Initialize
      require("mason-lspconfig").setup({ ensure_installed = get_tool_names(languages, "lsp") })
      require("mason-tool-installer").setup({
        ensure_installed = vim.tbl_extend(
          "force",
          get_tool_names(languages, "linter"),
          get_tool_names(languages, "formatter")
        ),
      })
      lint.linters_by_ft = {}

      for ft, setup in pairs(languages) do
        -- LSP
        if setup.lsp ~= nil then
          -- Get capabilities
          local name = (type(setup.lsp) == "table") and setup.lsp[1] or setup.lsp
          local user_setup = (type(setup.lsp) == "table") and setup.lsp[2] or {}

          local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            require("cmp_nvim_lsp").default_capabilities(),
            user_setup
          )

          require("lspconfig")[name].setup(capabilities)
        end

        -- Formatting
        local formatters = { "trim_whitespace", "trim_newlines", "injected" }

        --HACK: Freaking ruff_format
        if setup.formatter == "ruff" then
          table.insert(formatters, "ruff_format")
        else
          table.insert(formatters, setup.formatter)
        end

        conform.setup({
          formatters_by_ft = { [ft] = formatters },
          format_on_save = function()
            return { timeout_ms = 100, quiet = true, lsp_fallback = setup.formatter ~= nil }
          end,
          notify_on_error = true,
        })

        -- Linting
        if setup.linter then table.insert(lint.linters_by_ft, { [ft] = setup.linter }) end
      end

      -- Autocommands
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user::lsp", { clear = true }),
        callback = function(event)
          -- Keymaps
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc })
          end

          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gr", vim.lsp.buf.references, "Go to references")
          map("gD", vim.lsp.buf.declaration, "Go to Declaration")
          map("<leader>li", vim.lsp.buf.implementation, "Go to implementation")
          map("<leader>lt", vim.lsp.buf.type_definition, "Go to type definition")
          map("<leader>ls", vim.lsp.buf.document_symbol, "Document symbols")
          map("<leader>lS", vim.lsp.buf.workspace_symbol, "Workspace symbols")
          map("<leader>la", vim.lsp.buf.code_action, "Code action")
          map("<leader>lr", vim.lsp.buf.rename, "Rename")

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            vim.lsp.inlay_hint.enable()
            map(
              "<leader>lh",
              ---@diagnostic disable-next-line: missing-parameter
              function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
              "Toggle Inlay Hints"
            )
          end
        end,
      })

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        pattern = "*",
        callback = function() require("lint").try_lint() end,
      })

      -- Keymaps
      vim.keymap.set(
        "n",
        "<leader>lf",
        function() require("conform").format({ async = true }) end,
        { desc = "Format buffer" }
      )
    end,
  }, -- }}}a
}
