vim.cmd.highlight("clear")
if vim.fn.exists("syntax_on") then vim.cmd.syntax("reset") end

vim.o.background = "light"
vim.o.termguicolors = true
vim.g.colors_name = "random"

local base16 = require("mini.base16")

local base = {
  ["50"] = "#f1ecd0",
  ["200"] = "#dad5b9",
  ["300"] = "#c3bea2",
  ["400"] = "#aca78b",
  ["500"] = "#969275",
  ["600"] = "#817c5f",
  ["700"] = "#6c684a",
  ["800"] = "#585434",
  ["900"] = "#271f24",
  ["950"] = "#231a1f",
}

-- local palette = {
--   base00 = "#fef6d7", -- Default Background
--   base01 = "#E8DDb5", -- Lighter Background (Used for status bars, line number and folding marks)
--   base02 = "#9e9777", -- Selection Background
--   base03 = "#726a49", -- Comments, Invisibles, Line Highlighting
--   base04 = "#252525", -- Dark Foreground (Used for status bars)
--   base05 = "#1c1c1c", -- Default Foreground, Caret, Delimiters, Operators
--   base06 = "#121212", -- Light Foreground (Not often used)
--   base07 = "#040404", -- Light Background (Not often used)
--   base08 = "#3f0e00", -- Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
--   base09 = "#a14a08", -- Integers, Boolean, Constants, XML Attributes, Markup Link Url
--   base0A = "#fac200", -- Classes, Markup Bold, Search Text Background
--   base0B = "#002f00", -- Strings, Inherited Class, Markup Code, Diff Inserted
--   base0C = "#b3349e", -- Support, Regular Expressions, Escape Characters, Markup Quotes
--   base0D = "#1f6fbf", -- Functions, Methods, Attribute IDs, Headings
--   base0E = "#c400a2", -- Keywords, Storage, Selector, Markup Italic, Diff Changed
--   base0F = "#1f77bb", -- Deprecated, Opening/Closing Embedded Language Tags
-- }
local palette = base16.mini_palette("#f1ecd0", "#231a1f", 50)
local cterm = base16.rgb_palette_to_cterm_palette(palette)

require("mini.base16").setup({
  palette = palette,
  use_cterm = cterm,
  plugins = { default = true, ["lewis6991/gitsigns.nvim"] = false },
})

local hc = require("user.helpers.colors")
local alloverrides = {
  -- Syntax {{{
  Delimiter = { fg = palette.base04 },
  -- }}}
  -- Diff {{{
  Added = { fg = "#005000", bg = "#ccefcf" },
  DiffAdd = { link = "Added" },
  Changed = { bg = "#ffe5b9", fg = "#553d00" },
  DiffChange = { link = "Changed" },
  DiffText = { bg = "#ffd09f", fg = "#553d00", italic = true },
  Removed = { fg = "#8f1313", bg = "#ffd4d8" },
  DiffDelete = { link = "Removed" },
  -- }}}
  -- UI {{{
  CursorLine = { bg = base["200"] },
  WinBar = { bg = "#ffffff", fg = hc.get_hlgroup_table("StatusLine").bg },
  WinBarNC = { bg = "#ffffff", fg = hc.get_hlgroup_table("StatusLine").bg },
  StatusLine = hc.get_hlgroup_table("StatusLineNC"),
  TabLineFill = { bg = "#ffffff" },
  MsgArea = { bg = "#ffffff" },
  Type = hc.get_hlgroup_table("TabLine"),
  -- }}}
}
hc.override_hlgroups(alloverrides)

local allchanges = {
  markdownCodeBlock = { link = "CursorLine" },
  ColorColumn = { link = "CursorLine" },
  TabLineSel = { bold = true },
  Comment = { italic = true },
  Keyword = { italic = true },
  Folded = { link = "Comment" },
  -- String = { link = "Number" },
  Constant = { bold = true },
  WinBar = { bold = true },
  StatusLine = { bold = true },
  LineNr = { bold = true },
  Function = { bold = true },
  Whitespace = { italic = true },
  WinSeparator = { link = "MsgArea" },
  Boolean = { bold = true },
  NonText = { italic = true },
}
for hlgroup, overrides in pairs(allchanges) do
  hc.modify_hlgroup(hlgroup, overrides)
end
