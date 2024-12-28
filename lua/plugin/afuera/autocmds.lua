---@module "plugin.afuera.autocmds"
---@author Carlos Vigil-Vásquez
---@license MIT 2024

local C = require("plugin.afuera.core")
local log = require("plugin.afuera.log").new({}, true)

local M = {}

M.setup = function(opts)
  vim.api.nvim_create_autocmd({ "BufWinEnter", "BufNew", "BufEnter", "BufReadPost" }, {
    group = vim.api.nvim_create_augroup("afuera", { clear = true }),
    callback = function()
      -- Get window and buffer numbers
      local bufnr = tostring(vim.api.nvim_get_current_buf())
      local winnr = vim.api.nvim_get_current_win()

      -- Soft enforce highlight groups
      if opts.fix_colorscheme then
        vim.api.nvim_set_option_value("winhighlight", "EndOfBuffer:Normal", { win = winnr })
      end

      -- Set default state if buffer wasn't previously open
      if opts.state[bufnr] == nil then opts.state[bufnr] = opts.defaults.state end

      -- Check whether buffer/file type is ignored
      -- NOTE: if its ignored, force deactivate the OOB mode. Maybe in a future I can respect
      -- this in a more "intelligent" way.
      local buftype = vim.api.nvim_get_option_value("buftype", { buf = tonumber(bufnr) })
      local filetype = vim.api.nvim_get_option_value("filetype", { buf = tonumber(bufnr) })

      if vim.tbl_contains(opts.ignored_buftypes, buftype, {}) then
        log.info("Found buftype `" .. buftype .. "` inside `opts.ignored_buftypes`")
        log.info("Ignoring winid=" .. winnr .. "/bufid=" .. bufnr)
        opts.state[bufnr] = false
      end

      if vim.tbl_contains(opts.ignored_filetypes, filetype, {}) then
        log.info("Found filetype `" .. filetype .. "` inside `opts.ignored_filetypes`")
        log.info("Ignoring winid=" .. winnr .. "/bufid=" .. bufnr)
        opts.state[bufnr] = false
      end

      -- Set out-of-bounds mode
      C.set_oob_mode(bufnr, winnr, opts)
    end,
  })
end

return M
