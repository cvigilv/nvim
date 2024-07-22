---@module 'plugin.statuscolumn'
---@author Carlos Vigil-Vásquez
---@license MIT

-- TODO: Implement buffer centering using statuscolumn
vim.g.statuscolumn_center = false

-- Setup statuscolumn{{{
local c = require("user.helpers.statuscolumn.components")
local h = require("user.helpers.statuscolumn.helpers")
local ui = require("user.helpers.statuscolumn.ui")

_G.statuscolumn = function()
  local signs = h.get_signs()
  local components = {
    c.fold(vim.v.lnum),
    c.other(signs, "GitSigns"),
    ui.aligner(),
    c.linenumber(),
    " ",
    vim.v.relnum == 0 and "%#CursorLine#" or "%#Normal#",
    " ",
  }
  if vim.bo.filetype == "starter" then components = { " " } end

  return table.concat(components, "")
end

vim.o.statuscolumn = "%{%v:lua.statuscolumn()%}" -- }}}
-- Don't setup statuscolumn in some filetypes and buffers {{{
local augroup = vim.api.nvim_create_augroup("user::statuscolumn", { clear = true })

local ignored_filetypes = {
  "starter",
}
local ignored_buftypes = {
  "nofile",
  "help",
  "quickfix",
  "loclist",
}

-- https://github.com/luukvbaal/statuscol.nvim/blob/d6f7f5437c5404d958b88bb73e0721b1c0e09223/lua/statuscol.lua#L445-L463
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
        vim.api.nvim_get_option_value("ft", { scope = "local" })
      )
    then
      vim.api.nvim_set_option_value("stc", "", { scope = "local" })
    end
  end,
})

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
        vim.api.nvim_get_option_value("bt", { scope = "local" })
      )
    then
      vim.api.nvim_set_option_value("stc", "", { scope = "local" })
    end
  end,
})
-- }}}
