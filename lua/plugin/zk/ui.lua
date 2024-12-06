---@module "plugin.zk.ui"
---@author Carlos Vigil-Vásquez
---@license MIT 2024

local W = require("user.helpers.ui.windows")
local U = require("plugin.zk.utils")

local M = {}

M.show_links = function(note, opts)
  note = note or vim.fn.expand("%:p")
  local note_win = vim.api.nvim_get_current_win()
  local note_buf = vim.api.nvim_get_current_buf()

  local links = U.get_links(note, opts)
  vim.print(links)

  local contents = {}
  for _, f in ipairs(links.from) do
    table.insert(contents, "F | " .. f)
  end

  for _, f in ipairs(links.to) do
    table.insert(contents, "T | " .. f)
  end

  local links_win, links_buf = W.new_floating_win(contents, {
    title = " Note Links  - " .. note .. " ",
    footer = " `q` to quit / `<CR>` to open in current buffer / `p` to preview ",
  })
  vim.print(links_win, links_buf)

  -- UI
  vim.api.nvim_buf_set_name(links_buf --[[@as number]], "Note Links - " .. note)
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = links_buf })
  vim.api.nvim_set_option_value("number", false, { win = links_win })
  vim.api.nvim_set_option_value("relativenumber", false, { win = links_win })

  -- Keybinds
  vim.keymap.set("n", "<CR>", function()
    local line_contents =
      vim.split(vim.api.nvim_get_current_line(), "|", { plain = true, trimempty = true })
    local path = line_contents[2]
    vim.print(path)

    vim.api.nvim_win_close(links_win, true)
    vim.api.nvim_set_current_win(note_win)
    vim.cmd("e" .. path)
  end, { silent = true, noremap = true, buffer = links_buf })
end

return M
