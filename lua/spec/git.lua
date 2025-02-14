return {
  -- gitsigns {{{
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signcolumn = false,
        numhl = true,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
          interval = 1000,
          follow_files = true,
        },
        attach_to_untracked = false,
        current_line_blame = false,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "right_align",
          delay = 10,
          ignore_whitespace = true,
        },
        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil,
        max_file_length = 40000,
        preview_config = {
          border = "single",
          style = "minimal",
          relative = "cursor",
          row = 0,
          col = 1,
        },
      })

      -- Keymaps
      vim.keymap.set(
        "n",
        "<leader>ga",
        function() require("gitsigns").stage_hunk() end,
        { noremap = true, silent = true, desc = "Stage hunk" }
      )
      vim.keymap.set(
        "v",
        "<leader>ga",
        function() require("gitsigns").stage_hunk({ vim.fn.line("v"), vim.fn.line(".") }) end,
        { noremap = true, silent = true, desc = "Stage hunk" }
      )
      vim.keymap.set(
        "n",
        "<leader>gr",
        function() require("gitsigns").undo_stage_hunk() end,
        { noremap = true, silent = true, desc = "Undo stage hunk" }
      )
      vim.keymap.set(
        "v",
        "<leader>gr",
        function() require("gitsigns").undo_stage_hunk({ vim.fn.line("v"), vim.fn.line(".") }) end,
        { noremap = true, silent = true, desc = "Undo stage hunk" }
      )
      vim.keymap.set("n", "<leader>gd", function()
        require("gitsigns").toggle_deleted()
        require("gitsigns").toggle_linehl()
      end, { noremap = true, silent = true, desc = "Toggle diff" })

      vim.keymap.set(
        "n",
        "]g",
        function() require("gitsigns").nav_hunk("next") end,
        { noremap = true, silent = true, desc = "Go to next Git hunk" }
      )
      vim.keymap.set(
        "n",
        "[g",
        function() require("gitsigns").nav_hunk("prev") end,
        { noremap = true, silent = true, desc = "Go to previous Git hunk" }
      )
    end,
  }, -- }}}
}
