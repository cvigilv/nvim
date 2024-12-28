---@diagnostic disable: undefined-field
---@module 'plugin.diagnostics'
---@author Carlos Vigil-Vásquez
---@license MIT

-- -- Diagnostic symbols for display in the sign column.
-- local symbols = {
--   [vim.diagnostic.severity.ERROR] = "󰅙 ",
--   [vim.diagnostic.severity.WARN] = " ",
--   [vim.diagnostic.severity.HINT] = " ",
--   [vim.diagnostic.severity.INFO] = " ",
-- }
--
-- vim.fn.sign_define("DiagnosticSignError", { text = "󰅙 ", texthl = "DiagnosticSignError" })
-- vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
-- vim.fn.sign_define("DiagnosticSignHint", { text = " ", texthl = "DiagnosticSignHint" })
-- vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
-- vim.fn.sign_define("DiagnosticSignOk", { text = " ", texthl = "Normal" })
--
-- vim.diagnostic.config({
--   update_in_insert = true,
--   severity_sort = true,
--   signs = { text = symbols },
--   virtual_text = {
--     format = function(diagnostic)
--       -- Get line with diagnostics data
--       local line = vim.fn.getline(diagnostic.lnum + 1)
--       line = line:gsub("\t", string.rep(" ", vim.bo.tabstop))
--
--       -- Align diagnostic message with colorcolumn
--       local contents = symbols[diagnostic.severity] .. diagnostic.message
--
--       return "\t\t" .. contents
--     end,
--     prefix = "",
--     spacing = 0,
--     suffix = "",
--   },
-- })

-- Keymaps
vim.keymap.set(
  "n",
  "[d",
  function() vim.diagnostic.jump({ count = -1, float = true }) end,
  { desc = "Previous diagnostics", noremap = true }
)
vim.keymap.set(
  "n",
  "]d",
  function() vim.diagnostic.jump({ count = 1, float = true }) end,
  { desc = "Next diagnostics", noremap = true }
)
vim.keymap.set(
  "n",
  "<leader>d",
  vim.diagnostic.open_float,
  { desc = "Open diagnostics", noremap = true }
)
