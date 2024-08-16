return {
  { -- claudio {{{
    dir = os.getenv("GITDIR") .. "/claudio.nvim",
    config = true,
    opts = {},
  }, -- }}}
  { -- patana {{{
    dir = os.getenv("GITDIR") .. "/patana.nvim",
    priority = 1000,
    config = function()
      -- Setup colorscheme
      vim.g.patana_primary_color = "oranges"
      vim.g.patana_secondary_color = "greens"
      vim.g.patana_accent_color = "purples"
      vim.g.patana_colored_statusline = false

      vim.cmd.colorscheme("patana")

      -- Set background based on current time
      local current_hr = tonumber(os.date("%H", os.time()))
      if current_hr > 6 and current_hr < 18 then
        vim.cmd("set bg=light")
      else
        vim.cmd("set bg=dark")
      end
    end,
  }, -- }}}
  { -- esqueleto {{{
    dir = os.getenv("GITDIR") .. "/esqueleto.nvim",
    enabled = true,
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("esqueleto").setup({
        autouse = false,
        directories = { vim.fn.stdpath("config") .. "/skeletons" },
        patterns = vim.fn.readdir(vim.fn.stdpath("config") .. "/skeletons"),
        wildcards = {
          expand = true,
          lookup = {
            ["gh-username"] = "cvigilv",
            ["zk-year"] = function() return string.sub(vim.fn.expand("%:t:r"), 1, 4) end,
            ["zk-month"] = function() return string.sub(vim.fn.expand("%:t:r"), 5, 6) end,
            ["zk-day"] = function() return string.sub(vim.fn.expand("%:t:r"), 7, 8) end,
          },
        },
      })
    end,
  }, -- }}}
  { -- diferente {{{
    dir = os.getenv("GITDIR") .. "/diferente.nvim",
    ft = "gitcommit",
    config = true,
  }, -- }}}
}
