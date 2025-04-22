return {
  -- luapad {{{
  {
    "rafcamlet/nvim-luapad",
    keys = { "<leader>R" },
    ft = "lua",
  }, -- }}}
  -- anki.nvim {{{
  {
    "rareitems/anki.nvim",
    depedencies = { "nvim-lua/plenary.nvim" },
    opts = {
      models = {
        ["Basic"] = "french"
      }
    },
  },
  -- }}}
}
