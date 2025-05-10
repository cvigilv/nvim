local map = vim.keymap.set

-- Quickfix            {{{1
map("n", "]Q", ":cnewer<CR>", { silent = false, desc = "Next quickfix list" })
map("n", "[Q", ":colder<CR>", { silent = false, desc = "Previous quickfix list" })

-- Execution           {{{1
map("n", "<leader>x", ":source %<CR>", { silent = false, desc = "Source current file" })
map("v", "<leader>x", ":source<CR>", { silent = false, desc = "Source selected file" })

-- Diagnostics         {{{1
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

-- Plugins             {{{1
-- navigator           {{{2
vim.keymap.set(
  { "t", "n" },
  "<C-h>",
  require("Navigator").left,
  { noremap = true, silent = true }
)
vim.keymap.set(
  { "t", "n" },
  "<C-k>",
  require("Navigator").up,
  { noremap = true, silent = true }
)
vim.keymap.set(
  { "t", "n" },
  "<C-l>",
  require("Navigator").right,
  { noremap = true, silent = true }
)
vim.keymap.set(
  { "t", "n" },
  "<C-j>",
  require("Navigator").down,
  { noremap = true, silent = true }
)
vim.keymap.set(
  { "t", "n" },
  "<C-p>",
  require("Navigator").previous,
  { noremap = true, silent = true }
)

-- oil.nvim            {{{2
vim.keymap.set("n", "<leader><CR>", require("oil").open, {
  desc = "File browser",
  noremap = true,
  silent = true,
})

-- telescope.nvim      {{{2
local telescope_builtin = require("telescope.builtin")
vim.keymap.set(
  "n",
  ",ff",
  telescope_builtin.find_files,
  { silent = true, noremap = true, desc = "Find files" }
)
vim.keymap.set(
  "n",
  ",fs",
  "<CMD>Telescope live_grep<CR>",
  { silent = true, noremap = true, desc = "Find string with Grep" }
)
vim.keymap.set(
  "n",
  ",fw",
  function() telescope_builtin.grep_string({ search = vim.fn.expand("<cword>") }) end,
  { silent = true, noremap = true, desc = "Find word under cursor" }
)
vim.keymap.set(
  "n",
  ",fW",
  function() telescope_builtin.grep_string({ search = vim.fn.expand("<cWORD>") }) end,
  { silent = true, noremap = true, desc = "Find WORD under cursor" }
)
vim.keymap.set(
  "n",
  ",ft",
  function() telescope_builtin.grep_string({ search = " TODO: " }) end,
  { silent = true, noremap = true, desc = "Find TODO comments" }
)
vim.keymap.set(
  "n",
  ",fr",
  function() telescope_builtin.resume() end,
  { silent = true, noremap = true, desc = "Open last search result" }
)
vim.keymap.set(
  "n",
  ",fb",
  "<CMD>Telescope buffers<CR>",
  { silent = true, noremap = true, desc = "Buffers" }
)
vim.keymap.set(
  "n",
  ",fh",
  "<CMD>Telescope help_tags<CR>",
  { silent = true, noremap = true, desc = "Help tags" }
)
vim.keymap.set(
  "n",
  ",fd",
  "<CMD>Telescope diagnostics<CR>",
  { silent = true, noremap = true, desc = "LSP diagnostics" }
)
vim.keymap.set(
  "n",
  ",f?",
  "<CMD>Telescope builtin<CR>",
  { silent = true, noremap = true, desc = "Pickers" }
)

-- conform.nvim        {{{2
vim.keymap.set(
  "n",
  "<leader>lf",
  function() require("conform").format({ async = true }) end,
  { desc = "Format buffer" }
)

-- treesitter-context  {{{2
vim.keymap.set(
  "n",
  "[c",
  function() require("treesitter-context").go_to_context(vim.v.count1) end,
  { silent = true }
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
  function() require("gitsigns").undo_stage_hunk() end,
  { noremap = true, silent = true, desc = "Undo stage hunk" }
)
vim.keymap.set(
  "v",
  "<leader>gr",
  function() require("gitsigns").undo_stage_hunk({ vim.fn.line("v"), vim.fn.line(".") }) end,
  { noremap = true, silent = true, desc = "Undo stage hunk" }
)
vim.keymap.set("n", "<leader>gd", function()
  require("gitsigns").toggle_deleted()
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
