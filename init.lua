-- Setup leader key
vim.g.mapleader = ","

-- Setup personal global table
_G.carlos = {}

-- Bootstrap lazy.nvim and nfnl.nvim
local pack_path = vim.fn.stdpath("data") .. "/site/pack"

local function ensure (user, repo)
  -- Ensures a given github.com/USER/REPO is cloned in the pack/packer/start directory.
  local install_path = string.format("%s/packer/start/%s", pack_path, repo, repo)
  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.api.nvim_command(string.format("!git clone https://github.com/%s/%s %s", user, repo, install_path))
    vim.api.nvim_command(string.format("packadd %s", repo))
  end
end
ensure("Olical", "nfnl")
ensure("folke", "lazy.nvim")

-- Load packages
require("lazy").setup("spec", {
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
