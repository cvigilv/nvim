---@module "pkg"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
---@diagnostic disable-next-line: undefined-field
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Load packages
local specs = {}
local plugin_dir = vim.fn.stdpath("config") .. "/lua/pkg"
for _, file in ipairs(vim.fn.readdir(plugin_dir)) do
  if file:match("%.lua$") and file ~= "init.lua" then
    local spec = require("pkg." .. file:gsub("%.lua$", ""))
    table.insert(specs, spec)
  end
end

require("lazy").setup(specs, {
  ui = { pills = true },
  change_detection = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "netrwPlugin",
        "tarPlugin",
        "shada",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
