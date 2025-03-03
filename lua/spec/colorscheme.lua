---@module "carlos.pkgs.colorscheme"
---@author Carlos Vigil-Vásquez
---@license MIT 2024

return {
  { "cocopon/iceberg.vim" },
  -- {
  --   "f-person/auto-dark-mode.nvim",
  --   opts = {
  --     set_dark_mode = function()
  --       vim.api.nvim_set_option_value("background", "dark", {})
  --       -- vim.cmd("silent !tmux source $HOME/.config/tmux/tmux_dark.conf")
  --       vim.cmd.colorscheme(vim.g.color_name or "iceberg")
  --     end,
  --     set_light_mode = function()
  --       vim.api.nvim_set_option_value("background", "light", {})
  --       -- vim.cmd("silent !tmux source $HOME/.config/tmux/tmux_dark.conf")
  --       vim.cmd.colorscheme(vim.g.color_name or "iceberg")
  --     end,
  --     update_interval = 1,
  --     fallback = "light",
  --   },
  -- },
}
