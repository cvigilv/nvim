return {
  cmd = { "fennel-ls" },
  filetypes = { "fennel" },
  root_markers = { ".git", "flsproject.fnl" },
  settings = {
    fennel = {
      diagnostics = { globals = { "vim", "jit", "comment" } },
      workspace = { library = vim.api.nvim_list_runtime_paths() },
    },
  },
}
