---@module "spec.git"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

return {
  { -- fugitive
    "tpope/vim-fugitive"
  },
  { -- gitsigns
    "lewis6991/gitsigns.nvim",
    opts = {
        signcolumn = false,
        numhl = true,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
          interval = 1000,
          follow_files = true,
        },
        attach_to_untracked = false,
        current_line_blame = false,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "right_align",
          delay = 10,
          ignore_whitespace = true,
        },
        current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil,
        max_file_length = 40000,
        preview_config = {
          border = "single",
          style = "minimal",
          relative = "cursor",
          row = 0,
          col = 1,
        },
    },
  }, -- }}}
}
