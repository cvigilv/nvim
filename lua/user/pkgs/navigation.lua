return {
	{
		"numToStr/Navigator.nvim",
		config = function()
			require("Navigator").setup({
				auto_save = nil,
				disable_on_zoom = true,
			})

			-- Keybindings
			local opts = { noremap = true, silent = true }

			vim.keymap.set({ "t", "n" }, "<C-h>", require("Navigator").left, opts)
			vim.keymap.set({ "t", "n" }, "<C-k>", require("Navigator").up, opts)
			vim.keymap.set({ "t", "n" }, "<C-l>", require("Navigator").right, opts)
			vim.keymap.set({ "t", "n" }, "<C-j>", require("Navigator").down, opts)
			vim.keymap.set({ "t", "n" }, "<C-p>", require("Navigator").previous, opts)
		end,
	},
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("oil").setup({
				view_options = {
					show_hidden = true,
				},
				columns = { "icon" },
				default_file_explorer = true,
				restore_win_options = true,
				skip_confirm_for_simple_edits = false,
				delete_to_trash = false,
				prompt_save_on_select_new_entry = true,
				keymaps = {
					["g?"] = "actions.show_help",
					["<CR>"] = "actions.select",
					["|"] = "actions.select_vsplit",
					["-"] = "actions.select_split",
					["<C-t>"] = "actions.select_tab",
					["<C-p>"] = "actions.preview",
					["<C-c>"] = "actions.close",
					["<C-r>"] = "actions.refresh",
					["."] = "actions.parent",
					["_"] = "actions.open_cwd",
					["`"] = "actions.cd",
					["g."] = "actions.toggle_hidden",
				},
				-- Set to false to disable all of the above keymaps
				use_default_keymaps = false,
			})

			vim.keymap.set("n", "<leader><CR>", require("oil").open, {
				desc = "File browser",
				noremap = true,
				silent = true,
			})
		end,
	},
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		keys = {
			"<Space>fa",
			"<Space>fh",
			"<Space>fj",
			"<Space>fk",
			"<Space>fl",
			"<Space>ff",
			"}h",
			"{h",
		},
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup({
				setting = {
					get_root_dir = function()
						local cwd = ""
						if vim.b.gitsigns_status_dict ~= nil then
							cwd = vim.b.gitsigns_status_dict["root"]
						else
							---FIXME: Why are vim.loop methods not found?
							---@diagnostic disable-next-line: undefined-field
							cwd = vim.loop.cwd() or ""
						end
						return cwd
					end,
				},
			})

			-- Keymaps
			vim.keymap.set("n", "<Space>fa", function()
				harpoon:list():add()
			end, { desc = "Add file" })
			vim.keymap.set("n", "<Space>ff", function()
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end, { desc = "Toggle quick menu" })

			vim.keymap.set("n", "{h", function()
				harpoon:list():prev()
			end, { desc = "Previous harpoon buffer" })
			vim.keymap.set("n", "}h", function()
				harpoon:list():next()
			end, { desc = "Next harpoon buffer" })

			for i, key in ipairs({ "h", "j", "k", "l" }) do
				vim.keymap.set("n", "<Space>f" .. key, function()
					harpoon:list():select(i)
				end, { desc = "Select buffer #" .. key })
			end

			harpoon:extend({
				UI_CREATE = function(cx)
					vim.keymap.set("n", "|", function()
						harpoon.ui:select_menu_item({ vsplit = true })
					end, { buffer = cx.bufnr, desc = "Open in vertical split" })

					vim.keymap.set("n", "-", function()
						harpoon.ui:select_menu_item({ split = true })
					end, { buffer = cx.bufnr, desc = "Open in split" })

					vim.keymap.set("n", "<C-t>", function()
						harpoon.ui:select_menu_item({ tabedit = true })
					end, { buffer = cx.bufnr, desc = "Open in tab" })
				end,
			})
		end,
	},
}
