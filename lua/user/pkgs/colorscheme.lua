---@module "user.pkgs.colorscheme"
---@author Carlos Vigil-Vásquez
---@license MIT 2024

return {

  { "cocopon/iceberg.vim" },
  {
    "kyazdani42/blue-moon",
    config = function()
      vim.opt.termguicolors = true
      vim.cmd("colorscheme blue-moon")
    end,
  },
}
