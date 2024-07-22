return {
	{
		dir = os.getenv("GITDIR") .. "/patana.nvim",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("patana")
		end,
	},
}
