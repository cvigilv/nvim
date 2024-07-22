return {
	{ -- LSP Configuration & Plugins{{{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim", config = true }, -- NOTE: Must be loaded before dependants
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			"nvim-telescope/telescope.nvim",
			{ "folke/lazydev.nvim", ft = "lua", config = true },
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					-- Keymaps
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
					map("gr", vim.lsp.buf.references, "[G]oto [R]eferences")
					map("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
					map("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
					map("<leader>ds", vim.lsp.buf.document_symbol, "[D]ocument [S]ymbols")
					map("<leader>ws", vim.lsp.buf.workspace_symbol, "[W]orkspace [S]ymbols")
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
					map("K", vim.lsp.buf.hover, "Hover Documentation")
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
						map("<leader>th", function()
							---@diagnostic disable-next-line: missing-parameter
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				},
				["julia-lsp"] = {
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
				},
				["ruff_lsp"] = {},
				["bashls"] = {},
				["typst-lsp"] = {},
				["marksman"] = {},
				["pyright"] = {},
			}

			-- Mason
			require("mason").setup()
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua",
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	}, -- }}}
	{ -- Autoformat{{{
		"stevearc/conform.nvim",
		lazy = false,
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = "n",
				desc = "Format buffer",
			},
		},
		config = function()
			local conform = require("conform")

			--- Global options
			vim.o.formatexpr = [[v:lua.require('conform').formatexpr()]]

			--- Setup
			conform.setup({
				formatters_by_ft = {
					["*"] = { "trim_whitespace", "trim_newlines" },
					json = { "jq" },
					lua = { "stylua" },
					markdown = { "injected" },
					python = { "ruff_fix", "ruff_format" },
					sh = { "shfmt" },
					bib = { "bibtex-tidy" },
					typst = { "typstfmt" },
				},
				format_on_save = function(bufnr)
					local format_options = { timeout_ms = 100, quiet = true, lsp_fallback = false }
					if vim.bo[bufnr].filetype == "markdown" then
						format_options =
							vim.tbl_extend("keep", format_options, { formatters = { "injected", "trim_whitespace" } })
					end
					return format_options
				end,
				notify_on_error = false,
			})
		end,
	}, -- }}}
	{ -- Autocompletion{{{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				build = (function()
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {},
			},
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-omni",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-buffer",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			luasnip.config.setup({})

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-d>"] = cmp.mapping.scroll_docs(-4),
					["<C-u>"] = cmp.mapping.scroll_docs(4),
					["<C-y>"] = cmp.mapping(
						cmp.mapping.confirm({
							behavior = cmp.ConfirmBehavior.Insert,
							select = true,
						}),
						{ "i", "c" }
					),
					["<C-Space>"] = cmp.mapping.complete({}),
					["<C-l>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					["<C-h>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),
				}),
				sources = {
					{ name = "lazydev" },
					{ name = "luasnip" },
					{ name = "nvim_lsp" },
					{ name = "omni" },
					{ name = "path" },
					{ name = "buffer" },
				},
			})
		end,
	}, -- }}}
	{ -- Snippet {{{
		"chrisgrieser/nvim-scissors",
		dependencies = { "nvim-telescope/telescope.nvim", "L3MON4D3/LuaSnip" },
		keys = { "<leader>se" },
		config = function()
			-- Setup
			require("scissors").setup({
				jsonFormatter = "jq",
			})

			-- Keymaps
			vim.keymap.set("n", "<leader>se", function()
				require("scissors").editSnippet()
			end, { desc = "Edit snippet" })
			vim.keymap.set({ "n", "x" }, "<leader>sa", function()
				require("scissors").addNewSnippet()
			end, { desc = "Add snippet" })
		end,
	}, --}}}
}
