---@module "after.plugin.ui.colorscheme"
---@author Carlos Vigil-Vásquez
---@license MIT 2024-2025

-- Synchronize color scheme with system
local theme = vim.fn.system("defaults read -g AppleInterfaceStyle"):gsub("\n", "")
local colorscheme = "zenbones"
if theme == "Dark" then
  colorscheme = "neobones"
  vim.o.background = "dark"
else
  vim.o.background = "light"
end

-- Color scheme overrides
vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = { "zen*", "*bones" },
  callback = function(ev)
    local lush = require("lush")
    local base = require(ev.match)

    local function modify_colorscheme()
      -- Detect current background for out-of-bounds regions
      local bg = vim.api.nvim_get_option_value("background", { scope = "global" }) == "dark"
          and "#000000"
        or "#ffffff"
      local specs = lush.parse(
        function()
          return {
            OutOfBounds({ bg = base.NormalNC.bg }),
            Folded({}),
            MsgArea({ bg = bg }),
            ModeArea({ bg = bg }),
            TabLineFill({ bg = bg }),
            NormalFloat({ base.Normal }),
            NormalNC({ base.Normal }),
            StatusLine({ base.StatusLine, bold = true }),
            StatusLineNC({ base.StatusLineNC, italic = true }),
          }
        end
      )
      -- Apply specs using lush tool-chain
      lush.apply(lush.compile(specs))
    end
    modify_colorscheme()

    vim.api.nvim_create_autocmd("OptionSet", {
      pattern = "background",
      callback = modify_colorscheme,
      group = vim.api.nvim_create_augroup("carlos::colorscheme", { clear = true }),
    })
  end,
})

-- Differentiate plugin files with lighter/darker backgrounds
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = { "/private/*.org", "*\\[CodeCompanion\\]*", "oil://*" },
  callback = function(ev)
    vim.api.nvim_set_option_value(
      "winhighlight",
      "Normal:OutOfBounds",
      { scope = "local", win = vim.api.nvim_get_current_win() }
    )

    vim.api.nvim_create_autocmd("BufWinLeave", {
      pattern = ev.match,
      callback = function()
        vim.api.nvim_set_option_value(
          "winhighlight",
          "",
          { scope = "local", win = vim.api.nvim_get_current_win() }
        )
      end,
      once = true,
    })
  end,
})

vim.cmd("colorscheme " .. colorscheme)
