---@diagnostic disable: assign-type-mismatch

local function get_visual_selection()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return table.concat(lines, "\n")
end

return {
  {
    -- dir = os.getenv("GITDIR") .. "/orgmode",
    "nvim-orgmode/orgmode",
    dependencies = {
      "danilshvalov/org-modern.nvim",
    },
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

      -- Setup orgmode
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
          capture = {
            -- org_capture_finalize =  "<C-c>" ,
            -- org_capture_refile =  "<leader>or" ,
            -- org_capture_kill =  "<C-x>" ,
            -- org_capture_show_help = "g?",
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
        org_agenda_files = {
          "~/org/agenda/*",
          "~/org/calendar/*",
          "~/org/journal/*",
          "~/org/refile.org",
        },
        org_default_notes_file = "~/org/refile.org",
        org_archive_location = "~/org/archive/archive_%s",
        org_startup_folded = "content",
        org_capture_templates = {
          x = {
            description = "Contact",
            target = "~/org/rolodex.org",
            template = "* %?\n:PROPERTIES:\n:NICKNAME:\n:DISPLAYNAME:\n:END:\n",
            properties = { empty_lines = 1 },
          },
          c = {
            description = "Code",
            target = "~/org/refile.org",
            template = [[**** %U %?
                %a
            ]],
            properties = { empty_lines = 1 },
          },
          P = {
            description = "Journal - Personal",
            datetree = true,
            target = "~/org/journal/personal.org",
            template = "**** %U\n%?",
            properties = { empty_lines = 1 },
          },
          p = {
            description = "Journal - PhD",
            datetree = true,
            target = "~/org/journal/phd.org",
            template = "**** %U\n%?",
            properties = { empty_lines = 1 },
          },
          w = {
            description = "Journal - Work",
            datetree = true,
            target = "~/org/journal/work.org",
            template = "**** %U\n%?",
            properties = { empty_lines = 1 },
          },
          ---@diagnostic disable-next-line: assign-type-mismatch
          i = {
            description = "Note - Idea",
            target = "~/org/notes/%<%Y%m%d%s>.org",
            template = "* %? :idea:",
            properties = { empty_lines = 1 },
          },
          r = {
            description = "Note - Reference",
            target = "~/org/notes/%<%Y%m%d%s>.org",
            template = "#+TAGS: PAPER(p) REVIEW(r) BLOG(b) OTHER(?)\n* %? :reference:",
            properties = { empty_lines = 1 },
          },
          ---@diagnostic disable-next-line: assign-type-mismatch
          e = "Event",
          er = {
            description = "Recurring",
            template = "** %?\n %T",
            target = "~/org/calendar/local.org",
            headline = "Recurring",
            properties = { empty_lines = 1 },
          },
          eo = {
            description = "One-time",
            template = "** %?\n %T",
            target = "~/org/calendar/local.org",
            headline = "One-time",
            properties = { empty_lines = 1 },
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
          "BLOCKED(b)",
          "|",
          "DONE(d)",
          "CANCELED(c)",
          "INACTIVE(i)",
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

        ui = {
          menu = {
            handler = function(data)
              Menu:new({
                window = {
                  margin = { 1, 0, 1, 0 },
                  padding = { 0, 1, 0, 1 },
                  title_pos = "center",
                  border = "single",
                  zindex = 1000,
                },
                icons = {
                  separator = "➜",
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
  {
    "nvim-orgmode/telescope-orgmode.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-orgmode/orgmode",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").load_extension("orgmode")

      vim.keymap.set(
        "n",
        "<leader>zr",
        function()
          require("telescope").extensions.orgmode.refile_heading(
            require("telescope.themes").get_ivy({})
          )
        end,
        { desc = "Refile heading" }
      )
      vim.keymap.set(
        "n",
        "<leader>zf",
        function()
          require("telescope").extensions.orgmode.search_headings(
            require("telescope.themes").get_ivy({})
          )
        end,
        { desc = "Search headlings" }
      )
      vim.keymap.set(
        "n",
        "<leader>zi",
        function()
          require("telescope").extensions.orgmode.insert_link(
            require("telescope.themes").get_ivy({})
          )
        end,
        { desc = "Insert link" }
      )
    end,
  },
  {
    "michhernand/RLDX.nvim",
    enabled=false,
    ft = "org",
    dependencies = {
      "hrsh7th/nvim-cmp",
    },
    config = function()
      -- Setup rolodex
      require("rldx").setup({
        prefix_char = "&",
        filename = vim.fn.stdpath("config") .. "/extras/rolodex.json",
        schema_ver = "latest",
      })

      -- Better highlight group
      vim.cmd([[hi! link RolodexHighlight Constant]])
      vim.cmd([[hi! link RolodexPattern Constant]])

      -- Setupo completion
      require("cmp").setup.filetype("org", {
        sources = {
          { name = "cmp_rolodex" },
          { name = "omni" },
        },
      })
    end,
    keys = {
      { "<leader>oxa", "<cmd>RldxAdd<CR>" },
      { "<leader>oxl", "<cmd>RldxLoad<CR>" },
      { "<leader>oxs", "<cmd>RldxSave<CR>" },
      { "<leader>oxd", "<cmd>RldxDelete<CR>" },
    },
  },
}
