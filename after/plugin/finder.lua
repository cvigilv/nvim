---@module 'plugin.finder'
---@author Carlos Vigil-Vásquez
---@license MIT
---@description Small plugin to improve find, grep and vimpgrep experience

-- Add some relevant searching user commands
-- * Search: String in CWD files,
-- * Files: Files in CWD,
-- * GitFiles: Files tracked by git,
-- * GitSearch: String in CWD files,
-- * Todos: TODO tags in CWD,
-- * Zk: Note titles,
-- * ZkContents: Notes string search,
-- * ZkTags: Notes search by tag

-- function vim.api.nvim_create_user_command(name: string, command: any, opts: vim.api.keyset.user_command)

-- Search
local searchprg = "rg --vimgrep -uu"
if vim.b.gitsigns_status_dict ~= nil then
	searchprg = searchprg
		.. " --ignore-file="
		.. vim.b.gitsigns_status_dict["root"]
		.. "/.gitignore"
		.. " <args> "
		.. vim.b.gitsigns_status_dict["root"]
		.. " -g !*.git"
else
	searchprg = searchprg .. " <args> "
end

vim.cmd("command! -nargs=+ -bar Search silent! cgetexpr system('" .. searchprg .. "') | copen")

-- Files
-- local filesprg = "rg --vimgrep -uu"
-- if vim.b.gitsigns_status_dict ~= nil then
-- 	filesprg = "find " .. vim.b.gitsigns_status_dict["root"] .. [[ -type f -print | rg --vimgrep -uu <args> ]]
-- end
-- vim.cmd("command! -nargs=+ -bar Files silent! cgetexpr system('" .. filesprg .. "') | copen")

-- GitSearch
local gitsearchprg = "git grep -n --column <args>"
if vim.b.gitsigns_status_dict == nil then
	vim.cmd("command! -nargs=+ -bar GitSearch silent! cgetexpr system('" .. gitsearchprg .. "') | copen")
end

-- GitFiles
local gitfilesprg = "git ls-files | rg --vimgrep -uu <args>"
if vim.b.gitsigns_status_dict == nil then
	vim.cmd("command! -nargs=+ -bar GitFiles silent! cgetexpr system('" .. gitfilesprg .. "') | copen")
end
