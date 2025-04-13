return {
  { -- Navigator {{{
    "numToStr/Navigator.nvim",
    keys = {
      "<C-h>",
      "<C-k>",
      "<C-l>",
      "<C-j>",
      "<C-p>",
    },
    config = function()
      require("Navigator").setup({
        auto_save = nil,
        disable_on_zoom = true,
      })
    end,
  }, -- }}}
  { -- oil {{{
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup({
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
        -- Set to false to disable all of the above keymaps
        use_default_keymaps = false,
      })
    end,
  }, -- }}}
  { -- harpoon {{{
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    keys = {
      "<Space>fa",
      "<Space>fh",
      "<Space>fj",
      "<Space>fk",
      "<Space>fl",
      "<Space>ff",
      "]h",
      "[h",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup(
        -- @as HarpoonPartialConfig
        {
          setting = {
            get_root_dir = function()
              local cwd = ""
              if vim.b.gitsigns_status_dict ~= nil then
                cwd = vim.b.gitsigns_status_dict["root"]
              else
                ---FIXME: Why are vim.loop methods not found?
                ---@diagnostic disable-next-line: undefined-field
                cwd = vim.loop.cwd() or ""
              end
              return cwd
            end,
          },
        }
      )

      -- Keymaps
      harpoon:extend({
        UI_CREATE = function(cx)
          vim.keymap.set(
            "n",
            "|",
            function() harpoon.ui:select_menu_item({ vsplit = true }) end,
            { buffer = cx.bufnr, desc = "Open in vertical split" }
          )

          vim.keymap.set(
            "n",
            "-",
            function() harpoon.ui:select_menu_item({ split = true }) end,
            { buffer = cx.bufnr, desc = "Open in split" }
          )

          vim.keymap.set(
            "n",
            "<C-t>",
            function() harpoon.ui:select_menu_item({ tabedit = true }) end,
            { buffer = cx.bufnr, desc = "Open in tab" }
          )
        end,
      })
    end,
  }, -- }}}
  { -- telescope {{{
    "nvim-telescope/telescope.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    -- cmd = "Telescope",
    -- keys = {
    --   "<leader>ff",
    --   "<leader>fs",
    --   "<leader>fw",
    --   "<leader>fW",
    --   "<leader>fb",
    --   "<leader>fd",
    --   "<leader>fh",
    --   "<leader>f?",
    --   "<leader>fz",
    --   "<leader>fZ",
    -- },
    config = function()
      local previewers = require("telescope.previewers")
      local Job = require("plenary.job")

      local M = {}

      -- Intelligent find files
      M.project_files = function(opts)
        local ok = pcall(require("telescope.builtin").git_files, opts)
        if not ok then require("telescope.builtin").find_files(opts) end
      end

      -- Intelligent previewer
      local intelligent_previewer = function(filepath, bufnr, opts)
        filepath = vim.fn.expand(filepath)
        ---@diagnostic disable-next-line: missing-fields
        Job:new({
          command = "file",
          args = { "--mime-type", "-b", filepath },
          on_exit = function(j)
            local mime_type = vim.split(j:result()[1], "/")[1]
            if mime_type == "text" then
              previewers.buffer_previewer_maker(filepath, bufnr, opts)
            else
              vim.schedule(
                function()
                  vim.api.nvim_buf_set_lines(
                    bufnr,
                    0,
                    -1,
                    false,
                    { "Binary file - Can't preview..." }
                  )
                end
              )
            end
          end,
        }):sync()
      end

      -- Setup
      require("telescope").setup({
        defaults = {
          prompt_prefix = "? ",
          selection_prefix = "  ",
          multi_icon = "!",
          initial_mode = "insert",
          selection_strategy = "reset",
          sorting_strategy = "ascending",
          path_display = { "truncate = 3", "smart" },
          layout_strategy = "bottom_pane",
          winblend = 0,
          border = true,
          buffer_previewer_maker = intelligent_previewer,
        },
        pickers = {
          find_files = { prompt_title = "   Find files   ", theme="ivy" },
          git_files = { prompt_title = "   Git files   ", theme="ivy" },
          live_grep = { prompt_title = "   Live Grep   ", theme="ivy" },
          builtin = { prompt_title = "   Pickers   ", previewer = false, theme="ivy" },
        },
      })
    end,
  }, -- }}}
}
