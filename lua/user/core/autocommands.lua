-- Highlight yanked text
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
	pattern = { "*" },
	callback = function()
		vim.highlight.on_yank({ higroup = "IncSearch", timeout = 500 })
	end,
})

-- Terminal behaviour
vim.api.nvim_create_autocmd({ "TermOpen" }, {
	pattern = { "*" },
	callback = function()
		vim.o.relativenumber = false
		vim.o.number = false
	end,
})

-- Refresh MiniStarter after calculating `lazy.nvim` stats
vim.api.nvim_create_autocmd({ "User" }, {
	pattern = { "LazyVimStarted" },
	callback = function()
		if vim.bo.filetype == "starter" then
			require("mini.starter").refresh()
			vim.notify_once("Refreshed MiniStarter dashboard", 3)
		end
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
		if vim.opt.buftype:get() == "terminal" then
			vim.cmd(":startinsert")
		end
	end,
})

-- Automatically open quickfix
vim.cmd([[autocmd QuickFixCmdPost [^l]* cwindow]])
vim.cmd([[autocmd QuickFixCmdPost    l* lwindow]])
vim.cmd([[autocmd VimEnter            * cwindow]])

-- Activate cursorline only for focused window
-- vim.cmd([[
-- augroup FocusHighlight
--     au!
--     au VimEnter * setlocal cursorline
--     au WinEnter * setlocal cursorline
--     au BufWinEnter * setlocal cursorline
--     au WinLeave * setlocal nocursorline
-- augroup END
-- ]])
