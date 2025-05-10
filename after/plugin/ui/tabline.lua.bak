---@module 'plugin.tabline'
---@author Carlos Vigil-Vásquez
---@license MIT

-- PHILOSOPHY: The `tabline` is meant to display information pertinent to the different
-- "workspaces" one has open in the current instance of Neovim. Here we just showcase the
-- currently focused file/buffer, the number of additional windows open in this tab and
-- if the current tab has any kind of status change.

local C = require("carlos.helpers.tabline.components")
local H = require("carlos.helpers.colors")
local U = require("carlos.helpers.tabline.ui")

-- Set custom color groups for tabline
local setup_tabline_hlgroups = function()
  local colors = {
    Normal = H.get_hlgroup_table("Normal"),
    Comment = H.get_hlgroup_table("Comment"),
    Constant = H.get_hlgroup_table("Constant"),
    TabLine = H.get_hlgroup_table("TabLine"),
    TabLineSel = H.get_hlgroup_table("TabLineSel"),
    TabLineFill = H.get_hlgroup_table("TabLineFill"),
  }

  local hlgroups = {
    TabLineCaps = { fg = colors.TabLine.bg, bg = colors.TabLineFill.bg },
    TabLineSelCaps = { fg = colors.TabLineSel.bg, bg = colors.TabLineFill.bg },
    TabLineSelAccent = { fg = colors.Constant.fg, bg = colors.TabLineSel.bg, bold = true },
    TabLineSelDim = { fg = colors.Comment.fg, bg = colors.TabLineSel.bg },
    TabLineAccent = { fg = colors.Constant.fg, bg = colors.TabLine.bg },
    TabLineDim = { fg = colors.Comment.fg, bg = colors.TabLine.bg },
  }

  H.override_hlgroups(hlgroups)
end
setup_tabline_hlgroups()

-- Setup tabline
local hlgroup_lut = {
  [true] = {
    caps = "%#TabLineSelCaps#",
    normal = "%#TabLineSel#",
    accent = "%#TabLineSelAccent#",
    dim = "%#TabLineSelDim#",
  },
  [false] = {
    caps = "%#TabLineCaps#",
    normal = "%#TabLine#",
    accent = "%#TabLineAccent#",
    dim = "%#TabLineDim#",
  },
}

_G.carlos.tabline = function()
  local content = ""

  -- Add Tabline content for each tab page
  for index = 1, vim.fn.tabpagenr("$") do
    local winnr = vim.fn.tabpagewinnr(index)
    local buflist = vim.fn.tabpagebuflist(index)
    local bufnr = buflist[winnr]
    local bufname = vim.fn.bufname(bufnr)
    local selected = (index == vim.fn.tabpagenr())

    local tab_has_status = false
    for _, bnr in ipairs(buflist) do
      --TODO: Add LSP status also (just ERROR or WARNING level though)
      if vim.fn.getbufvar(bnr, "&mod") == 1 then
        tab_has_status = true
        break
      end
    end

    local nbuffers = 0
    for _, buf in pairs(buflist) do
      if vim.bo[buf].filetype ~= "incline" then nbuffers = nbuffers + 1 end
    end

    -- Set tab index
    local components = {
      "%" .. index .. "T",

      -- Add left cap
      hlgroup_lut[selected]["caps"],
      "",

      -- Add tab index
      hlgroup_lut[selected]["accent"],
      " ",
      index < 10 and U.index_icons[index][tab_has_status] or U.index_icons.more[tab_has_status],

      -- Add focused buffer information
      hlgroup_lut[selected]["normal"],
      " ",
      C.fileicon(bufname),
      vim.fn.fnamemodify(bufname, ":t"),

      -- Add other relevant tab information
      hlgroup_lut[selected]["accent"],
      (nbuffers > 1 and "+" .. nbuffers - 1 or ""),
      "  ",

      -- Add right cap
      hlgroup_lut[selected]["caps"],
      "",
    }
    content = content .. vim.fn.join(components, "")
  end

  content = content .. "%#TabLineFill#"
  return content
end

vim.o.tabline = "%!v:lua.carlos.tabline()"

-- Autocommands
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("carlos::ui", { clear = false }),
  pattern = "*",
  callback = setup_tabline_hlgroups,
})
