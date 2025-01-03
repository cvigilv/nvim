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

      -- Keybindings
      local opts = { noremap = true, silent = true }

      vim.keymap.set({ "t", "n" }, "<C-h>", require("Navigator").left, opts)
      vim.keymap.set({ "t", "n" }, "<C-k>", require("Navigator").up, opts)
      vim.keymap.set({ "t", "n" }, "<C-l>", require("Navigator").right, opts)
      vim.keymap.set({ "t", "n" }, "<C-j>", require("Navigator").down, opts)
      vim.keymap.set({ "t", "n" }, "<C-p>", require("Navigator").previous, opts)
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

      vim.keymap.set("n", "<leader><CR>", require("oil").open, {
        desc = "File browser",
        noremap = true,
        silent = true,
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
      vim.keymap.set(
        "n",
        "<Space>fa",
        function() harpoon:list():add() end,
        { desc = "Add file" }
      )
      vim.keymap.set(
        "n",
        "<Space>ff",
        function()
          harpoon.ui:toggle_quick_menu(harpoon:list(), {
            border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
            title = " Harpoon ",
            title_pos = "left",
            ui_width_ratio = 0.33,
          })
        end,
        { desc = "Toggle quick menu" }
      )

      vim.keymap.set(
        "n",
        "[h",
        function() harpoon:list():prev() end,
        { desc = "Previous harpoon buffer" }
      )
      vim.keymap.set(
        "n",
        "]h",
        function() harpoon:list():next() end,
        { desc = "Next harpoon buffer" }
      )

      for i, key in ipairs({ "h", "j", "k", "l" }) do
        vim.keymap.set(
          "n",
          "<Space>f" .. key,
          function() harpoon:list():select(i) end,
          { desc = "Select buffer #" .. key }
        )
      end

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
          layout_config = {
            bottom_pane = {
              height = 0.4,
              prompt_position = "top",
              preview_width = 0.6,
            },
          },
          winblend = 0,
          border = true,
          borderchars = { "▔", "▕", "▁", "▏", "🭽", "🭾", "🭿", "🭼" },
          buffer_previewer_maker = intelligent_previewer,
        },
        pickers = {
          find_files = { prompt_title = "   Find files   " },
          git_files = { prompt_title = "   Git files   " },
          live_grep = { prompt_title = "   Live Grep   " },
          builtin = { prompt_title = "   Pickers   ", previewer = false },
        },
      })

      -- Keymaps
      local builtin = require("telescope.builtin")
      vim.keymap.set(
        "n",
        ",ff",
        M.project_files,
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
        function() builtin.grep_string({ search = vim.fn.expand("<cword>") }) end,
        { silent = true, noremap = true, desc = "Find word under cursor" }
      )
      vim.keymap.set(
        "n",
        ",fW",
        function() builtin.grep_string({ search = vim.fn.expand("<cWORD>") }) end,
        { silent = true, noremap = true, desc = "Find WORD under cursor" }
      )
      vim.keymap.set(
        "n",
        ",ft",
        function() builtin.grep_string({ search = " TODO: " }) end,
        { silent = true, noremap = true, desc = "Find TODO comments" }
      )
      vim.keymap.set(
        "n",
        ",fr",
        function() builtin.resume() end,
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
        "<CMD>Telescope pickers<CR>",
        { silent = true, noremap = true, desc = "Pickers" }
      )
    end,
  }, -- }}}
}
