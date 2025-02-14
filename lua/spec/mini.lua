return {
  {
    "echasnovski/mini.nvim",
    config = function()
      -- mini.ai {{{1
      require("mini.ai").setup()
      -- mini.align {{{1
      require("mini.align").setup()
      -- mini.bracketed {{{1
      require("mini.bracketed").setup({
        file = { suffix = "", options = {} },
        indent = { suffix = "", options = {} },
        oldfile = { suffix = "", options = {} },
        treesitter = { suffix = "", options = {} },
        yank = { suffix = "", options = {} },
      })
      -- mini.indentscope {{{1
      require("mini.indentscope").setup({
        draw = {
          delay = 100,
          priority = 2,
          animation = function(s, n) return s / n * 10 end,
        },
      })
      -- mini.comment {{{1
      require("mini.comment").setup()
      -- mini.surround {{{1
      require("mini.surround").setup()
      -- mini.splitjoin {{{1
      require("mini.splitjoin").setup()
      require("mini.hipatterns").setup({
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
    end, --}}}
  },
}
