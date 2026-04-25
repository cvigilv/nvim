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

-- vim.g.refer_last = nil
--
-- local function run_and_remember_picker(runner)
--     vim.g.refer_last = runner
--     return runner()
-- end
--
-- local function resume_last_picker()
--     if not vim.g.refer_last then
--         vim.notify("No picker to resume", vim.log.levels.INFO)
--         return
--     end
--
--     return vim.g.refer_last()
-- end

vim.keymap.set(
  "n",
  ",ff",
  "<CMD>Refer Files<CR>",
  { silent = true, noremap = true, desc = "Find files" }
)
vim.keymap.set(
  "n",
  ",fs",
  "<CMD>Refer Grep<CR>",
  { silent = true, noremap = true, desc = "Find string with Grep" }
)
vim.keymap.set(
  "n",
  ",fw",
  "<CMD>Refer Selection<CR>",
  { silent = true, noremap = true, desc = "Find word under cursor/selection" }
)
-- vim.keymap.set(
--   "n",
--   ",ft",
--   function() telescope_builtin.grep_string({ search = " TODO: " }) end,
--   { silent = true, noremap = true, desc = "Find TODO comments" }
-- )
vim.keymap.set(
  "n",
  ",fr",
  "<CMD>Refer Last<CR>",
  { silent = true, noremap = true, desc = "Open last search result" }
)


vim.keymap.set(
  "n",
  ",fb",
  "<CMD>Refer Buffers<CR>",
  { silent = true, noremap = true, desc = "Buffers" }
)

vim.keymap.set("n", ",fh", function()
  local langs = vim.split(vim.o.helplang, ",", { trimempty = true })
  if not vim.tbl_contains(langs, "en") then table.insert(langs, "en") end

  local langs_map = {}
  for _, lang in ipairs(langs) do
    langs_map[lang] = true
  end

  local tag_files = {}
  local function add_tag_file(lang, file)
    if not langs_map[lang] then return end

    if not tag_files[lang] then tag_files[lang] = {} end
    table.insert(tag_files[lang], file)
  end

  local help_files = {}
  local rtp = vim.o.runtimepath
  local lazy = package.loaded["lazy.core.util"]
  if lazy and lazy.get_unloaded_rtp then
    local paths = lazy.get_unloaded_rtp("")
    if #paths > 0 then rtp = rtp .. "," .. table.concat(paths, ",") end
  end

  local all_files = vim.fn.globpath(rtp, "doc/*", true, true)
  for _, fullpath in ipairs(all_files) do
    local file = vim.fs.basename(fullpath)
    if file == "tags" then
      add_tag_file("en", fullpath)
    elseif file:match("^tags%-..$") then
      add_tag_file(file:sub(-2), fullpath)
    else
      help_files[file] = fullpath
    end
  end

  local tags = {}
  local lookup = {}
  local tags_map = {}

  for _, lang in ipairs(langs) do
    for _, file in ipairs(tag_files[lang] or {}) do
      for _, line in ipairs(vim.fn.readfile(file)) do
        if not line:match("^!_TAG_") then
          local fields = vim.split(line, "\t", { trimempty = true })
          if #fields == 3 and not tags_map[fields[1]] then
            if fields[1] ~= "help-tags" or fields[2] ~= "tags" then
              table.insert(tags, fields[1])
              lookup[fields[1]] = fields[1] .. "@" .. lang
              tags_map[fields[1]] = true
            end
          end
        end
      end
    end
  end

  if #tags == 0 then return end

  require("refer").pick(tags, function(selection)
    if not selection or selection == "" then return end

    local value = lookup[selection] or selection
    vim.cmd("help " .. vim.fn.fnameescape(value))
  end, {
    prompt = "Help > ",
    keymaps = {
      ["<CR>"] = "select_entry",
    },
  })
  end,
  { silent = true, noremap = true, desc = "Help tags" }
)
-- vim.keymap.set(
--   "n",
--   ",fd",
--   "<CMD>Telescope diagnostics<CR>",
--   { silent = true, noremap = true, desc = "LSP diagnostics" }
-- )
vim.keymap.set(
  "n",
  ",f?",
  "<CMD>Refer Commands<CR>",
  { silent = true, noremap = true, desc = "Pickers" }
)

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
