-- Setup completion sources
local cmp = require("cmp")

require("plugin.zk.cmp")
cmp.setup.filetype("markdown", {
  sources = cmp.config.sources({
    { name = "zk", group_index = 1 },
    -- { name = "nvim_lsp", group_index = 2 },
  }),
})

vim.o.textwidth = 96
