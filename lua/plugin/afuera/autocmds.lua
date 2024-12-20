---@module "plugin.afuera.autocmds"
---@author Carlos Vigil-Vásquez
---@license MIT 2024

local C = require("plugin.afuera.core")

local M = {}

M.setup = function(opts)
  vim.api.nvim_create_autocmd({ "BufWinEnter", "BufNew", "BufEnter", "BufReadPost" }, {
    group = vim.api.nvim_create_augroup("afuera", { clear = true }),
    callback = function()
      -- Get window and buffer numbers
      local bufnr = tostring(vim.api.nvim_get_current_buf())
      local winnr = vim.api.nvim_get_current_win()

      -- Set default state if buffer wasn't previously open
      if opts.state[bufnr] == nil then opts.state[bufnr] = opts.defaults.state end

      if
        vim.tbl_contains(
          opts.ignored_buftypes,
          vim.api.nvim_get_option_value("buftype", {}),
          {}
        )
      then
        vim.print("Buffer " .. bufnr .. " is ignored")
        opts.state[bufnr] = false
      end

      -- Set OOB mode
      C.set_oob_mode(bufnr, winnr, opts)
    end,
  })
end

return M
