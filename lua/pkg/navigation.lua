-- Picker
require("refer").setup({
  max_height_percent = 0.2,
  min_height = 16,
  debounce_ms = 50,
  default_sorter = "native",
  keymaps = {
    ["<Tab>"] = { action = "complete_selection", desc = "Complete selection" },
    ["<CR>"] = { action = "select_input", desc = "Confirm selection" },
    ["<C-n>"] = { action = "next_item", desc = "Next item" },
    ["<C-p>"] = { action = "prev_item", desc = "Previous item" },
    ["<Down>"] = { action = "next_item", desc = "Next item" },
    ["<Up>"] = { action = "prev_item", desc = "Previous item" },
    ["<M-p>"] = { action = "toggle_preview", desc = "Toggle preview" },
    ["<C-u>"] = { action = "scroll_preview_up", desc = "Scroll preview up" },
    ["<C-d>"] = { action = "scroll_preview_down", desc = "Scroll preview down" },
    ["<C-S>"] = { action = "cycle_sorter ", desc = "Cycle sorter" },
    ["<C-q>"] = { action = "send_to_qf", desc = "Send to quickfix" },
    ["<C-g>"] = { action = "send_to_grep", desc = "Send to grep buffer (experimental)" },
    ["<M-a>"] = { action = "select_all", desc = "Select all" },
    ["<M-d>"] = { action = "deselect_all", desc = "Deselect all" },
    ["<M-t>"] = { action = "toggle_all", desc = "Toggle all marks" },
    ["<Esc>"] = { action = "close", desc = "Close picker" },
    ["<C-c>"] = { action = "close", desc = "Close picker" },
    ["<C-e>"] = { action = "edit_entry", desc = "Open selected item in current window" },
    ["<C-h>"] = { action = "split_entry", desc = "Open selected item in a horizontal split" },
    ["<C-v>"] = { action = "vsplit_entry", desc = "Open selected item in a vertical split" },
    ["<C-t>"] = { action = "tab_entry", desc = "Open selected item in a new tab" },
    ["<C-s>"] = {
      action = "select_entry",
      desc = "Call on_select with item and its attached data",
    },
  },
})

require("refer").setup_ui_select()

-- Window management
require("Navigator").setup({
  auto_save = nil,
  disable_on_zoom = true,
  mux = "auto",
})
local swm = require("swm")

vim.keymap.set(
  { "n", "t" },
  "<C-h>",
  function() return swm.h() or require("Navigator").left() end,
  { noremap = true, silent = true }
)
vim.keymap.set(
  { "n", "t" },
  "<C-j>",
  function() return swm.j() or require("Navigator").up() end,
  { noremap = true, silent = true }
)
vim.keymap.set(
  { "n", "t" },
  "<C-k>",
  function() return swm.k() or require("Navigator").down() end,
  { noremap = true, silent = true }
)
vim.keymap.set(
  { "n", "t" },
  "<C-l>",
  function() return swm.l() or require("Navigator").right() end,
  { noremap = true, silent = true }
)

-- Oil
require("oil").setup({
  view_options = {
    show_hidden = true,
  },
  columns = {
    { "permissions", highlight = "Structure" },
    { "size", highlight = "Number" },
    { "mtime", highlight = "Comment" },
    "icon",
  },
  default_file_explorer = true,
  restore_win_options = true,
  skip_confirm_for_simple_edits = false,
  delete_to_trash = false,
  prompt_save_on_select_new_entry = true,
  keymaps = {
    ["g?"] = "actions.show_help",
    ["<CR>"] = "actions.select",
    ["|"] = "actions.select_vsplit",
    ["-"] = "actions.select_split",
    ["<C-v>"] = "actions.select_vsplit",
    ["<C-h>"] = "actions.select_split",
    ["<C-t>"] = "actions.select_tab",
    ["<C-p>"] = "actions.preview",
    ["<C-c>"] = "actions.close",
    ["<C-r>"] = "actions.refresh",
    ["."] = "actions.parent",
    ["_"] = "actions.open_cwd",
    ["`"] = "actions.cd",
    ["g."] = "actions.toggle_hidden",
    ["gx"] = "actions.open_external",
  },
  use_default_keymaps = false,
})
