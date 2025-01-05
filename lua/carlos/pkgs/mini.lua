return {
  {
    "echasnovski/mini.ai",
    config = true,
    lazy = "VeryLazy",
  },
  {
    "echasnovski/mini.align",
    config = true,
    event = "VeryLazy",
  },

  {
    "echasnovski/mini.bracketed",
    event = "VeryLazy",
    config = {
      file = { suffix = "", options = {} },
      indent = { suffix = "", options = {} },
      oldfile = { suffix = "", options = {} },
      treesitter = { suffix = "", options = {} },
      yank = { suffix = "", options = {} },
    },
  },
  {
    "echasnovski/mini.indentscope",
    event = "VeryLazy",
    config = function()
      require("mini.indentscope").setup({
        draw = {
          delay = 100,
          priority = 2,
          animation = function(s, n) return s / n * 20 end,
        },
      })
    end,
  },
  {
    "echasnovski/mini.comment",
    config = true,
    event = "VeryLazy",
  },
  {
    "echasnovski/mini.surround",
    config = true,
    event = "VeryLazy",
  },
  {
    "echasnovski/mini.splitjoin",
    config = true,
    event = "VeryLazy",
  },
  {
    "echasnovski/mini.hipatterns",
    event = "VeryLazy",
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
