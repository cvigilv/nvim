return {
  -- Context {{{
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "VeryLazy",
    config = function()
      -- Setup
      require("treesitter-context").setup({
        multiwindow = true,
        max_lines = 0,
        min_window_height = 0,
        line_numbers = true,
        multiline_threshold = 20,
        trim_scope = "inner",
        mode = "topline",
        separator = "•",
        zindex = 20,
        on_attach = nil,
      })

      -- Highlights
      vim.api.nvim_set_hl(0, "TreesitterContext", { link = "Normal" })
      vim.api.nvim_set_hl(0, "TreesitterContextSeparator", { link = "Comment" })

      -- Keymaps
      vim.keymap.set(
        "n",
        "[c",
        function() require("treesitter-context").go_to_context(vim.v.count1) end,
        { silent = true }
      )
    end,
  }, -- }}}
  -- quicker.nvim {{{
  {
    "stevearc/quicker.nvim",
    event = "FileType qf",
    opts = {
      opts = {
        buflisted = false,
        colorcolumn = "",
        number = true,
        relativenumber = false,
        signcolumn = "auto",
        winfixheight = true,
        wrap = false,
        winfixbuf = true,
      },
      keys = {
        {
          ">",
          function()
            require("quicker").expand({ before = 3, after = 3, add_to_existing = true })
          end,
          desc = "Expand quickfix context",
        },
        {
          "<",
          function() require("quicker").collapse() end,
          desc = "Collapse quickfix context",
        },
      },
    },
  }, --}}}
}
