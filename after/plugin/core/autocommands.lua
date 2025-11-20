-- Highlight yanked text
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  pattern = { "*" },
  callback = function() vim.highlight.on_yank({ higroup = "IncSearch", timeout = 500 }) end,
})

-- Terminal behaviour
vim.api.nvim_create_autocmd({ "TermOpen" }, {
  pattern = { "*" },
  callback = function()
    vim.api.nvim_set_option_value("filetype", "terminal", { scope = "local" })
  end,
})

-- Update listchars
local function update_lead()
  local lcs = vim.opt_local.listchars:get()
  local tab = vim.fn.str2list(lcs.tab)
  local space = vim.fn.str2list(lcs.multispace or lcs.space)
  local lead = { tab[1] }
  for i = 1, vim.bo.tabstop - 1 do
    lead[#lead + 1] = space[i % #space + 1]
  end
  vim.opt_local.listchars:append({ leadmultispace = vim.fn.list2str(lead) })
end

vim.api.nvim_create_autocmd("OptionSet", {
  pattern = { "listchars", "tabstop", "filetype" },
  callback = update_lead,
})
vim.api.nvim_create_autocmd("VimEnter", { callback = update_lead, once = true })

-- Always enter terminal pane in Insert mode
vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter" }, {
  pattern = { "*" },
  callback = function()
    if vim.opt.buftype:get() == "terminal" then vim.cmd(":startinsert") end
  end,
})

-- Automatically open quick-fix
vim.cmd([[autocmd QuickFixCmdPost [^l]* cwindow]])
vim.cmd([[autocmd QuickFixCmdPost    l* lwindow]])
vim.cmd([[autocmd VimEnter            * cwindow]])

-- Activate cursor line only for focused window
vim.cmd([[
augroup FocusHighlight
    au!
    au VimEnter * setlocal cursorline
    au WinEnter * setlocal cursorline
    au BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
augroup END
]])

-- `help` and `man` open to the right (if possible)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "help", "man" },
  callback = function()
    local MIN_WIDTH_RATIO = 2
    local width = vim.api.nvim_win_get_width(0)
    local do_vsplit = width > vim.o.textwidth * MIN_WIDTH_RATIO

    if do_vsplit then vim.cmd("wincmd L") end
  end,
})

-- Better built-in file path completion
local function simulate_keypress(key)
  local termcodes = vim.api.nvim_replace_termcodes(key, true, false, true)
  vim.api.nvim_feedkeys(termcodes, "m", false)
end

vim.api.nvim_create_autocmd("CompleteDone", {
  callback = function()
    if vim.v.event.complete_type == "files" and vim.v.event.reason == "accept" then
      simulate_keypress("<c-x>")
      simulate_keypress("<c-f>")
    end
  end,
  desc = "Complete multiple path components with built-in completion (<C-x><C-f>)",
})

-- Automatically open file picker whenever I enter neovim without arguments
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local argv = vim.tbl_values(vim.v.argv)
    local is_session = vim.tbl_contains(argv, "-S")
    if
      vim.fn.argc() == 0
      and not vim.tbl_contains(vim.tbl_values(vim.v.argv), "-c")
      and not is_session
    then
      vim.cmd("Telescope find_files layout_config={height=0.5}")
    end
  end,
})
