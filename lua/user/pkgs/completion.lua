return {
  { -- Autocompletion {{{
    "saghen/blink.cmp",
    lazy = false, -- lazy loading handled internally
    dependencies = { "folke/lazydev.nvim", ft = "lua", config = true }, -- Neovim development
    version = "v0.*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- Keymaps
      keymap = {
        ["<C-s>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },

        ["<C-y>"] = { "select_and_accept" },

        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },

        ["<C-u>"] = { "scroll_documentation_up", "fallback" },
        ["<C-d>"] = { "scroll_documentation_down", "fallback" },

        ["<C-l>"] = { "snippet_forward", "fallback" },
        ["<C-h>"] = { "snippet_backward", "fallback" },
      },

      -- UX/UI
      completion = {
        list = { max_items = 64 },
        menu = {
          max_height = 32,
          draw = {
            columns = { { "kind_icon" }, { "label" }, { "kind", "source_name", gap = 1 } },
          },
          winhighlight = "Normal:NormalFloat,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 10,
          update_delay_ms = 10,
        },
      },
      signature = { enabled = true },

      -- Sources
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "lazydev" },
        providers = { -- {{{
          buffer = {
            min_keyword_length = 5,
          },
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            fallbacks = { "lsp" },
          },
        }, -- }}}
      },
    },
  }, --}}}
}
