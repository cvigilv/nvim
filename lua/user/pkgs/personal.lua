return {
  { -- claudio {{{
    dir = os.getenv("GITDIR") .. "/claudio.nvim",
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("claudio").setup({
        ---@diagnostic disable-next-line: missing-fields
        tools = {
          prompts_dir = vim.fn.stdpath("config") .. "/extras/prompts/tools/",
        },
      })

      vim.keymap.set("n", "<leader>cc", ":ClaudioChat<CR>", {})
    end,
  }, -- }}}
  { -- patana {{{
    dir = os.getenv("GITDIR") .. "/patana.nvim",
  }, -- }}}
  { -- esqueleto {{{
    dir = os.getenv("GITDIR") .. "/esqueleto.nvim",
    enabled = true,
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("esqueleto").setup({
        -- selector = require("esqueleto.selectors.telescope"),
        autouse = false,
        directories = {
          vim.fn.stdpath("config") .. "/extras/skeletons/protera",
          vim.fn.stdpath("config") .. "/extras/skeletons/personal",
        },
        wildcards = {
          expand = true,
          lookup = {
            ["gh-username"] = "cvigilv",
            ["zk-year"] = function() return string.sub(vim.fn.expand("%:t:r"), 1, 4) end,
            ["zk-month"] = function() return string.sub(vim.fn.expand("%:t:r"), 5, 6) end,
            ["zk-day"] = function() return string.sub(vim.fn.expand("%:t:r"), 7, 8) end,
          },
        },
        ---@diagnostic disable-next-line: missing-fields
        advanced = {
          ignored = { "^/private/*" },
        },
      })
    end,
  }, -- }}}
  { -- diferente {{{
    dir = os.getenv("GITDIR") .. "/diferente.nvim",
    ft = "gitcommit",
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("diferente").setup({
        ratio = "auto",
      })
    end,
  }, -- }}}
}
