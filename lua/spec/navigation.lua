---@module "spec.navigation"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

vim.pack.add({
  "https://github.com/hrsh7th/nvim-swm",
  "https://github.com/numToStr/Navigator.nvim",
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons" ,
  "https://github.com/stevearc/oil.nvim",
})

-- Tmux + floating window movement
local navigator = require("Navigator")
local swm = require("swm")
navigator.setup({
  auto_save = nil,
  disable_on_zoom = true,
  mux = "auto",
})
vim.keymap.set(
  { "n", "t" },
  "<C-h>",
  function() return swm.h() or navigator.left() end,
  { noremap = true, silent = true }
)
vim.keymap.set(
  { "n", "t" },
  "<C-j>",
  function() return swm.j() or navigator.up() end,
  { noremap = true, silent = true }
)
vim.keymap.set(
  { "n", "t" },
  "<C-k>",
  function() return swm.k() or navigator.down() end,
  { noremap = true, silent = true }
)
vim.keymap.set(
  { "n", "t" },
  "<C-l>",
  function() return swm.l() or navigator.right() end,
  { noremap = true, silent = true }
)

-- Oil
require("oil").setup({
  view_options = {
    show_hidden = true,
  },
  columns = { "icon" },
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
vim.keymap.set("n", "<leader><CR>", "<Plug>Oil", {remap = false})

-- Telescope + pickers
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")

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
