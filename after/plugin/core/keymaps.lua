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
-- cvigilv/zk          {{{2
vim.keymap.set(
  "n",
  "<leader>zc",
  ":ZkNewNote<CR>",
  { noremap = true, silent = false, desc = "Create note" }
)
vim.keymap.set(
  "n",
  "<leader>zf",
  ":ZkSearchNotes<CR>",
  { noremap = true, silent = false, desc = "Search by notes metadata" }
)
vim.keymap.set(
  "n",
  "<leader>zt",
  ":ZkSearchTags<CR>",
  { noremap = true, silent = false, desc = "Search by tags" }
)
vim.keymap.set(
  "n",
  "<leader>zl",
  ":ZkLinks<CR>",
  { noremap = true, silent = false, desc = "Show note links" }
)

-- --- Bind ,zl to create a link from current visual selection
-- --- TODO: Add second step where a Telescope prompt appears and I can easily select a note from
-- ---       its title.
-- vim.keymap.set(
--   { "x", "v" },
--   "<leader>zl",
--   [[c[<C-r>"]()<C-c>i]],
--   vim.tbl_extend("keep", { noremap = true, silent = false }, { desc = "Create new link" })
-- )

-- cvigilv/afuera.nvim {{{2
vim.keymap.set("n", ",,o", ":AfueraToggle<CR>", { desc = "Toggle Afuera" })
vim.keymap.set("n", ",,O", ":AfueraStatus<CR>", { desc = "Afuera status" })

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

-- harpoon.nvim        {{{2
local harpoon = require("harpoon")
vim.keymap.set("n", "<Space>fa", function() harpoon:list():add() end, { desc = "Add file" })
vim.keymap.set(
  "n",
  "<Space>ff",
  function()
    harpoon.ui:toggle_quick_menu(harpoon:list(), {
      border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
      title = " Harpoon ",
      title_pos = "left",
      ui_width_ratio = 0.33,
    })
  end,
  { desc = "Toggle quick menu" }
)

vim.keymap.set(
  "n",
  "[h",
  function() harpoon:list():prev() end,
  { desc = "Previous harpoon buffer" }
)
vim.keymap.set(
  "n",
  "]h",
  function() harpoon:list():next() end,
  { desc = "Next harpoon buffer" }
)

for i, key in ipairs({ "h", "j", "k", "l" }) do
  vim.keymap.set(
    "n",
    "<Space>f" .. key,
    function() harpoon:list():select(i) end,
    { desc = "Select buffer #" .. key }
  )
end

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

-- neogen.nvim         {{{2
vim.keymap.set(
  "n",
  "<Leader>ld",
  function() require("neogen").generate({ type = "func" }) end,
  { desc = "Generate function docstring", noremap = true, silent = true }
)

vim.keymap.set(
  "n",
  "<Leader>lD",
  function()
    vim.ui.select(
      { "class", "func", "type", "file" },
      { prompt = "Select docstring to generate:" },
      function(choice) require("neogen").generate({ type = choice }) end
    )
  end,
  { desc = "Pick docstring to generate", noremap = true, silent = true } --
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
