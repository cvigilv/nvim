---@module "spec.pkm"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

return {
  { -- orgmode
    "nvim-orgmode/orgmode",
    dependencies = {
      "danilshvalov/org-modern.nvim",
      { -- RLDX
        "michhernand/RLDX.nvim",
        enabled = true,
        ft = "org",
        dependencies = { "hrsh7th/nvim-cmp" },
        keys = {
          { "<leader>oxa", "<cmd>RldxAdd<CR>" },
          { "<leader>oxl", "<cmd>RldxLoad<CR>" },
          { "<leader>oxs", "<cmd>RldxSave<CR>" },
          { "<leader>oxd", "<cmd>RldxDelete<CR>" },
        },
        config = function()
          -- Setup rolodex
          require("rldx").setup({
            prefix_char = "@",
            filename = vim.fn.stdpath("config") .. "/extras/rolodex.json",
            schema_ver = "latest",
          })

          -- Better highlight group
          vim.cmd([[hi! link RolodexHighlight @comment.warning]])
          vim.cmd([[hi! link RolodexPattern @comment.warning]])

          -- Setup completion
          require("cmp").setup.filetype("org", {
            sources = {
              { name = "cmp_rolodex", trigger_characters = { "@" } },
              { name = "omni" },
            },
          })
        end,
      },
      { -- denote
        dir = os.getenv("GITDIR") .. "denote.nvim",
        cmd = "Denote",
        ft = "org",
        event = {
          "BufRead *" .. vim.fs.abspath("~/org/") .. "*",
          "VeryLazy",
        },
        dependencies = {
          "nvim-telescope/telescope.nvim",
          "stevearc/oil.nvim",
        },
        keys = {},
        config = function()
          ---@type Denote.Configuration
          require("denote").setup({
            filetype = "org",
            directory = "/Users/carlos/Insync/itmightbecarlos@gmail.com/Google_Drive/org",
            prompts = { "title", "signature", "keywords" },
            integrations = {
              oil = true,
              telescope = {
                enabled = true,
                opts = require("telescope.themes").get_ivy({
                  layout_config = { height = 0.30 },
                  previewer = false,
                  prompt_prefix = "[Denote] ",
                  prompt_title = false,
                }),
              },
            },
          })
          vim.cmd([[
            hi def link DenoteDate      DiagnosticHint
            hi def link DenoteSignature DiagnosticError
            hi def link DenoteTitle     DiagnosticOK
            hi def link DenoteKeywords  DiagnosticWarning
            hi def link DenoteExtension Comment
          ]])
          vim.keymap.set(
            "n",
            "<leader>zf",
            ":Denote search<CR>",
            { desc = "Search Denote files" }
          )
          vim.keymap.set(
            "n",
            "<leader>zl",
            ":Denote insert-link<CR>",
            { desc = "Insert link to Denote files" }
          )
          vim.keymap.set("n", "<leader>zc", ":Denote note<CR>", { desc = "New Denote note" })
          vim.keymap.set(
            "n",
            "<leader>zr",
            ":Denote rename-file<CR>",
            { desc = "Rename current Denote note" }
          )
        end,
      },
    },
    ft = "org",
    keys = {
      "<leader>oa",
      "<leader>oc",
      { "<leader>oA", ":Org agenda g<CR>", "Open GTD calendar view" },
      { "<leader>oC", ":Org capture p<CR>", "Capture to PhD journal" },
    },
    cmd = "Org",
    event = "VeryLazy",
    config = function()
      -- Colors overrides
      local color_add_fg = "#475946"
      local color_add_bg = "#d4dbd1"
      local color_changed_fg = "#375570"
      local color_changed_bg = "#ced9e1"
      local color_remove_fg = "#70415e"
      local color_remove_bg = "#e3d2da"

      -- Extras
      local Menu = require("org-modern.menu")

      -- Setup
      require("orgmode").setup({
        mappings = {
          global = {
            org_agenda = ",oa",
            org_capture = ",oc",
          },
          agenda = {
            org_agenda_later = "f",
            org_agenda_earlier = "b",
            org_agenda_goto_today = ".",
            org_agenda_day_view = "vd",
            org_agenda_week_view = "vw",
            org_agenda_month_view = "vm",
            org_agenda_year_view = "vy",
            org_agenda_quit = "q",
            org_agenda_switch_to = "<CR>",
            org_agenda_goto = "<Tab>",
            org_agenda_goto_date = "gd",
            org_agenda_redo = "r",
            org_agenda_todo = "t",
            org_agenda_clock_in = "ci",
            org_agenda_clock_out = "co",
            org_agenda_clock_cancel = "cc",
            org_agenda_set_effort = "ce",
            org_agenda_clock_goto = "gc",
            org_agenda_clockreport_mode = "cr",
            org_agenda_priority = "p",
            org_agenda_priority_up = false,
            org_agenda_priority_down = false,
            org_agenda_archive = "<leader>A",
            org_agenda_toggle_archive_tag = "<leader>a",
            org_agenda_set_tags = "T",
            org_agenda_deadline = "sd",
            org_agenda_schedule = "ss",
            org_agenda_filter = "/",
            org_agenda_refile = "R",
            org_agenda_add_note = "N",
            org_agenda_show_help = "g?",
          },
          note = {
            org_note_finalize = "<C-c>",
            org_note_kill = "<C-x>",
          },
          org = {
            org_refile = false,
            org_timestamp_up_day = false,
            org_timestamp_down_day = false,
            org_timestamp_up = "<C-a>",
            org_timestamp_down = "<C-x>",
            org_change_date = "cid",
            org_todo = "<leader>ot",
            org_todo_prev = false,
            org_priority = "<leader>op",
            org_priority_up = "<leader>opa",
            org_priority_down = "<leader>opx",
            org_toggle_checkbox = "<leader>o<space>",
            -- org_toggle_heading = ",o*",
            -- org_open_at_point = ",oo",
            -- org_edit_special = ",o'",
            org_add_note = ",on",
            -- org_cycle = "<Tab>",
            -- org_global_cycle = "<S-Tab>",
            org_archive_subtree = "<leader>oA",
            org_set_tags_command = "<leader>oTT",
            org_toggle_archive_tag = "<leader>oTA",
            org_do_promote = { ">>", "<Right>" },
            org_do_demote = { "<<", "<Left>" },
            org_promote_subtree = { ">s", "<S-Right>" },
            org_demote_subtree = { "<s", "<S-Left>" },
            org_meta_return = { "<leader>oih", "<CR>" },
            org_insert_heading_respect_content = { ",oiH" },
            -- org_insert_todo_heading = "",
            -- org_insert_todo_heading_respect_content = "",
            org_move_subtree_up = { "<leader>oK", "<Up>" },
            org_move_subtree_down = { "<leader>oJ", "<Down>" },
            -- org_export = "",
            -- org_return = "",
            -- org_next_visible_heading = "",
            -- org_previous_visible_heading = "",
            -- org_forward_heading_same_level = "",
            -- org_backward_heading_same_level = "",
            -- outline_up_heading = "",
            org_deadline = "<leader>osd",
            org_schedule = "<leader>oss",
            org_time_stamp = "<leader>ost",
            org_time_stamp_inactive = false,
            org_toggle_timestamp_type = "<leader>osT",
            -- org_insert_link = "<leader>oli",
            -- org_store_link = "<leader>ols",
            org_clock_in = "<leader>oCi",
            org_clock_out = "<leader>oCo",
            org_clock_cancel = "<leader>oCc",
            org_clock_goto = "<leader>oCg",
            org_set_effort = "<leader>oCe",
            org_show_help = "g?",
            -- org_babel_tangle = "",
          },
        },

        org_adapt_indentation = false,
        org_agenda_files = "~/org/.org/**",
        org_default_notes_file = "~/org/.org/inbox.org",
        org_archive_location = "~/org/.archive/archive_%s",
        org_startup_folded = "content",
        org_capture_templates = {
          c = {
            description = "Journal - Personal",
            datetree = true,
            target = "~/org/" .. os.date("%Y") .. "0101T090000==logs--dailies__personal.org",
            template = "**** %U\n%?",
            ---@diagnostic disable-next-line: missing-fields
            properties = { empty_lines = 1 },
          },
          p = {
            description = "Journal - PhD",
            datetree = true,
            target = "~/org/" .. os.date("%Y") .. "0101T090001==logs--dailies__phd.org",
            template = "**** %U\n%?",
            ---@diagnostic disable-next-line: missing-fields
            properties = { empty_lines = 1 },
          },
          w = {
            description = "Journal - Work",
            datetree = true,
            target = "~/org/" .. os.date("%Y") .. "0101T090002==logs--dailies__work.org",
            template = "**** %U\n%?",
            ---@diagnostic disable-next-line: missing-fields
            properties = { empty_lines = 1 },
          },
          ---@diagnostic disable-next-line: assign-type-mismatch
          e = "Event",
          er = {
            description = "Recurring",
            template = "** %?\n %T",
            target = "~/org/.org/calendar/local.org",
            headline = "Recurring",
          },
          eo = {
            description = "One-time",
            template = "** %?\n %T",
            target = "~/org/.org/calendar/local.org",
            headline = "One-time",
          },
        },

        org_indent_mode = "noindent",
        org_blank_before_new_entry = { heading = true, plain_list_item = false },
        org_hide_emphasis_markers = false,
        org_tags_column = 80,

        org_log_into_drawer = "LOGBOOK",
        org_log_done = "note",
        org_log_repeat = "time",

        org_agenda_min_height = 24,
        win_split_mode = "auto",
        org_todo_keywords = {
          "NEXT(n)",
          "TODO(t)",
          "STOP(b)",
          "|",
          "DONE(d)",
          "CNCL(c)",
        },
        org_todo_keyword_faces = {
          NEXT = ":foreground " .. color_changed_bg .. " :background " .. color_changed_fg,
          TODO = ":foreground " .. color_remove_bg .. " :background " .. color_remove_fg,
          STOP = ":foreground " .. color_remove_bg .. " :background " .. color_remove_fg,
          DONE = ":foreground " .. color_add_fg .. " :background " .. color_add_bg,
          CNCL = ":foreground " .. color_add_fg .. " :background " .. color_add_bg,
        },

        notifications = {
          enabled = true,
          cron_enabled = true,
          repeater_reminder_time = true,
          deadline_warning_reminder_time = true,
          reminder_time = { 0, 15 },
          deadline_reminder = true,
          scheduled_reminder = true,
          notifier = function(tasks)
            for _, task in ipairs(tasks) do
              local title = string.format("%s (%s)", task.category, task.humanized_duration)
              local subtitle = string.format(
                "%s %s %s",
                string.rep("*", task.level),
                task.todo or "",
                task.title
              )
              local date = string.format("%s: %s", task.type, task.time:to_string())

              if vim.fn.executable("terminal-notifier") == 1 then
                vim.system({
                  "terminal-notifier",
                  "-title",
                  title,
                  "-subtitle",
                  subtitle,
                  "-message",
                  date,
                })
              end
            end
          end,
        },

        ui = {
          menu = {
            handler = function(data)
              data.title = " " .. data.title .. " "
              Menu:new({
                window = {
                  margin = { 1, 0, 1, 0 },
                  padding = { 0, 1, 0, 1 },
                  title_pos = "center",
                  border = "single",
                  zindex = 1000,
                },
                icons = {
                  separator = "->",
                },
              }):open(data)
            end,
          },
        },

        -- Agenda
        org_agenda_skip_scheduled_if_done = true,
        org_agenda_skip_deadline_if_done = true,
        org_agenda_block_separator = " ",
        org_agenda_custom_commands = {
          g = {
            description = "Getting Things Done (GTD)",
            types = {
              {
                type = "agenda",
                org_agenda_span = "day",
                org_agenda_todo_ignore_deadlines = "all",
                org_agenda_remove_tags = true,
              },
              {
                org_agenda_overriding_header = "Deadlines",
                type = "tags_todo",
                match = "DEADLINE>=\"<today>\"",
                org_agenda_remove_tags = true,
              },
              {
                org_agenda_overriding_header = "Tasks",
                type = "tags_todo",
                match = "TODO=\"NEXT\"",
                org_agenda_todo_ignore_deadlines = "all",
                org_agenda_todo_ignore_scheduled = "all",
                org_agenda_remove_tags = true,
              },
              {
                org_agenda_overriding_header = "Inbox",
                type = "tags_todo",
                match = "TODO=\"TODO\"",
                org_agenda_files = { "~/org/.org/inbox.org" },
                org_agenda_remove_tags = true,
              },
              {
                org_agenda_overriding_header = "Completed today",
                type = "tags",
                match = "CLOSED>=\"<today>\"",
                org_agenda_remove_tags = true,
              },
            },
          },
        },
      })
    end,
  },
}
