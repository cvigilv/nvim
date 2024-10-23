---@module "zk.finders"
---@author Carlos Vigil Vasquez
---@license MIT 2024

local pickers = require("telescope.pickers")
local sorters = require("telescope.sorters")
local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local utils = require("plugin.zk.utils")

local telescope_theme = {
  preview_title = "Zettelkasten",
  prompt_prefix = "? ",
  selection_caret = "> ",
  entry_prefix = "  ",
  initial_mode = "insert",
  selection_strategy = "reset",
  sorting_strategy = "ascending",
  layout_strategy = "vertical",
  layout_config = {
    horizontal = {},
    vertical = {
      prompt_position = "top",
      results_width = 60,
      results_length = 1,
    },
    width = 96,
    height = 64,
  },
  path_display = { "truncate" },
  winblend = 10,
  border = {},
}

-- Helpers

local M = {}

---Search notes by headings
---@param opts table Options table containing the path to search
---@return nil
M.search_headings = function(opts)
  -- Get metadata of all notes
  local all_metadata = utils.get_all_metadatas(opts)
  -- vim.print(all_metadata)

  -- Define how to build entry for Telescope
  local make_display = function(entry)
    -- Tags may be a string or a table, convert it for display purposes.
    local tags = vim.fn.join(entry.value.tags, ";")
    local type = entry.value.type

    local displayer = entry_display.create({
      separator = " ",
      items = {
        { width = string.len("Map-of-Contents") }, -- Pad to longest type
        { width = string.len(entry.value.title) },
        { remaining = true },
      },
    })

    return displayer({
      -- We can skip highlight groups if we want.
      { entry.value.type, "TelescopeResultsNumber" },
      entry.value.title,
      { tags, "TelescopeResultsComment" },
    })
  end

  -- "Blur" background whenever Telescope launches
  local backdrop_buf = vim.api.nvim_create_buf(false, true)
  local backdrop_win = vim.api.nvim_open_win(backdrop_buf, false, {
    relative = "editor",
    width = vim.o.columns,
    height = vim.o.lines,
    row = 0,
    col = 0,
    style = "minimal",
    focusable = false,
    zindex = 2,
  })
  vim.api.nvim_set_hl(0, "LazyBackdrop", { bg = "#000000", default = true })
  vim.api.nvim_set_option_value(
    "winhighlight",
    "Normal:LazyBackdrop",
    { scope = "local", win = backdrop_win }
  )
  vim.api.nvim_set_option_value("winblend", 80, { scope = "local", win = backdrop_win })
  vim.api.nvim_set_option_value("buftype", "nofile", { scope = "local", buf = backdrop_buf })
  vim.api.nvim_set_option_value(
    "filetype",
    "lazy_backprop",
    { scope = "local", buf = backdrop_buf }
  )

  pickers
    .new(telescope_theme, {
      -- UI
      prompt_title = "Search notes",
      results_title = "Notes",

      -- Behaviour
      finder = finders.new_table({
        results = vim.tbl_values(all_metadata),
        entry_maker = function(entry)
          return {

            ordinal = entry.title .. entry.type .. table.concat(entry.tags, ";"),
            value = entry,
            path = entry.path,
            display = make_display,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      previewer = conf.file_previewer({}),
      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          -- Get selected entry/entries
          local selected = action_state.get_selected_entry()

          -- Close Telescope and backdrop
          actions.close(prompt_bufnr)
          vim.api.nvim_win_close(backdrop_win, true)

          -- Open file
          vim.print(selected)
          vim.cmd("e " .. selected.path)
        end)

        ---@diagnostic disable-next-line: undefined-field
        actions.close:replace(function()
          local picker = action_state.get_current_picker(prompt_bufnr)
          local original_win_id = picker.original_win_id
          local cursor_valid, original_cursor =
            pcall(vim.api.nvim_win_get_cursor, original_win_id)

          actions.close_pum(prompt_bufnr)

          vim.api.nvim_win_close(backdrop_win, true)
          require("telescope.pickers").on_close_prompt(prompt_bufnr)
          pcall(vim.api.nvim_set_current_win, original_win_id)
          if
            cursor_valid
            and vim.api.nvim_get_mode().mode == "i"
            and picker._original_mode ~= "i"
          then
            pcall(
              vim.api.nvim_win_set_cursor,
              original_win_id,
              { original_cursor[1], original_cursor[2] + 1 }
            )
          end
        end)

        return true
      end,
    })
    :find()
end

--- Search by tags
---@param opts table Plugin options
M.search_tags = function(opts)
  -- Step 1: Find all tags
  local notes = vim.fn.glob(opts.path .. "*.md", false, true)
  local allnotetags = utils.get_all_tags(opts)

  -- Convert tags table to a list for telescope
  local alltagnotes = {}
  for notepath, notetags in pairs(allnotetags) do
    for _, tag in ipairs(notetags) do
      if not alltagnotes[tag] then alltagnotes[tag] = {} end

      table.insert(alltagnotes[tag], notepath)
    end
  end

  local tag_list = {}
  for tag, filelist in pairs(alltagnotes) do
    table.insert(tag_list, {
      tag = tag,
      amount = #filelist,
      filelist = filelist,
    })
  end

  pickers
    .new({}, {
      prompt_title = "Select tag(s)",
      finder = finders.new_table({
        results = tag_list,
        entry_maker = function(entry)
          local display = entry.tag .. " (" .. entry.amount .. " notes)"
          return {
            value = entry.filelist,
            display = display,
            ordinal = entry.tag,
            path = entry.tag,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, _)
        actions.select_default:replace(function()
          local selected_tag_files = action_state.get_selected_entry()
          actions.close(prompt_bufnr)

          local headings = {}
          vim.print(utils.get_notes_headings(selected_tag_files.value))
          for path, heading in pairs(utils.get_notes_headings(selected_tag_files.value)) do
            table.insert(headings, {
              value = heading[1],
              display = heading[1] .. " (" .. path .. ")",
              ordinal = heading[1],
              path = path,
            })
          end
          vim.print(headings)

          pickers
            .new(telescope_theme, {
              prompt_title = "Files with Selected Tags",
              finder = finders.new_table({
                results = headings,
                entry_maker = function(entry) return entry end,
              }),
              sorter = conf.file_sorter({}),
              previewer = conf.file_previewer({}),
            })
            :find()
        end)
        return true
      end,
      multi_select = true,
    })
    :find()
end

return M
