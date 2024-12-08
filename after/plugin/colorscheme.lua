local function sync_theme()
  vim.cmd("silent !tmux source ~/.config/tmux/tmux_" .. vim.o.background .. ".conf")
end

vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "background",
  callback = function()
    vim.cmd("silent !tmux source ~/.config/tmux/tmux_" .. vim.o.background .. ".conf")
  end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "retrobox",
  desc = "`retrobox` overrides",
  callback = function()
    local c_helper = require("user.helpers.colors")

    local c = {
      Normal = c_helper.get_hlgroup_table("Normal"),
      Pmenu = c_helper.get_hlgroup_table("Pmenu"),
      Comment = c_helper.get_hlgroup_table("Comment"),
      Function = c_helper.get_hlgroup_table("Function"),
      Statement = c_helper.get_hlgroup_table("Statement"),
      StatusLine = c_helper.get_hlgroup_table("StatusLine"),
      StatusLineNC = c_helper.get_hlgroup_table("StatusLineNC"),
      Constant = c_helper.get_hlgroup_table("Constant"),
      Identifier = c_helper.get_hlgroup_table("Identifier"),
      Added = c_helper.get_hlgroup_table("Added"),
      Changed = c_helper.get_hlgroup_table("Changed"),
      Removed = c_helper.get_hlgroup_table("Removed"),
    }

    c_helper.override_hlgroups({
      Constant = vim.tbl_extend("force", c.Constant, { reverse = true, bold = true }),
      MsgArea = { bg = vim.o.background == "light" and "#FFFDF9" or "#000000" },
      TabLine = { bg = c.StatusLine.fg },
      TabLineSel = { bg = c.StatusLineNC.fg },
      TabLineFill = { bg = vim.o.background == "light" and "#FFFDF9" or "#000000" },
      CursorLine = { bg = c.StatusLineNC.fg },
      StatusLine = { bg = c.StatusLineNC.fg, bold = true },
      StatusLineCap = {
        bg = c.StatusLineNC.fg,
        fg = vim.o.background == "light" and "#FFFDF9" or "#000000",
      },
      WinBar = { fg = c.Comment.fg, bg = c.Normal.bg, bold = true },
      WinBarNC = { fg = c.Comment.fg, bg = c.Normal.bg, bold = false, italic = true },
      Function = { fg = c.Function.fg, bold = true },
      Statement = { fg = c.Statement.fg, bold = true },
      Conditional = { link = "Statement" },
      Repeat = { link = "Statement" },
      Label = { link = "Statement" },
      Keyword = { link = "Statement" },
      Exception = { link = "Statement" },
      Folded = { bg = c.Normal.bg },
      FloatBorder = { fg = c.Comment.fg, bg = c.Pmenu.bg },
      FloatTitle = { fg = c.Comment.fg, bg = c.Pmenu.bg },
      NonText = { fg = c.Comment.fg, italic = true },

      -- Diff {{{
      Added = { fg = c.Normal.bg, bg = "#BCCE95" },
      GitSignsAdd = { link = "Added" },
      GitSignsAddNr = vim.tbl_extend("force", c.Added, { bold = true }),
      GitSignsAddLn = { link = "Added" },

      Changed = { fg = c.Normal.bg, bg = "#C9E8D5" },
      GitSignsChange = { link = "Changed" },
      GitSignsChangeNr = vim.tbl_extend("force", c.Changed, { bold = true }),
      GitSignsChangeLn = { link = "Changed" },

      Removed = { fg = c.Normal.bg, bg = "#FCB595" },
      GitSignsDelete = { link = "Removed" },
      GitSignsDeleteNr = vim.tbl_extend("force", c.Removed, { bold = true }),
      GitSignsDeleteLn = { link = "Removed" },
      -- }}}
      -- Diagnostics {{{
      DiagnosticDeprecated = { strikethrough = true },
      DiagnosticOk = { fg = c.Normal.fg, bold = true },

      DiagnosticError = { fg = c.Normal.bg, bg = "Red", bold = true },
      DiagnosticDefaultError = { link = "DiagnosticError" },
      DiagnosticFloatingError = { link = "DiagnosticError" },
      DiagnosticSignError = { link = "DiagnosticError" },
      DiagnosticVirtualTextError = { link = "DiagnosticError" },

      DiagnosticWarn = { bg = "Orange", bold = true },
      DiagnosticDefaultWarn = { link = "DiagnosticWarn" },
      DiagnosticFloatingWarn = { link = "DiagnosticWarn" },
      DiagnosticSignWarn = { link = "DiagnosticWarn" },
      DiagnosticVirtualTextWarn = { link = "DiagnosticWarn" },

      DiagnosticHint = { bg = "LightBlue", bold = true },
      DiagnosticDefaultHint = { link = "DiagnosticHint" },
      DiagnosticFloatingHint = { link = "DiagnosticHint" },
      DiagnosticSignHint = { link = "DiagnosticHint" },
      DiagnosticVirtualTextHint = { link = "DiagnosticHint" },

      DiagnosticInfo = { fg = c.Comment.fg, bold = true },
      DiagnosticDefaultInfo = { link = "DiagnosticInfo" },
      DiagnosticFloatingInfo = { link = "DiagnosticInfo" },
      DiagnosticSignInfo = { link = "DiagnosticInfo" },
      DiagnosticVirtualTextInfo = { link = "DiagnosticInfo" },

      DiagnosticUnderlineError = { sp = "Red", undercurl = true, bold = true },
      DiagnosticUnderlineWarn = { sp = "Orange", undercurl = true, bold = true },
      DiagnosticUnderlineHint = { sp = "LightBlue", undercurl = true, bold = true },
      DiagnosticUnderlineInfo = { sp = c.Normal.fg, undercurl = true, bold = true },
      DiagnosticUnderlineOk = { sp = c.Normal.fg, undercurl = true, bold = true },
      --}}}
      -- Telescope {{{
      TelescopeSelection = { link = "CursorLine" },
      -- }}}
    })
  end,
})

vim.cmd("colorscheme personal")
sync_theme()
