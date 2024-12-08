---@module 'patana'
---@author Carlos Vigil-Vásquez
---@license MIT

vim.cmd.highlight("clear")
if vim.fn.exists("syntax_on") then vim.cmd.syntax("reset") end

vim.o.termguicolors = true
vim.g.colors_name = "ef-eagle"

-- Colors
local bg = "#f1ecd0"
local fg = "#231a1f"

if vim.o.background == "dark" then
  bg, fg = fg, bg
end
local base16 = require("mini.base16")

local palette = base16.mini_palette(bg, fg, 80)
local cterm = base16.rgb_palette_to_cterm_palette(palette)

require("mini.base16").setup({
  palette = palette,
  use_cterm = cterm,
})
