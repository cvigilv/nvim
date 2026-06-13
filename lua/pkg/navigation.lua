-- Picker
-- require("refer").setup({
--   max_height_percent = 0.2,
--   min_height = 16,
--   debounce_ms = 1,
--   default_sorter = "blink",
--   keymaps = {
--     ["<Tab>"] = { action = "complete_selection", desc = "Complete selection" },
--     ["<CR>"] = { action = "select_input", desc = "Confirm selection" },
--     ["<C-n>"] = { action = "next_item", desc = "Next item" },
--     ["<C-p>"] = { action = "prev_item", desc = "Previous item" },
--     ["<Down>"] = { action = "next_item", desc = "Next item" },
--     ["<Up>"] = { action = "prev_item", desc = "Previous item" },
--     ["<M-p>"] = { action = "toggle_preview", desc = "Toggle preview" },
--     ["<C-u>"] = { action = "scroll_preview_up", desc = "Scroll preview up" },
--     ["<C-d>"] = { action = "scroll_preview_down", desc = "Scroll preview down" },
--     ["<C-S>"] = { action = "cycle_sorter ", desc = "Cycle sorter" },
--     ["<C-q>"] = { action = "send_to_qf", desc = "Send to quickfix" },
--     ["<C-g>"] = { action = "send_to_grep", desc = "Send to grep buffer (experimental)" },
--     ["<M-a>"] = { action = "select_all", desc = "Select all" },
--     ["<M-d>"] = { action = "deselect_all", desc = "Deselect all" },
--     ["<M-t>"] = { action = "toggle_all", desc = "Toggle all marks" },
--     ["<Esc>"] = { action = "close", desc = "Close picker" },
--     ["<C-c>"] = { action = "close", desc = "Close picker" },
--     ["<C-e>"] = { action = "edit_entry", desc = "Open selected item in current window" },
--     ["<C-h>"] = { action = "split_entry", desc = "Open selected item in a horizontal split" },
--     ["<C-v>"] = { action = "vsplit_entry", desc = "Open selected item in a vertical split" },
--     ["<C-t>"] = { action = "tab_entry", desc = "Open selected item in a new tab" },
--     ["<C-s>"] = {
--       action = "select_entry",
--       desc = "Call on_select with item and its attached data",
--     },
--   },
-- })
--
-- vim.keymap.set(
--   "n",
--   ",ff",
--   "<CMD>Refer Files<CR>",
--   { silent = true, noremap = true, desc = "Find files" }
-- )
-- vim.keymap.set(
--   "n",
--   ",fs",
--   "<CMD>Refer Grep<CR>",
--   { silent = true, noremap = true, desc = "Find string with Grep" }
-- )
-- vim.keymap.set(
--   "n",
--   ",fw",
--   "<CMD>Refer Selection<CR>",
--   { silent = true, noremap = true, desc = "Find word under cursor/selection" }
-- )
-- -- vim.keymap.set(
-- --   "n",
-- --   ",ft",
-- --   function() telescope_builtin.grep_string({ search = " TODO: " }) end,
-- --   { silent = true, noremap = true, desc = "Find TODO comments" }
-- -- )
-- vim.keymap.set(
--   "n",
--   ",fr",
--   "<CMD>Refer Resume<CR>",
--   { silent = true, noremap = true, desc = "Resume last picker" }
-- )
--
-- vim.keymap.set(
--   "n",
--   ",fb",
--   "<CMD>Refer Buffers<CR>",
--   { silent = true, noremap = true, desc = "Pick buffers" }
-- )
--
-- vim.keymap.set(
--   "n",
--   ",fh",
--   "<CMD>Refer Help<CR>",
--   { silent = true, noremap = true, desc = "Pick help page" }
-- )
-- -- vim.keymap.set(
-- --   "n",
-- --   ",fd",
-- --   "<CMD>Telescope diagnostics<CR>",
-- --   { silent = true, noremap = true, desc = "LSP diagnostics" }
-- -- )
-- vim.keymap.set(
--   "n",
--   ",f?",
--   "<CMD>Refer Commands<CR>",
--   { silent = true, noremap = true, desc = "Pickers" }
-- )
--
-- require("refer").setup_ui_select()
---@diagnostic disable-next-line: missing-fields
require("zotero").setup({
  zotero="~/Zotero/zotero.sqlite",
  better_bibtex_db_path=nil,
  pdf_opener="sioyek",
  ft = {
    org = {
      insert_key_formatter = function(citekey) return "[cite:@" .. citekey .. "]" end,
      locate_bib = function()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        for _, line in ipairs(lines) do
          local location = line:match("#%+BIBLIOGRAPHY:%s*(.+)")
            or line:match("#%+bibliography:%s*(.+)")
          if location then return location end
        end
        return vim.fn.fnamemodify(vim.fn.expand("%"), ":r") .. ".bib"
      end,
    },
    typst = {
      insert_key_formatter = function(citekey) return "@" .. citekey end,
      locate_bib = function()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        for _, line in ipairs(lines) do
          local location = line:match("^#bibliography%((.+)%)")
          if location then return location:sub(2, -2) end
        end
        return vim.fn.fnamemodify(vim.fn.expand("%"), ":r") .. ".bib"
      end,
    },
  },
})
require("telescope").load_extension("denote")
require("telescope").load_extension("zotero")
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")

