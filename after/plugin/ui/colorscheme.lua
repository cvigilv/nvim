---@module "after.plugin.ui.colorscheme"
---@author Carlos Vigil-Vásquez
---@license MIT 2024-2025

vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = {"zenbones", "neobones"},
  callback = function()
    local lush = require("lush")

    local bg = vim.opt.bg == "dark" and "#000000" or "#ffffff"

    local specs = lush.parse(
      function()
        return {
          Folded({}),
          MsgArea({ bg = bg }),
          ModeArea({ bg = bg }),
          TabLineFill({ bg = bg }),
        }
      end
    )
    -- Apply specs using lush tool-chain
    lush.apply(lush.compile(specs))
  end,
})

vim.cmd("colorscheme zenbones")
