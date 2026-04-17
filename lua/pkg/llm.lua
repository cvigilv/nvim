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
