---@module "plugin.zk.ui"
---@author Carlos Vigil-Vásquez
---@license MIT 2024
---
local S = require("carlos.helpers.string")
local U = require("plugin.zk.utils")
local W = require("carlos.helpers.windows.factory")

local M = {}

-- TODO: see what to do with this
local namespace = vim.api.nvim_create_namespace("zk.ui")

M.show_links = function(note, opts)
  -- Define note information
  note = note or vim.fn.expand("%:p")
  local note_win = vim.api.nvim_get_current_win()
  local note_buf = vim.api.nvim_get_current_buf()

  -- Get note links
  local all_links = U.get_links(note, opts)

  -- Construct data structure containing the information about the link
  local data = {}
  for kind, links in pairs(all_links) do
    for _, f in ipairs(links) do
      if vim.tbl_contains(vim.tbl_keys(data), f) then
        data[f] = { path = f, title = U.get_title(f), tags = U.get_tags(f), kind = "both" }
      else
        data[f] = { path = f, title = U.get_title(f), tags = U.get_tags(f), kind = kind }
      end
    end
  end
  data = vim.tbl_values(data)
  table.sort(data, function(a, b)
    local order = { from = 1, both = 2, to = 3 }
    return order[a.kind] > order[b.kind]
  end)

  -- TODO: Test changing file path with tags just after title (sort tags by count in ZK)
  local link_kind = { from = "F", to = "T", both = "B" }
  local contents = vim
    .iter(data)
    :map(function(v)
      local function shorter_str(s, l)
        l = l or 1
        local shorten = s:sub(1, l)
        return S.rpad(shorten .. (#shorten > l and "…" or " "), l + 1, " ")
      end

      local short_path = shorter_str(vim.fs.basename(v.path), 12)
      local short_title = shorter_str(v.title, 42)
      return " " .. link_kind[v.kind] .. " · " .. short_title .. "   " .. short_path
    end)
    :totable()

  -- TODO: Add section header with counts
  -- table.insert(
  --   contents,
  --   1,
  --   S.pad("# T = " .. #all_links.to, 32, " ") .. S.pad("# F = " .. #all_links.from, 32, " ")
  -- )

  local links_win, links_buf = W.new_floating_win(contents, {
    title = " Note Links  - " .. vim.fs.basename(note) .. " ",
    footer = " `q` to quit / `<CR>` to open in buffer / `p` to preview ",
    border = "single",
    width = function() return 64 end,
    win_opts = { winblend = 0 },

    -- TODO: add this to user opts
    -- TODO: improve defaults
    winhighlight = {
      "FloatNormal:ColorColumn",
      "NormalFloat:ColorColumn",
      "FloatBorder:ColorColumn",
      "FloatTitle:ColorColumn",
      "FloatFooter:ColorColumn",
      "EndOfBuffer:ColorColumn",
    },
  })

  -- UI
  vim.api.nvim_buf_set_name(links_buf --[[@as number]], "Note Links - " .. U.get_title(note))
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = links_buf })
  vim.api.nvim_set_option_value("number", false, { win = links_win })
  vim.api.nvim_set_option_value("relativenumber", false, { win = links_win })

  -- TODO: add a third color for bidirectional links
  -- TODO: improve to have 3 distinct areas (**type** title _path_)
  vim.cmd([[syntax match ZkFromLinks /^ F .*/ |
      syntax match ZkBothLinks /^ B .*/ |
      syntax match ZkToLinks /^ T .*/ |
      highlight link ZkFromLinks Removed |
      highlight link ZkBothLinks Changed |
      highlight link ZkToLinks Added]])

  -- TODO: add keybind that skips headers and lets you fold them
  -- TODO: disable lateral scrolling (so I can hide fold marks)
  -- Keybinds
  local previewing = false
  opts = { silent = true, noremap = true, buffer = links_buf }

  -- Open link under cursor
  vim.keymap.set("n", "<CR>", function()
    local selection = data[vim.api.nvim_win_get_cursor(links_win)[1]]
    vim.api.nvim_win_close(links_win, true)
    vim.api.nvim_set_current_win(note_win)
    vim.cmd("e" .. selection.path)
  end, opts)

  -- Close links windows
  vim.keymap.set("n", "<Esc>", function()
    vim.api.nvim_win_close(links_win, true)
    vim.api.nvim_set_current_win(note_win)
    vim.api.nvim_win_set_buf(note_win, note_buf)
  end, opts)

  -- Toogle preview
  vim.keymap.set("n", "p", function()
    previewing = not previewing
    if not previewing then vim.api.nvim_win_set_buf(note_win, note_buf) end
  end, opts)

  -- h,j,k,l movement
  vim.keymap.set("n", "j", function()
    -- Move cursor down
    local cursor = vim.api.nvim_win_get_cursor(links_win)
    local current_line = cursor[1]
    local new_line = current_line + 1
    local last_line = vim.api.nvim_buf_line_count(links_buf)
    new_line = math.min(new_line, last_line)
    vim.api.nvim_win_set_cursor(links_win, { new_line, cursor[2] })

    -- Preview file if toogled
    if previewing then
      local selection = data[vim.api.nvim_win_get_cursor(links_win)[1]]
      vim.api.nvim_set_current_win(note_win)
      vim.cmd("e" .. selection.path)
      vim.api.nvim_set_current_win(links_win)
    end
  end, opts)

  vim.keymap.set("n", "k", function()
    -- Move cursor up
    local cursor = vim.api.nvim_win_get_cursor(links_win)
    local current_line = cursor[1]
    local new_line = current_line - 1
    new_line = math.max(new_line, 1)
    vim.api.nvim_win_set_cursor(links_win, { new_line, cursor[2] })

    -- Preview file if toogled
    if previewing then
      local selection = data[vim.api.nvim_win_get_cursor(links_win)[1]]
      vim.api.nvim_set_current_win(note_win)
      vim.cmd("e" .. selection.path)
      vim.api.nvim_set_current_win(links_win)
    end
  end, opts)

  vim.keymap.set("n", "l", "<Nop>", opts)
  vim.keymap.set("n", "h", "<Nop>", opts)

  return links_win
end

return M
