local map = vim.keymap.set

-- Quickfix
map("n", "]Q", ":cnewer<CR>", { silent = false, desc = "Next quickfix list" })
map("n", "[Q", ":colder<CR>", { silent = false, desc = "Previous quickfix list" })

vim.g.user_colorcolumn_oob = false
local function toggle_colorcolumn_oob()
  if vim.g.user_colorcolumn_oob then
    vim.cmd("set colorcolumn=96")
  else
    vim.cmd("let &colorcolumn=join(range(97,999),',')")
  end
  vim.g.user_colorcolumn_oob = not vim.g.user_colorcolumn_oob
end

map(
  "n",
  "<leader><leader>c",
  toggle_colorcolumn_oob,
  { silent = true, desc = "Activate colorcolumn OOB view" }
)
