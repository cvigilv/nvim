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
  gh("juniorsundar/refer.nvim"),
  gh("nvim-lua/plenary.nvim"),

  -- UI (ui.lua)
  gh("Aasim-A/scrollEOF.nvim"),
  gh("stevearc/quicker.nvim"),
  gh("folke/which-key.nvim"),
  gh("hernancerm/bareline.nvim"),
  gh("zenbones-theme/zenbones.nvim"),

  -- PKM (pkm.lua)
  -- gh("nvim-orgmode/telescope-orgmode.nvim"),
  -- cvv("telescope-zotero.nvim"),
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
  gh("saghen/blink.lib"),
  gh("saghen/blink.cmp"),

  -- mini (mini.lua)
  -- gh("echasnovski/mini.nvim"),

  -- LLM (llm.lua)
  gh("github/copilot.vim"),
  gh("olimorris/codecompanion.nvim"),
})

-- Add commands for vim.pack
vim.api.nvim_create_user_command("Pack", function(opts)
  -- Core
  local cmd = opts.fargs
  if #cmd == 0 then
    error("[pack] No operation specified")
  elseif cmd[1] == "add" then
    vim.pack.add(require("lib.tables").tbl_slice(cmd, 2))
  elseif cmd[1] == "delete" then
    vim.pack.del(require("lib.tables").tbl_slice(cmd, 2))
  elseif cmd[1] == "update" then
    vim.pack.update()
  elseif cmd[1] == "sync" then
    vim.pack.update(nil, { target = "lockfile" })
  elseif cmd[1] == "clean" then
    local toclean = vim
      .iter(vim.pack.get())
      :filter(function(x) return not x.active end)
      :map(function(x) return x.spec.name end)
      :totable()
    if #toclean == 0 then
      print("No packages to clean")
    else
      print("Cleaning packages: " .. table.concat(toclean, ", "))
      vim.pack.del(toclean)
    end
  else
    error("[pack] Unsupported operation " .. opts.fargs[1])
  end
end, {
  desc = "Pack user commands",
  nargs = "*",
  complete = function()
    -- Builtin
    local subcommands = {
      "add",
      "update",
      "delete",
      "clean",
      "sync",
    }
    return subcommands
  end,
})

-- Configure packages
local plugin_dir = vim.fn.stdpath("config") .. "/lua/pkg"
for _, file in ipairs(vim.fn.readdir(plugin_dir)) do
  if file:match("%.lua$") and file ~= "init.lua" then
    local ok, _ = pcall(require, "pkg." .. file:gsub("%.lua$", ""))
    if not ok then error("[pack] Error loading plugin config: " .. file) end
  end
end
