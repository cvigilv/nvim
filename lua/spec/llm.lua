---@module "spec.llm"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

vim.pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/olimorris/codecompanion.nvim",
})

-- CodeCompanion
require("codecompanion").setup({
  strategies = {
    chat = { adapter = "copilot" },
    inline = { adapter = "copilot" },
  },
  display = {
    chat = {
      window = {
        layout = "buffer",
      },
    },
  },
})
