-- Setup completion sources
local cmp = require("cmp")

-- require("cardex.cmp")
cmp.setup.filetype("markdown", {
  sources = cmp.config.sources({
    -- { name = "cardex", group_index = 1 },
    { name = "nvim_lsp", group_index = 1 },
  }),
})

vim.o.textwidth = 96
