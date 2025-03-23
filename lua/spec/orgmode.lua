return {
  {
    "nvim-orgmode/orgmode",
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
        org_agenda_files = "~/org/agenda/*",
        org_default_notes_file = "~/org/refile.org",
        org_startup_folded="content",
        org_capture_templates = {
          j = {
            description = "Journal",
            template = "*** %<%Y-%m-%d> %<%A>\n%?",
            target = "~/org/journal/phd.org",
          },
        },

        org_indent_mode = "noindent",
        org_blank_before_new_entry = { heading = true, plain_list_item = false },
        org_hide_emphasis_markers = false,

        org_agenda_skip_scheduled_if_done = true,
        org_agenda_skip_deadline_if_done = true,
        org_agenda_span = 14,
        win_split_mode = "auto",
        org_todo_keywords = {
          "NEXT(n)",
          "TODO(t)",
          "WAITING(w)",
          "BLOCKED(b)",
          "SOMEDAY(s)",
          "PROJECT(p)",
          "|",
          "DONE(d)",
          "CANCELED(x)",
        },
        org_todo_keyword_faces = {
          NEXT = ":foreground " .. color_changed_bg .. " :background " .. color_changed_fg,
          -- TODO = ":foreground " .. color_remove_bg .. " :background " .. color_remove_fg,
          -- WAITING = ":foreground " .. color_remove_bg .. " :background " .. color_remove_fg,
          -- SOMEDAY = ":foreground " .. color_remove_bg .. " :background " .. color_remove_fg,
          -- PROJECT = ":foreground " .. color_remove_bg .. " :background " .. color_remove_fg,
          -- BLOCKED = ":foreground " .. color_remove_bg .. " :background " .. color_remove_fg,
          -- DONE = ":foreground " .. color_add_fg .. " :background " .. color_add_bg,
          -- CANCELED = ":foreground " .. color_add_fg .. " :background " .. color_add_bg,
        },
        --

        notifications = { enabled = true },
      })
    end,
  },
}
