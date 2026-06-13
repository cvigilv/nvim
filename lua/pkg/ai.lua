-- Copilot
vim.g.copilot_filetypes = { ["*"] = false }
vim.keymap.set("i", "<C-]>", "<Plug>(copilot-suggest)", {desc = "Trigger Copilot suggestion"})

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
