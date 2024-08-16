---@module 'plugin.statusline'
---@author Carlos Vigil-Vásquez
---@license MIT

vim.g.user_qf_open = false

-- Setup custom colors for statusline
local setup_statusline_hlgroups = function()
  local hc = require("user.helpers.colors")

  local hlgroups = {
    StatusLineCap = {
      fg = hc.get_hlgroup_table("MsgArea").bg,
      bg = hc.get_hlgroup_table("StatusLine").bg,
    },
  }

  hc.override_hlgroups(hlgroups)
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("user::ui", { clear = false }),
  pattern = "*",
  callback = setup_statusline_hlgroups,
})

setup_statusline_hlgroups()

-- Setup statusline
local statusline = require("user.helpers.statusline")
local c, h, m, ui =
  statusline.components, statusline.helpers, statusline.modifiers, statusline.ui

_G.statusline = function()
  local components = {
    -- Cap
    h.ifttt(vim.g.user_qf_open, "", "%#MsgArea#" .. ui.align() .. ui.leftcap() .. " "),

    -- Modal block
    " ",
    m.important(c.mode()),
    " ",
    "",
    h.center(c.location(), 7),
    "•",

    -- Buffer block
    " ",
    c.harpoon(),
    " ",
    c.fileicon(),
    h.ifttt(vim.b.gitsigns_status_dict, c.filepath(), nil),
    m.important(c.filename()),
    c.filestatus(),

    -- Git/CWD block
    h.ifttt(vim.b.gitsigns_status_dict, "  ", nil),
    m.important(h.ifttt(vim.b.gitsigns_status_dict, c.gitbranch(), " " .. c.filepath())),
    " ",
    h.ifttt(vim.b.gitsigns_status_dict, c.gitstatus()),
    " ",

    -- Misc block
    ui.align(),
    c.recording_macro(),
    ui.align(),

    -- LSP block
    " ",
    m.important(c.lsp()),
    h.ifttt(c.diagnostics() ~= "", "  ", nil),
    c.diagnostics(),
    " ",

    -- Cap
    h.ifttt(vim.g.user_qf_open, "", ui.rightcap() .. "%#MsgArea#" .. ui.align()),
  }

  return vim.fn.join(vim.tbl_filter(function(value) return value ~= "" end, components), "")
end

vim.o.statusline = "%{%v:lua.statusline()%}"

-- Special statuslines for some filetypes
local augroup = vim.api.nvim_create_augroup("user::statusline", { clear = true })
-- oil.nvim {{{
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = augroup,
  callback = function()
    if vim.api.nvim_get_option_value("ft", { scope = "local" }) == "oil" then
      local components = {
        "%#StatusLineEmpty#",
        ui.align(),
        ui.leftcap(),
        " ",
        c.recording_macro(),
        m.important(" Oildir"),
        " ",
        m.important(c.oil()),
        c.filestatus(),
        " ",
        ui.rightcap(),
        "%#StatusLineEmpty#",
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
        ui.leftcap(),
        c.recording_macro(),
        m.important("%t%{exists('w:quickfix_title')? ' '.w:quickfix_title : ''}"),
        ui.align(),
        ui.rightcap(),
      }

      vim.api.nvim_set_option_value(
        "stl",
        vim.fn.join(vim.tbl_filter(function(value) return value ~= "" end, components), ""),
        { scope = "local" }
      )

      vim.api.nvim_set_option_value(
        "stl",
        vim.fn.join(vim.tbl_filter(function(value) return value ~= "" end, components), ""),
        { scope = "local" }
      )
    end
  end,
}) -- }}}
