local function sync_theme()
  vim.cmd("silent !tmux source ~/.config/tmux/tmux_" .. vim.o.background .. ".conf")
end

vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "background",
  callback = function()
    vim.cmd("silent !tmux source ~/.config/tmux/tmux_" .. vim.o.background .. ".conf")
  end,
})

vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = "iceberg",
  callback = function(ev)
    local hc = require("user.helpers.colors")

    -- Overrides
    local alloverrides = {
      -- Diff
      Added = { fg = "#005000", bg = "#ccefcf" },
      DiffAdd = { link = "Added" },
      GitGutterAdd = { link = "Added" },
      Changed = { bg = "#ffe5b9", fg = "#553d00" },
      DiffChange = { link = "Changed" },
      GitGutterChanged = { link = "Changed" },
      DiffText = { bg = "#ffd09f", fg = "#553d00", italic = true },
      Removed = { fg = "#8f1313", bg = "#ffd4d8" },
      DiffDelete = { link = "Removed" },
      GitGutterDelete = { link = "Removed" },
      -- UI
      WinBar = { bg = "#ffffff", fg = hc.get_hlgroup_table("StatusLine").bg },
      WinBarNC = { bg = "#ffffff", fg = hc.get_hlgroup_table("StatusLine").bg },
      StatusLine = hc.get_hlgroup_table("StatusLineNC"),
      TabLineFill = { bg = "#ffffff" },
      MsgArea = { bg = "#ffffff", fg = "#000000" },
      Type = hc.get_hlgroup_table("TabLine"),
    }
    hc.override_hlgroups(alloverrides)

    -- Modifications
    local allchanges = {
      ColorColumn = { link = "CursorLine" },
      TabLineSel = { bold = true },
      Keyword = { italic = true },
      Folded = { link = "Comment" },
      WinBar = { link = "Normal" },
      WinBarNC = { link = "Normal" },
      EndOfBuffer = { link = "CursorLine" },
      StatusLine = { bold = true },
      LineNr = { bold = true },
      Whitespace = { italic = true },
      WinSeparator = { link = "Comment" },
      NonText = { fg = hc.get_hlgroup_table("Comment").fg, italic = true },
      NormalFloat = { bg = "#ffffff" },
    }
    for hlgroup, overrides in pairs(allchanges) do
      hc.modify_hlgroup(hlgroup, overrides)
    end
  end,
})

vim.o.background = "light"
vim.cmd("colorscheme iceberg")
sync_theme()
