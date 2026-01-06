---@module "colors.claro"
---@author Carlos Vigil-Vásquez
---@license MIT 2026

vim.cmd("highlight clear")
vim.g.color_name = "duobones"

local base = require("zenbones")
local lush = require("lush")

-- Define base colors
local is_dark = vim.o.background == "dark"
local bg = is_dark and "#000000" or "#ffffff"
local accent = lush.hsluv("#008ec4")
local counter = lush.hsluv("#c18401").mix(accent, 25)

-- Define and apply lush specs
local specs = lush.extends({ base }).with(function(injected_functions)
  local sym = injected_functions.sym
  return {
    Folded({}),
    OutOfBounds({ bg = base.NormalNC.bg }),
    MsgArea({ bg = bg }),
    ModeArea({ bg = bg }),
    TabLineFill({ bg = bg }),
    NormalFloat({ bg = base.NormalNC.bg }),
    FloatBorder({ fg = base.Normal.bg, bg = base.NormalNC.bg }),
    NormalNC({ base.Normal }),
    StatusLine({ base.StatusLine, bold = true }),
    StatusLineNC({ base.StatusLineNC, italic = true }),
    String({ fg = accent.saturation(100), italic = true }),
    Number({ fg = accent.saturation(100) }),
    sym("Function")({ fg = counter.saturation(100) }),
    sym("Special")({ fg = counter.saturation(100) }),
  }
end)
lush.apply(lush.compile(specs))

-- Additional highlight groups
vim.cmd("hi! link @org.keyword.face.TODO DiagnosticVirtualTextError")
vim.cmd("hi! link @org.keyword.face.NEXT DiagnosticVirtualTextHint")
vim.cmd("hi! link @org.keyword.face.PROG DiagnosticVirtualTextWarn")
vim.cmd("hi! link @org.keyword.face.DONE DiagnosticVirtualTextOk")
vim.cmd("hi! link @org.keyword.face.CNCL DiagnosticVirtualTextOk")
vim.cmd(
  "hi! @org.keyword.face.INTR.org guibg=#000000 guifg=#ffffff"
    .. (is_dark and " gui=reverse cterm=reverse" or "")
)
