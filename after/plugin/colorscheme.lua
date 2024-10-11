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
      MsgArea = { bg = "#FFFDF9" },
      TabLine = { bg = c.StatusLine.fg },
      TabLineSel = { bg = c.StatusLineNC.fg },
      TabLineFill = { bg = "#FFFDF9" },
      CursorLine = { bg = c.StatusLineNC.fg },
      StatusLine = { bg = c.StatusLineNC.fg, bold = true },
      StatusLineCap = { bg = c.StatusLineNC.fg, fg = "#FFFDF9" },
      WinBar = { fg = c.Comment.fg, bg = c.Normal.bg, bold = true },
      WinBarNC = { fg = c.Comment.fg, bg = c.Normal.bg, bold = false, italic = true },
      Function = { fg = c.Function.fg, bold = true },
      Statement = { fg = c.Statement.fg, bold = true },
      Conditional = { link = "Statement" },
      Repeat = { link = "Statement" },
      Label = { link = "Statement" },
      Keyword = { link = "Statement" },
      Exception = { link = "Statement" },

      Added = { fg = c.Normal.fg, bg = "#BCCE95" },
      GitSignsAdd = vim.tbl_extend("force", c.Added, { bg = "#BCCE95" }),
      GitSignsAddNr = vim.tbl_extend(
        "force",
        c.Added,
        { fg = c.Normal.bg, bg = "#BCCE95", bold = true }
      ),
      GitSignsAddLn = { link = "GitSignsAdd" },

      Changed = { fg = c.Normal.fg, bg = "#C9E8D5" },
      GitSignsChange = vim.tbl_extend("force", c.Changed, { bg = "#C9E8D5" }),
      GitSignsChangeNr = vim.tbl_extend(
        "force",
        c.Changed,
        { fg = c.Normal.bg, bg = "#C9E8D5", bold = true }
      ),
      GitSignsChangeLn = { link = "GitSignsChange" },

      Removed = { fg = c.Normal.fg, bg = "#FCB595" },
      GitSignsDelete = vim.tbl_extend(
        "force",
        c.Removed,
        { fg = c.Normal.bg, bg = "#FCB595", bold = true }
      ),
      GitSignsDeleteNr = { link = "GitSignsDelete" },
      GitSignsDeleteLn = { link = "GitSignsDelete" },
    })
  end,
})

-- -- Set background based on current time
-- local current_hr = tonumber(os.date("%H", os.time()))
-- if current_hr > 6 and current_hr < 18 then
--   vim.cmd.colorscheme("retrobox")
--   vim.cmd("set bg=light")
-- else
--   vim.cmd.colorscheme("patana")
--   vim.cmd("set bg=dark")
-- end
-- vim.cmd("silent !tmux source ~/.config/tmux/tmux_" .. vim.o.background .. ".conf")

vim.cmd("set bg=light")
vim.cmd("colorscheme retrobox")
