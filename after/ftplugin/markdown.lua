local c = require("patana.palette")
-- Highlight tags
vim.fn.matchadd("MarkdownTag", "<\\w\\+>\\zs.*\\ze</\\w\\+>")
vim.fn.matchadd("MarkdownTagName", "<\\w\\+>")
vim.fn.matchadd("MarkdownTagName", "</\\w\\+>")

vim.cmd("highlight MarkdownTag gui=bold guifg=" .. c.generate_palette().secondary)
vim.cmd("highlight MarkdownTagName gui=bold guifg=" .. c.generate_palette().accent)
