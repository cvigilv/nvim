-- Setup completion sources
local cmp = require("cmp")

cmp.setup.filetype("tex", {
  sources = cmp.config.sources({
    { name = "omni", group_index = 1 },
    { name = "buffer", group_index = 2 },
  }),
})