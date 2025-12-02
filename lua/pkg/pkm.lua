---@module "spec.pkm"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

return {
  { -- orgmode
    "nvim-orgmode/orgmode",
    config = function()
      local function hlgroup2org(hlgroup)
        local normal = require("lib.colors").get_hlgroup_table("Normal") --[[@as table]]
        local hl = require("lib.colors").get_hlgroup_table(hlgroup) --[[@as table]]

        return ":foreground " .. (hl.fg or normal.fg) .. " :background " .. (hl.bg or normal.bg)
      end

      -- Setup
      require("orgmode").setup({
        hyperlinks = {
          sources = {
            require("denote.extensions.orgmode"):new({
              files = vim.g.denote.directory --[[@as OrgFiles]],
            }),
          },
        },
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
            org_agenda_clock_in = "xi",
            org_agenda_clock_out = "xo",
            org_agenda_clock_cancel = "xc",
            org_agenda_set_effort = "xe",
            org_agenda_clock_goto = "xg",
            org_agenda_clockreport_mode = "xr",
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
            org_refile = "<leader>or",
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
            org_clock_in = "<leader>oxi",
            org_clock_out = "<leader>oxo",
            org_clock_cancel = "<leader>oxc",
            org_clock_goto = "<leader>oxg",
            org_set_effort = "<leader>oxe",
            org_show_help = "g?",
            -- org_babel_tangle = "",
          },
        },

        org_adapt_indentation = false,
        org_agenda_files = {
          "~/org/.org/inbox.org",
          "~/org/.org/projects.org",
          "~/org/.org/calendar/*.org",
          "~/org/*==logs*.org",
        },
        org_default_notes_file = "~/org/.org/inbox.org",
        org_archive_location = "~/org/.archive/archive_%s",
        org_startup_folded = "overview",
        org_capture_templates = {
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
        org_hide_emphasis_markers = true,
        org_tags_column = 80,

        org_log_into_drawer = "LOGBOOK",
        org_log_done = "note",
        org_log_repeat = "time",

        org_agenda_min_height = 24,
        win_split_mode = "auto",
        org_todo_keywords = {
          "NEXT(n)",
          "TODO(t)",
          "PROG(p)",
          "INTR(i)",
          "|",
          "DONE(d)",
          "CNCL(c)",
        },
        org_todo_keyword_faces = {
          TODO = hlgroup2org("DiagnosticVirtualTextError"),
          NEXT = hlgroup2org("DiagnosticVirtualTextInfo"),
          PROG = hlgroup2org("DiagnosticVirtualTextWarn"),
          INTR = hlgroup2org("DiagnosticVirtualTextWarn"),
          DONE = hlgroup2org("DiagnosticVirtualTextOk"),
          CNCL = hlgroup2org("DiagnosticVirtualTextOk"),
        },

        -- Agenda
        org_agenda_block_separator = " ",
        org_agenda_time_grid = {
          type = { "daily", "today" },
          times = { 800, 1000, 1200, 1400, 1600, 1800, 2000 },
          time_separator = "      ",
          time_label = string.rep("·", 48),
        },
        org_agenda_current_time_string = "· now " .. string.rep("·", 42),
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
                org_agenda_overriding_header = "Interuption",
                type = "tags_todo",
                match = "TODO=\"INTR\"",
              },
              {
                org_agenda_overriding_header = "Deadlines",
                type = "tags_todo",
                match = "DEADLINE>=\"<2w>\"",
                org_agenda_remove_tags = true,
              },
              {
                org_agenda_overriding_header = "In progress",
                type = "tags_todo",
                match = "TODO=\"PROG\"",
                org_agenda_todo_ignore_scheduled = "all",
                org_agenda_remove_tags = true,
              },
              {
                org_agenda_overriding_header = "Tasks",
                type = "tags_todo",
                match = "TODO=\"NEXT\"",
                org_agenda_todo_ignore_deadlines = "all",
                org_agenda_todo_ignore_scheduled = "all",
                org_agenda_remove_tags = true,
                org_agenda_files = {
                  "~/org/.org/inbox.org",
                  "~/org/.org/projects.org",
                  "~/org/.org/calendar/*.org",
                  "~/org/*==logs*.org",
                },
              },
              {
                org_agenda_overriding_header = "Inbox",
                type = "tags_todo",
                match = "TODO=\"TODO\"",
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
        org_agenda_skip_scheduled_if_done = true,
        org_agenda_skip_deadline_if_done = true,
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
      })
    end,
  },
  { -- denote
    dir = os.getenv("GITDIR") .. "denote.nvim",
    event = {
      "BufRead *" .. vim.fs.abspath("~/org/") .. "*",
    },
    command = "Denote",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "stevearc/oil.nvim",
    },
    init = function()
      -- Setup Denote
      ---@type Denote.Configuration
      vim.g.denote = {
        filetype = "org",
        directory = "/Users/carlos/Insync/itmightbecarlos@gmail.com/Google_Drive/org",
        prompts = { "title", "signature", "keywords" },
      }

      -- Add Telescope pickers
      require("telescope").load_extension("denote")

      -- Override default highlight groups
      vim.cmd([[
            hi! def link DenoteDate      Number
            hi! def link DenoteSignature Type
            hi! def link DenoteTitle     Title
            hi! def link DenoteKeywords  WarningMsg
            hi! def link DenoteExtension SpecialComment
          ]])
    end,
  },
}
