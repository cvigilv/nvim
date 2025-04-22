return {
  -- quicker.nvim {{{
  {
    "stevearc/quicker.nvim",
    event = "FileType qf",
    opts = {
      opts = {
        buflisted = false,
        colorcolumn = "",
        number = true,
        relativenumber = false,
        signcolumn = "auto",
        winfixheight = true,
        wrap = false,
        winfixbuf = true,
      },
      keys = {
        {
          ">",
          function()
            require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
          end,
          desc = "Expand quickfix context",
        },
        {
          "<",
          function() require("quicker").collapse() end,
          desc = "Collapse quickfix context",
        },
      },
    },
  }, --}}}
{ "oonamo/ef-themes.nvim" },
}
