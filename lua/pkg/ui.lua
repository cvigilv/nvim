-- Zenbones and friends
vim.g.zenbones_lightness = "bright"
vim.g.zenbones_darkness = "stark"
vim.g.zenbones_lighten_noncurrent_window = true
vim.g.zenbones_darken_noncurrent_window = true
vim.g.zenbones_colorize_diagnostic_underline_text = true

vim.g.neobones_lightness = "bright"
vim.g.neobones_darkness = "stark"
vim.g.neobones_lighten_noncurrent_window = true
vim.g.neobones_darken_noncurrent_window = true
vim.g.neobones_colorize_diagnostic_underline_text = true

vim.g.zenwritten_lightness = "bright"
vim.g.zenwritten_darkness = "stark"
vim.g.zenwritten_lighten_noncurrent_window = true
vim.g.zenwritten_darken_noncurrent_window = true
vim.g.zenwritten_colorize_diagnostic_underline_text = true

-- Customizations
local augroup = vim.api.nvim_create_augroup("zenbones", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  desc = "Override color scheme",
  pattern = { "zen*", "*bones" },
  callback = function(ev)
    local lush = require("lush")
    local base = require(ev.match)

    local function modify_colorscheme()
      -- Detect current background for out-of-bounds regions
      local is_dark = vim.o.background == "dark"
      local bg = is_dark and "#000000" or "#ffffff"

      local specs = lush.parse(
        function()
          return {
            OutOfBounds({ bg = base.NormalNC.bg }),
            Folded({}),
            MsgArea({ bg = bg }),
            ModeArea({ bg = bg }),
            TabLineFill({ bg = bg }),
            NormalFloat({ bg = base.NormalNC.bg }),
            FloatBorder({ fg = base.Normal.bg, bg = base.NormalNC.bg }),
            NormalNC({ base.Normal }),
            StatusLine({ base.StatusLine, bold = true }),
            StatusLineNC({ base.StatusLineNC, italic = true }),
          }
        end
      )
      -- Apply specs using lush tool-chain
      lush.apply(lush.compile(specs))

      vim.cmd("hi! link @org.keyword.face.TODO DiagnosticVirtualTextError")
      vim.cmd("hi! link @org.keyword.face.NEXT DiagnosticVirtualTextHint")
      vim.cmd("hi! link @org.keyword.face.PROG DiagnosticVirtualTextWarn")
      vim.cmd("hi! link @org.keyword.face.DONE DiagnosticVirtualTextOk")
      vim.cmd("hi! link @org.keyword.face.CNCL DiagnosticVirtualTextOk")
      vim.cmd(
        "hi! @org.keyword.face.INTR.org ctermbg=0 ctermfg=255 guibg=#000000 guifg=#ffffff"
          .. (is_dark and " gui=reverse cterm=reverse" or "")
      )
    end
    modify_colorscheme()

    vim.api.nvim_create_autocmd("OptionSet", {
      pattern = "background",
      callback = modify_colorscheme,
      group = augroup,
    })
  end,
  group = augroup,
})
