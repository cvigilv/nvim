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
  { -- Formatter and Linter {{{
    "WhoIsSethDaniel/mason-tool-installer.nvim", -- Tool installer
    dependencies = {
      "neovim/nvim-lspconfig",
      "williamboman/mason-lspconfig.nvim",
      "mfussenegger/nvim-lint", -- Linting
      "stevearc/conform.nvim", -- Formatting
    },
    enabled = true,
    config = function()
      local conform = require("conform")
      local lint = require("lint")

      -- Tools per language
      local languages = { -- {{{
        ["*"] = { formatter = { "trim_whitespace", "trim_newlines" }, linter = nil },
        bib = { formatter = { "bibtex-tidy" }, linter = nil },
        json = { formatter = { "jq" }, linter = nil },
        julia = { formatter = { "runic" }, linter = nil },
        lua = { formatter = { "stylua" }, linter = { "luacheck" } },
        markdown = { formatter = { "injected" }, linter = nil },
        python = { formatter = { "ruff" }, linter = { "mypy" } },
        sh = { formatter = { "shfmt" }, linter = { "shellcheck" } },
        typst = { formatter = { "typstyle" }, linter = nil },
      } -- }}}

      -- Custom formatters
      conform.formatters = {
        runic = {
          command = "julia",
          args = { "--project=@runic", "-e", "using Runic; exit(Runic.main(ARGS))" },
        },
        typstyle = {
          command = "typstyle",
          args = { "-i" },
        },
      }

      -- Ensure tools are installed
      require("mason-tool-installer").setup({
        automatic_installation = true,
        ensure_installed = vim
          .iter(vim.tbl_values(languages))
          :map(function(kv) return vim.tbl_values(kv) end)
          :flatten(math.huge)
          :filter(function(v)
            local ignore = {
              "injected",
              "trim_whitespace",
              "trim_newlines",
            }
            return not vim.tbl_contains(ignore, v)
              and not vim.tbl_contains(vim.tbl_keys(conform.formatters), v)
          end)
          :totable(),
      })

      -- Tool configuration
      lint.linters_by_ft = {}
      conform.setup({
        notify_on_error = true,
        notify_no_formatters = false,
        default_format_opts = {
          quiet = true,
          lsp_fallback = "first",
          timeout_ms = 10000,
        },
      })
      for ft, tools in pairs(languages) do
        conform.formatters_by_ft[ft] = tools["formatter"]
        if tools.linter then table.insert(lint.linters_by_ft, { [ft] = tools.linter }) end
      end

      -- Autocommands
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
  }, --}}}
}
