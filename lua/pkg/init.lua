---@module "pkg"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

-- Helpers
local gh = function(x) return "https://github.com/" .. x end
local cvv = function(x) return "file://" .. vim.fs.abspath(os.getenv("GITDIR") .. x) end

-- Ensure packages are installed
vim.pack.add({
  -- Libraries (libraries.lua)
  gh("kkharji/sqlite.lua"),
  cvv("jason.nvim"),
  gh("rktjmp/lush.nvim"),

  -- Navigation (navigation.lua)
  gh("hrsh7th/nvim-swm"),
  gh("numToStr/Navigator.nvim"),
  gh("stevearc/oil.nvim"),
  gh("nvim-tree/nvim-web-devicons"),
  gh("nvim-telescope/telescope.nvim"),
  gh("nvim-lua/plenary.nvim"),

  -- UI (ui.lua)
  gh("Aasim-A/scrollEOF.nvim"),
  gh("stevearc/quicker.nvim"),
  gh("folke/which-key.nvim"),
  gh("hernancerm/bareline.nvim"),
  gh("zenbones-theme/zenbones.nvim"),

  -- PKM (pkm.lua)
  gh("nvim-orgmode/telescope-orgmode.nvim"),
  cvv("telescope-zotero.nvim"),
  gh("nvim-orgmode/orgmode"),
  cvv("denote.nvim"),

  -- Misc (misc.lua)
  cvv("diferente.nvim"),
  cvv("esqueleto.nvim"),

  -- Syntax (syntax.lua)
  gh("nvim-treesitter/nvim-treesitter"),
  gh("kaarmu/typst.vim"),

  -- Tooling (tooling.lua)
  gh("folke/lazydev.nvim"),
  gh("danymat/neogen"),
  gh("williamboman/mason.nvim"),
  gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
  gh("mfussenegger/nvim-lint"),
  gh("stevearc/conform.nvim"),

  -- mini (mini.lua)
  gh("echasnovski/mini.nvim"),

  -- LLM (llm.lua)
  gh("github/copilot.vim"),
  gh("olimorris/codecompanion.nvim"),
})

-- Configure packages
local plugin_dir = vim.fn.stdpath("config") .. "/lua/pkg"
for _, file in ipairs(vim.fn.readdir(plugin_dir)) do
  if file:match("%.lua$") and file ~= "init.lua" then
    local ok, _ = pcall(require, "pkg." .. file:gsub("%.lua$", ""))
    if not ok then error("Error loading plugin config: " .. file) end
  end
end

vim.api.nvim_buf_create_user_command(
  0,
  "PackUpdate",
  "lua vim.pack.update()",
  { desc = "Update packages" }
)
