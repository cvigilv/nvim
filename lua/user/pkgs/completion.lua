local kind_icons = {
  Class = "󰠱",
  Color = "󰏘",
  Constant = "󰏿",
  Constructor = "",
  Enum = "",
  EnumMember = "",
  Event = "",
  Field = "󰇽",
  File = "󰈙",
  Folder = "󰉋",
  Function = "󰊕",
  Interface = "",
  Keyword = "󰌋",
  Method = "󰆧",
  Module = "",
  Operator = "󰆕",
  Property = "",
  Reference = "",
  Snippet = "",
  Struct = "",
  Text = "",
  TypeParameter = "",
  Unit = "U",
  Value = "󰎠",
  Variable = "󰂡",
}

return {
  { -- Autocompletion {{{
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { -- {{{
      {
        "L3MON4D3/LuaSnip",
        build = (function()
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then return end
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
      { "petertriho/cmp-git", dependencies = "nvim-lua/plenary.nvim" },
    }, -- }}}
    config = function()
      -- Snippet management
      local luasnip = require("luasnip")
      luasnip.config.setup({})

      -- Autocompletion
      local cmp = require("cmp")
      cmp.setup({
        ---@diagnostic disable-next-line: missing-fields
        performance = { -- {{{
          max_view_entries = 24,
        }, -- }}}
        window = { -- {{{
          completion = {
            col_offset = -3,
            side_padding = 0,
          },
        }, -- }}}
        view = { -- {{{
          entries = {
            name = "custom",
            selection_order = "near_cursor",
          },
        }, -- }}}
        experimental = { -- {{{
          ghost_text = false, -- Too noisy
        }, -- }}}

        ---@diagnostic disable-next-line: missing-fields
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, item)
            -- Don't fancy up the command line
            if vim.tbl_contains({ "cmdline", "git" }, entry.source.name) then
              item.kind = ""
              item.menu = ""
              return item
            end

            -- Add icons to completion items
            item.menu = item.kind
              .. " "
<<<<<<< Updated upstream:lua/user/pkgs/completion.lua
              .. ({
                buffer = "[Buf]",
                nvim_lsp = "[LSP]",
                luasnip = "[Snip]",
                lazydev = "[Nvim]",
                omni = "[Omni]",
                path = "[Path]",
                git = "[Git]",
                zk = "[ZK]",
              })[entry.source.name]
=======
              .. (({
                nvim_lsp = "[LSP]",
                luasnip = "[SNIP]",
                lazydev = "[NVIM]",
                omni = "[OMNI]",
                cardex = "[CARDEX]",
              })[entry.source.name] or "[PLUG]")
>>>>>>> Stashed changes:lua/spec/completion.lua
            item.kind = string.format(" %s ", kind_icons[item.kind])

            return item
          end,
        },

        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },

        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-u>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete({}),
          ["<C-y>"] = cmp.mapping(
            cmp.mapping.confirm({
              behavior = cmp.ConfirmBehavior.Insert,
              select = true,
            }),
            { "i", "c" }
          ),
          ["<C-l>"] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then luasnip.expand_or_jump() end
          end, { "i", "s" }),
          ["<C-h>"] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then luasnip.jump(-1) end
          end, { "i", "s" }),
        }),

        sources = {
          { name = "lazydev", group_index = 1 },
          { name = "luasnip", group_index = 2 },
          { name = "nvim_lsp", group_index = 3 },
          { name = "omni", group_index = 4 },
          { name = "path", group_index = 4 },
          { name = "buffer", group_index = 6 },
        },
      })

      -- Set configuration for specific filetype.
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "cmdline", group_index = 1 },
          { name = "path", group_index = 2 },
        }),
      })

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer", group_index = 1 },
          { name = "path", group_index = 2 },
        },
      })
    end,
  }, -- }}}
  { -- Snippet creation {{{
    "chrisgrieser/nvim-scissors",
    dependencies = { "nvim-telescope/telescope.nvim", "L3MON4D3/LuaSnip" },
    keys = { "<leader>sa", "<leader>se" },
    config = function()
      -- Setup
      require("scissors").setup({
        snippetDir = vim.fn.stdpath("config") .. "/extras/snippets",
        editSnippetPopup = {
          height = 0.3,
          width = 0.6,
          ---@diagnostic disable-next-line: assign-type-mismatch
          border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
          keymaps = {
            cancel = "<Esc>",
            saveChanges = "<CR>",
            goBackToSearch = "<BS>",
            deleteSnippet = "<C-BS>",
            duplicateSnippet = "<C-d>",
            openInFile = "<C-o>",
            insertNextPlaceholder = "<C-p>",
          },
        },
        backdrop = { enabled = true, blend = 50 },
        telescope = { alsoSearchSnippetBody = true },
        jsonFormatter = "jq",
      })

      -- Keymaps
      vim.keymap.set(
        "n",
        "<leader>se",
        function() require("scissors").editSnippet() end,
        { desc = "Edit snippet" }
      )
      vim.keymap.set(
        { "n", "x" },
        "<leader>sa",
        function() require("scissors").addNewSnippet() end,
        { desc = "Add snippet" }
      )
    end,
  }, --}}}
}
