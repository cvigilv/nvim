-- Keymaps
vim.keymap.set("n", ",fz", ":Telescope zotero<CR>", { desc = "Find Zotero" })

-- Statuscolumn
require("plugin.headercolumn").setup(12)

-- Writing mode
require("plugin.escritura").setup(12)

-- Try to open PDF if exists
local pdf = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":r") .. ".pdf"
if vim.loop.fs_stat(pdf) ~= nil then
  local handle = vim.loop.spawn("sioyek", { args = { pdf }, detached = true }, function() end)
  if handle then handle:close() end
end
