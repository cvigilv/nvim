local map = vim.keymap.set

-- Quick-fix
map("n", "]Q", ":cnewer<CR>", { silent = false, desc = "Next quickfix list" })
map("n", "[Q", ":colder<CR>", { silent = false, desc = "Previous quickfix list" })

-- Execution
map("n", "<leader>x", ":source %<CR>", { silent = false, desc = "Source current file" })
map("v", "<leader>x", ":source<CR>", { silent = false, desc = "Source selected file" })

-- Diagnostics
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

-- oil.nvim
vim.keymap.set(
  "n",
  "<leader><CR>",
  function() require("oil").open(nil, { preview = {} }) end,
  { desc = "File browser", noremap = true, silent = true }
)

-- conform.nvim
vim.keymap.set(
  "n",
  "<leader>lf",
  function() require("conform").format({ async = true }) end,
  { desc = "Format buffer" }
)

-- gitsigns
vim.keymap.set(
  "n",
  "<leader>ga",
  function() require("gitsigns").stage_hunk() end,
  { noremap = true, silent = true, desc = "Stage hunk" }
)
vim.keymap.set(
  "v",
  "<leader>ga",
  function() require("gitsigns").stage_hunk({ vim.fn.line("v"), vim.fn.line(".") }) end,
  { noremap = true, silent = true, desc = "Stage hunk" }
)
vim.keymap.set(
  "n",
  "<leader>gr",
  function() require("gitsigns").stage_hunk() end,
  { noremap = true, silent = true, desc = "Undo stage hunk" }
)
vim.keymap.set(
  "v",
  "<leader>gr",
  function() require("gitsigns").stage_hunk({ vim.fn.line("v"), vim.fn.line(".") }) end,
  { noremap = true, silent = true, desc = "Undo stage hunk" }
)
vim.keymap.set("n", "<leader>gd", function()
  require("gitsigns").preview_hunk_inline()
  require("gitsigns").toggle_linehl()
end, { noremap = true, silent = true, desc = "Toggle diff" })
vim.keymap.set(
  "n",
  "]g",
  function() require("gitsigns").nav_hunk("next") end,
  { noremap = true, silent = true, desc = "Go to next Git hunk" }
)
vim.keymap.set(
  "n",
  "[g",
  function() require("gitsigns").nav_hunk("prev") end,
  { noremap = true, silent = true, desc = "Go to previous Git hunk" }
)
