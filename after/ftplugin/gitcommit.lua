-- Setup completion sources
local cmp = require("cmp")

cmp.setup.filetype("gitcommit", {
  sources = cmp.config.sources({
    { name = "git", group_index = 1 },
    { name = "omni", group_index = 2 },
    { name = "buffer", group_index = 3 },
  }),
})

require("cmp_git").setup()
