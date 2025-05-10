---@module "spec.navigation"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

return {
  { -- Navigator
    "numToStr/Navigator.nvim",
    keys = {
      "<C-h>",
      "<C-k>",
      "<C-l>",
      "<C-j>",
      "<C-p>",
    },
    opts = {
      auto_save = nil,
      disable_on_zoom = true,
    },
  },
  { -- oil
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      view_options = {
        show_hidden = true,
      },
      columns = { "icon" },
      default_file_explorer = true,
      restore_win_options = true,
      skip_confirm_for_simple_edits = false,
      delete_to_trash = false,
      prompt_save_on_select_new_entry = true,
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["|"] = "actions.select_vsplit",
        ["-"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-r>"] = "actions.refresh",
        ["."] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["g."] = "actions.toggle_hidden",
      },
      use_default_keymaps = false,
    },
  },
  { -- Telescope
    "nvim-telescope/telescope.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    cmd = "Telescope",
    keys = {
      "<leader>ff",
      "<leader>fs",
      "<leader>fw",
      "<leader>fW",
      "<leader>fb",
      "<leader>fd",
      "<leader>fh",
      "<leader>f?",
      "<leader>fz",
      "<leader>fZ",
    },
    config = function()
      require("telescope").setup({
        defaults = require("telescope.themes").get_ivy({
          prompt_prefix = "? ",
          selection_prefix = "  ",
          multi_icon = "!",
          layout_config = { height = 0.2, width = 0.6 },
          selection_strategy = "reset",
          sorting_strategy = "ascending",
          path_display = { "filename_first" },
        }),
        pickers = {
          find_files = {
            prompt_title = false,
            prompt_prefix = "[Find files] ",
            previewer = false,
          },
          git_files = {
            prompt_title = false,
            prompt_prefix = "[Git files] ",
            previewer = false,
          },
          live_grep = { prompt_title = false, prompt_prefix = "[Live Grep] " },
          builtin = { prompt_title = false, prompt_prefix = "[Pickers] ", previewer = false },
        },
      })

      local telescope_builtin = require("telescope.builtin")
      vim.keymap.set(
        "n",
        ",ff",
        telescope_builtin.find_files,
        { silent = true, noremap = true, desc = "Find files" }
      )
      vim.keymap.set(
        "n",
        ",fs",
        "<CMD>Telescope live_grep<CR>",
        { silent = true, noremap = true, desc = "Find string with Grep" }
      )
      vim.keymap.set(
        "n",
        ",fw",
        function() telescope_builtin.grep_string({ search = vim.fn.expand("<cword>") }) end,
        { silent = true, noremap = true, desc = "Find word under cursor" }
      )
      vim.keymap.set(
        "n",
        ",fW",
        function() telescope_builtin.grep_string({ search = vim.fn.expand("<cWORD>") }) end,
        { silent = true, noremap = true, desc = "Find WORD under cursor" }
      )
      vim.keymap.set(
        "n",
        ",ft",
        function() telescope_builtin.grep_string({ search = " TODO: " }) end,
        { silent = true, noremap = true, desc = "Find TODO comments" }
      )
      vim.keymap.set(
        "n",
        ",fr",
        function() telescope_builtin.resume() end,
        { silent = true, noremap = true, desc = "Open last search result" }
      )
      vim.keymap.set(
        "n",
        ",fb",
        "<CMD>Telescope buffers<CR>",
        { silent = true, noremap = true, desc = "Buffers" }
      )
      vim.keymap.set(
        "n",
        ",fh",
        "<CMD>Telescope help_tags<CR>",
        { silent = true, noremap = true, desc = "Help tags" }
      )
      vim.keymap.set(
        "n",
        ",fd",
        "<CMD>Telescope diagnostics<CR>",
        { silent = true, noremap = true, desc = "LSP diagnostics" }
      )
      vim.keymap.set(
        "n",
        ",f?",
        "<CMD>Telescope builtin<CR>",
        { silent = true, noremap = true, desc = "Pickers" }
      )
    end,
  }, -- }}}
}
