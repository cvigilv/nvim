---@module 'plugin.statusline'
---@author Carlos Vigil-Vásquez
---@license MIT

-- PHILOSOPHY: The `statusline` is meant to display status information pertinent to the
-- currently focused file/buffer. This information comes from current mode, diagnostics, LSP,
-- Git, etc.

-- Setup statusline
local c = require("carlos.helpers.statusline.components")
local h = require("carlos.helpers.statusline.helpers")
local m = require("carlos.helpers.statusline.modifiers")
local ui = require("carlos.helpers.statusline.ui")

_G.carlos.statusline = function()
  local components = {
    -- Git/CWD block
    " ",
    h.ifttt(vim.b.gitsigns_status_dict, m.important(c.gitbranch()), nil),
    h.ifttt(vim.b.gitsigns_status_dict, "  ", nil),
    h.ifttt(vim.b.gitsigns_status_dict, c.gitstatus()),
    " ",
    ui.align(),

    -- Buffer block
    " ",
    -- c.harpoon_cheat(),
    -- " ",
    c.fileicon(),
    h.ifttt(vim.b.gitsigns_status_dict, c.filepath(), nil),
    m.important(c.filename() .. c.filestatus()),
    " ",

    -- LSP block
    ui.align(),
    " ",
    m.important(c.lsp()),
    c.env(),
    h.ifttt(c.diagnostics() ~= "", "  ", nil),
    h.ifttt(c.diagnostics() ~= "", c.diagnostics(), nil),
    " ",
  }

  return vim.fn.join(vim.tbl_filter(function(value) return value ~= "" end, components), "")
end

vim.o.statusline = "%{%v:lua.carlos.statusline()%}"

-- Special statuslines for some filetypes
-- TODO: Leave term statusline to only current shell
local augroup = vim.api.nvim_create_augroup("carlos::statusline", { clear = true })

-- oil.nvim {{{
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = augroup,
  callback = function()
    if vim.api.nvim_get_option_value("ft", { scope = "local" }) == "oil" then
      local components = {
        ui.align(),
        " ",
        c.recording_macro(),
        m.important(""),
        " ",
        m.important(c.oil()),
        c.filestatus(),
        ui.align(),
      }

      vim.api.nvim_set_option_value(
        "stl",
        vim.fn.join(vim.tbl_filter(function(value) return value ~= "" end, components), ""),
        { scope = "local" }
      )
    end
  end,
}) -- }}}
-- quickfix {{{
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = augroup,
  callback = function()
    if vim.api.nvim_get_option_value("ft", { scope = "local" }) == "qf" then
      local components = {
        "    ",
        "󱖫 ",
        m.important("%t%{exists('w:quickfix_title')? ' '.w:quickfix_title : ''}"),
        ui.align(),
      }

      vim.api.nvim_set_option_value(
        "stl",
        vim.fn.join(vim.tbl_filter(function(value) return value ~= "" end, components), ""),
        { scope = "local" }
      )
    end
  end,
}) -- }}}
-- terminal {{{
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = augroup,
  callback = function()
    if vim.api.nvim_get_option_value("buftype", { scope = "local" }) == "terminal" then
      local components = {
        ui.align(),
        "%f",
        ui.align(),
      }
      vim.api.nvim_set_option_value(
        "stl",
        vim.fn.join(vim.tbl_filter(function(value) return value ~= "" end, components), ""),
        { scope = "local" }
      )
    end
  end,
}) -- }}}
