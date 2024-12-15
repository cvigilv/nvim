-- Setup completion sources
local cmp = require("cmp")

require("plugin.zk.cmp")
cmp.setup.filetype("markdown", {
  sources = cmp.config.sources({
    { name = "zk", group_index = 1 },
    { name = "buffer", group_index = 3 },
  }),
})

vim.o.textwidth = 96
