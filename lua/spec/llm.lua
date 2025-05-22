---@module "spec.llm"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      strategies = {
        chat = { adapter = "anthropic" },
        inline = { adapter = "anthropic" },
      },
      display = {
        chat = {
          window = {
            layout = "buffer",
          },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = {
      "CodeCompanion",
      "CodeCompanionChat",
      "CodeCompanionCmd",
      "CodeCompanionActions",
    },
  },
}
