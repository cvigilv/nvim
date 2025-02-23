---@module 'plugin.statuscolumn'
---@author Carlos Vigil-Vásquez
---@license MIT

-- Setup statuscolumn
local c = require("carlos.helpers.statuscolumn.components")
local h = require("carlos.helpers.statuscolumn.helpers")
local ui = require("carlos.helpers.statuscolumn.ui")

_G.carlos.statuscolumn = function()
  local signs = h.get_signs()
  local components = {
    " ",
    c.other(signs, "GitSigns"),
    " ",
    ui.aligner(),
    c.linenumber(),
    " ",
    -- "%#CursorLine#▏",
    (vim.v.relnum == 0 and vim.api.nvim_get_option_value("cursorline", { scope = "local" }))
        and "%#CursorLine#"
      or "%#Normal#",
    "▏",
    " ",
  }

  return table.concat(components, "")
end

vim.o.statuscolumn = "%{%v:lua.carlos.statuscolumn()%}"

-- Don't setup statuscolumn in some filetypes and buffers {{{
-- NOTE: This is based on https://github.com/luukvbaal/statuscol.nvim/blob/d6f7f5437c5404d958b88bb73e0721b1c0e09223/lua/statuscol.lua#L445-L463
local augroup = vim.api.nvim_create_augroup("carlos::statuscolumn", { clear = true })

local ignored_buftypes = { "nofile", "help", "quickfix", "loclist" }
vim.api.nvim_create_autocmd("OptionSet", {
  group = augroup,
  pattern = "buftype",
  callback = function()
    if vim.tbl_contains(ignored_buftypes, vim.v.option_new) then
      vim.api.nvim_set_option_value("stc", "", { scope = "local" })
    end
  end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = augroup,
  callback = function()
    if
      vim.tbl_contains(
        ignored_buftypes,
        vim.api.nvim_get_option_value("buftype", { scope = "local" })
      )
    then
      vim.api.nvim_set_option_value("stc", "", { scope = "local" })
    end
  end,
})

local ignored_filetypes = { "ministarter" }
vim.api.nvim_create_autocmd(
  "FileType",
  { group = augroup, pattern = ignored_filetypes, command = "setlocal stc=" }
)
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = augroup,
  callback = function()
    if
      vim.tbl_contains(
        ignored_filetypes,
        vim.api.nvim_get_option_value("filetype", { scope = "local" })
      )
    then
      vim.api.nvim_set_option_value("stc", "", { scope = "local" })
    end
  end,
})
-- }}}
