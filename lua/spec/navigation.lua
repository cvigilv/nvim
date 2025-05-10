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
          layout_config = { height = 0.4, width = 0.8 },
          initial_mode = "insert",
          selection_strategy = "reset",
          sorting_strategy = "ascending",
          path_display = { "truncate = 3", "smart" },
          previewer=false,
        }),
        pickers = {
          find_files = { prompt_title = "   Find files   " },
          git_files = { prompt_title = "   Git files   " },
          live_grep = { prompt_title = "   Live Grep   " },
          builtin = { prompt_title = "   Pickers   ", previewer = false },
        },
      })
    end,
  }, -- }}}
}