-- Helpers
local function ismedia(path)
  local media_extensions = {
    "png",
    "jpg",
    "jpeg",
    "gif",
    "webp",
    "svg",
    "mp4",
    "mkv",
    "avi",
    "mov",
    "webm",
    "pdf",
    "mp3",
    "wav",
    "flac",
    "ogg",
  }
  return path and vim.tbl_contains(media_extensions, vim.fn.fnamemodify(path, ":e"))
end

-- Custom actions
local function open_media(prompt_bufnr)
  local selection = action_state.get_selected_entry()
  local path = selection.path or selection.value

  -- Check if file is a PDF
  if ismedia(path) then
    actions.close(prompt_bufnr)

    -- Determine command based on OS
    local open_cmd
    if vim.fn.has("mac") == 1 then
      open_cmd = "open"
    elseif vim.fn.has("unix") == 1 then
      open_cmd = "xdg-open"
    elseif vim.fn.has("win32") == 1 then
      open_cmd = "start"
    end

    -- Execute the command to open PDF externally
    if open_cmd then vim.fn.jobstart({ open_cmd, path }) end
  else
    -- Use default action for non-PDF files
    actions.select_default(prompt_bufnr)
  end
end

require("telescope").setup({
  defaults = require("telescope.themes").get_ivy({
    prompt_prefix = "? ",
    selection_prefix = "  ",
    multi_icon = "!",
    layout_config = { height = 16, width = 0.6 },
    selection_strategy = "reset",
    sorting_strategy = "ascending",
    path_display = { "filename_first" },
  }),
  pickers = {
    find_files = {
      prompt_title = false,
      prompt_prefix = "[Find files] ",
      previewer = false,
      mappings = {
        i = { ["<CR>"] = open_media },
        n = { ["<CR>"] = open_media },
      },
    },
    git_files = {
      prompt_title = false,
      prompt_prefix = "[Git files] ",
      previewer = false,
      mappings = {
        i = { ["<CR>"] = open_media },
        n = { ["<CR>"] = open_media },
      },
    },
    live_grep = { prompt_title = false, prompt_prefix = "[Live Grep] " },
    builtin = { prompt_title = false, prompt_prefix = "[Pickers] ", previewer = false },
  },
})

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
vim.keymap.set(
  "n",
  ",fc",
  "<CMD>Telescope zotero<CR>",
  { silent = true, noremap = true, desc = "Citation" }
)

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

vim.keymap.set(
  "n",
  ",zf",
  "<CMD>Telescope denote search<CR>",
  { silent = true, noremap = true, desc = "Denote search" }
)

vim.keymap.set(
  "n",
  ",zl",
  "<CMD>Telescope denote insert_link<CR>",
  { silent = true, noremap = true, desc = "Denote link" }
)

-- Oil
require("oil").setup({
  view_options = { show_hidden = true },
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
