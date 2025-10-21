---@module "spec.qol"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

vim.pack.add({
  "https://github.com/nvim-mini/mini.nvim",
})

require("mini.ai").setup()
-- TODO: Add line number coloring
require("mini.diff").setup()
require("mini.align").setup()
require("mini.bracketed").setup({
  file = { suffix = "", options = {} },
  indent = { suffix = "", options = {} },
  oldfile = { suffix = "", options = {} },
  treesitter = { suffix = "", options = {} },
  yank = { suffix = "", options = {} },
})
require("mini.completion").setup()
require("mini.comment").setup()
require("mini.surround").setup()
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
