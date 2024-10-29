return {
  { "echasnovski/mini.base16" },
  { "echasnovski/mini.colors" },
  {
    "echasnovski/mini.starter",
    enabled = false,
    config = function()
      local generate_footer = function()
        local ls = require("lazy").stats()
        local n_updates = "0"
        if require("lazy.status").has_updates() then
          n_updates = require("lazy.status").updates():gsub("🔌", "")
        end
        return table.concat({
          "",
          "## Relevant keymaps",
          "",
          "- ,zc (New Zettelkasten note)",
          "- ,fz (Search note by title)",
          "- ,fZ (Search note by content)",
          "- ,ff (Search Git files)",
          "- ,fs (Search string using Grep)",
          "",
          "",
          "## Stats",
          "",
          "- Loaded "
            .. ls.loaded
            .. "/"
            .. ls.count
            .. " plugins in "
            .. ls.startuptime
            .. " miliseconds",
          "- " .. n_updates .. " plugins can be updated",
          -- -- TODO: Implement tasks finder and counter
          -- "- Tasks found in current directory: " .. "nil",
          "",
        }, "\n")
      end

      require("mini.starter").setup({
        -- Setup
        autoopen = true,
        evaluate_single = true,
        header = table.concat({
          -- "# mateo.nvim",
          -- "",
          "> mateo: someone who uses his head, smart guy (chilean slang)",
          "",
        }, "\n"),
        items = {
          -- Add prefix to section header
          function()
            local allfiles = require("mini.starter").sections.recent_files(10, true, true)()
            for _, file in ipairs(allfiles) do
              file.section = "## " .. file.section
            end
            return allfiles
          end,
        },
        footer = generate_footer,
        query_updaters = [[abcdefghijklmnopqrstuvwxyz0123456789_-.ABCDEFGHIJKLMNOPQRSTUVWXYZ]],
        content_hooks = {
          function(content)
            local blank_content_line = { { type = "empty", string = "" } }

            local section_coords = require("mini.starter").content_coords(content, "section")
            -- Insert backwards to not affect coordinates
            for i = #section_coords, 1, -1 do
              table.insert(content, section_coords[i].line + 1, blank_content_line)
            end

            return content
          end,
          require("mini.starter").gen_hook.adding_bullet("- "),
          require("mini.starter").gen_hook.aligning("center", "center"),
        },
      })
    end,
  },
  {
    "echasnovski/mini.ai",
    config = true,
    -- lazy = "VeryLazy",
  },
  {
    "echasnovski/mini.align",
    config = true,
    -- keys = { "ga", "gA" },
  },

  {
    "echasnovski/mini.bracketed",
    config = {
      file = { suffix = "", options = {} },
      indent = { suffix = "", options = {} },
      oldfile = { suffix = "", options = {} },
      treesitter = { suffix = "", options = {} },
      yank = { suffix = "", options = {} },
    },
    keys = {
      "[b",
      "]b",
      "[B",
      "]B",
      "[c",
      "]c",
      "[C",
      "]C",
      "[x",
      "]x",
      "[X",
      "]X",
      "[d",
      "]d",
      "[D",
      "]D",
      "[j",
      "]j",
      "[J",
      "]J",
      "[l",
      "]l",
      "[L",
      "]L",
      "[q",
      "]q",
      "[Q",
      "]Q",
      "[u",
      "]u",
      "[U",
      "]U",
      "[w",
      "]w",
      "[W",
      "]W",
    },
  },
  {
    "echasnovski/mini.indentscope",
    enabled = true,
    config = function()
      require("mini.indentscope").setup({
        draw = {
          delay = 100,
          priority = 2,
          animation = function(s, n) return s / n * 20 end,
        },
      })
    end,
    --   require("mini.indentscope").setup({
    --     draw = {
    --       delay = 0,
    --       animation = require("mini.indentscope").gen_animation.none(),
    --       priority = 2,
    --     },
    --     mappings = {
    --       -- Textobjects
    --       object_scope = "",
    --       object_scope_with_border = "",
    --       goto_top = "",
    --       goto_bottom = "",
    --     },
    --     options = {
    --       border = "both",
    --       indent_at_cursor = true,
    --       try_as_border = false,
    --     },
    --
    --     -- Which character to use for drawing scope indicator
    --     symbol = "╎",
    --   })
    -- end,
    event = "VeryLazy",
  },
  {
    "echasnovski/mini.comment",
    config = true,
    keys = {
      "gcc",
      "gc",
    },
  },
  {
    "echasnovski/mini.surround",
    config = true,
    keys = {
      "sa",
      "sd",
      "sf",
      "sF",
      "sh",
      "sr",
      "sn",
    },
  },
  {
    "echasnovski/mini.splitjoin",
    config = true,
    keys = { "gS" },
  },
  {
    "echasnovski/mini.hipatterns",
    config = function()
      local hl = require("mini.hipatterns")
      hl.setup({
        highlighters = {
          -- Highlight some keywords
          fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
          fix = { pattern = "%f[%w]()FIX()%f[%W]", group = "MiniHipatternsFixme" },
          hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
          perf = { pattern = "%f[%w]()PERF()%f[%W]", group = "MiniHipatternsHack" },
          todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
          note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
          philosophy = { pattern = "%f[%w]()PHILOSOPHY()%f[%W]", group = "MiniHipatternsNote" },

          -- Highlight hex color strings (`#rrggbb`) using that color
          hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
        },
      })
    end,
  },
}
