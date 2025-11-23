---@module 'after.plugin.diagnostics'
---@author Carlos Vigil-Vásquez
---@license MIT

-- Diagnostic symbols for display in the sign column.
local symbols = {
  [vim.diagnostic.severity.ERROR] = "E",
  [vim.diagnostic.severity.WARN] = "W",
  [vim.diagnostic.severity.HINT] = "H",
  [vim.diagnostic.severity.INFO] = "I",
}

vim.fn.sign_define("DiagnosticSignError", { text = "E", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "W", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignHint", { text = "H", texthl = "DiagnosticSignHint" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "I", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignOk", { text = " ", texthl = "Normal" })

vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  signs = { text = symbols },
  virtual_lines = { current_line = true },
  virtual_text = {
    hl_mode = "combine",
    virt_text_pos = "eol",

    prefix = function(diagnostic, _, total)
      symbols = {
        [vim.diagnostic.severity.ERROR] = "E",
        [vim.diagnostic.severity.WARN] = "W",
        [vim.diagnostic.severity.INFO] = "I",
        [vim.diagnostic.severity.HINT] = "H",
      }

      local severity = diagnostic.severity
      local symbol = symbols[severity] or "?"

      -- You can customize this format as needed
      return string.format("%s%d ", symbol, total)
    end,
    spacing = 0,
    suffix = "",
  },
})

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
