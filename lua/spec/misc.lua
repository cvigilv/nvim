return {
  -- luapad {{{
  {
    "rafcamlet/nvim-luapad",
    keys = { "<leader>R" },
    ft = "lua",
  }, -- }}}
  -- snacks.nvim {{{
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      image = {},
    },
  }, --}}}
}
