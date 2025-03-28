return {
  {
    dir = os.getenv("GITDIR") .. "/orgmode",
    event = "VeryLazy",
    ft = { "org" },
    config = function()
      -- Colors overrides
      local color_add_fg = "#475946"
      local color_add_bg = "#d4dbd1"
      local color_changed_fg = "#375570"
      local color_changed_bg = "#ced9e1"
      local color_remove_fg = "#70415e"
      local color_remove_bg = "#e3d2da"

      -- Setup orgmode
      require("orgmode").setup({
        org_agenda_files = "~/org/**/*",
        org_default_notes_file = "~/org/refile.org",
        org_startup_folded = "content",
        org_capture_templates = {
          j = {
            description = "Journal",
            datetree = true,
            target = "~/org/journal/%^{Journal|phd|personal}.org",
            template = "**** %U\n%?",
          },
          ---@diagnostic disable-next-line: assign-type-mismatch
          n = "Note",
          ni = {
            description = "Idea",
            target = "~/org/notes/%<%Y%m%d%s>.org",
            template = "* %? :idea:"
          },
          nr = {
            description = "Reference",
            target = "~/org/notes/%<%Y%m%d%s>.org",
            template = "#+TAGS: PAPER(p) REVIEW(r) BLOG(b) OTHER(?)\n* %? :reference:"
          },
          ---@diagnostic disable-next-line: assign-type-mismatch
          e = "Event",
          er = {
            description = "Recurring",
            template = "** %?\n %T",
            target = "~/org/calendar/local.org",
            headline = "Recurring",
          },
          eo = {
            description = "One-time",
            template = "** %?\n %T",
            target = "~/org/calendar/local.org",
            headline = "One-time",
          },
        },

        org_indent_mode = "noindent",
        org_blank_before_new_entry = { heading = true, plain_list_item = false },
        org_hide_emphasis_markers = false,
        org_tags_column=80,

        org_log_into_drawer="LOGBOOK",
        org_log_done = "note",
        org_log_repeat = "time",

        org_agenda_min_height=24,
        win_split_mode = "auto",
        org_todo_keywords = {
          "NEXT(n)",
          "TODO(t)",
          "BLOCKED(b)",
          "|",
          "DONE(d)",
          "CANCELED(c)",
          "INACTIVE(i)"
        },
        org_todo_keyword_faces = {
          NEXT = ":foreground " .. color_changed_bg .. " :background " .. color_changed_fg,
          TODO = ":foreground " .. color_remove_bg .. " :background " .. color_remove_fg,
          BLOCKED = ":foreground " .. color_remove_bg .. " :background " .. color_remove_fg,
          DONE = ":foreground " .. color_add_fg .. " :background " .. color_add_bg,
          CANCELED = ":foreground " .. color_add_fg .. " :background " .. color_add_bg,
          INACTIVE = ":foreground " .. color_add_fg .. " :background " .. color_add_bg,
        },

        notifications = { enabled = true },

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
                type = "tags_todo",
                match = "TODO=\"NEXT\"",
                org_agenda_todo_ignore_deadlines = "all",
                org_agenda_overriding_header = "Tasks",
              },
              {
                type = "tags_todo",
                match = "DEADLINE>=\"<today>\"",
                org_agenda_overriding_header = "Deadlines",
              },
              {
                type = "tags_todo",
                match = "TODO=\"TODO\"",
                org_agenda_files = { "~/org/refile.org" },
                org_agenda_overriding_header = "Inbox",
              },
              {
                type = "tags",
                match = "CLOSED>=\"<today>\"",
                org_agenda_overriding_header = "Completed today",
              },
            },
          },
        },
      })
    end,
  },
}
