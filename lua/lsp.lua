---@module "lsp"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

-- Refer to https://github.com/neovim/nvim-lspconfig/blob/c8b90ae5cbe21d547b342b05c9266dcb8ca0de8f/plugin/lspconfig.lua#L157-L184
-- Lsp <- Entry point
-- Lsp                        -> LspInfo (https://github.com/neovim/nvim-lspconfig/blob/c8b90ae5cbe21d547b342b05c9266dcb8ca0de8f/plugin/lspconfig.lua#L68)
-- Lsp info                   -> LspInfo (https://github.com/neovim/nvim-lspconfig/blob/c8b90ae5cbe21d547b342b05c9266dcb8ca0de8f/plugin/lspconfig.lua#L68)
-- Lsp start <name>           -> LspStart <name> (https://github.com/neovim/nvim-lspconfig/blob/c8b90ae5cbe21d547b342b05c9266dcb8ca0de8f/plugin/lspconfig.lua#L99-L120)
-- Lsp stop <name>            -> LspStop <name> (https://github.com/neovim/nvim-lspconfig/blob/c8b90ae5cbe21d547b342b05c9266dcb8ca0de8f/plugin/lspconfig.lua#L157-L184)
-- Lsp restart <name>         -> LspRestart <name> (https://github.com/neovim/nvim-lspconfig/blob/c8b90ae5cbe21d547b342b05c9266dcb8ca0de8f/plugin/lspconfig.lua#L122-L155)
-- Lsp restart                -> Restart all LSP servers running on buffer
-- Lsp toggle <name>          -> Start or stop LSP server
-- Lsp log                    -> Open LSP logs (https://github.com/neovim/nvim-lspconfig/blob/c8b90ae5cbe21d547b342b05c9266dcb8ca0de8f/plugin/lspconfig.lua#L70-L74)

local function lsp_info()
  vim.cmd("checkhealth lsp")
  vim.keymap.set("n", "q", function() vim.api.nvim_win_close(0, true) end, { buffer = true })
  vim.notify("[lsp] Press 'q' to quit.", vim.log.levels.INFO)
end

local function lsp_start(name)
  -- Attempt to start server from available configs
  local ok, _ = pcall(vim.lsp.start, vim.lsp.config[name])
  if ok then
    vim.notify("[lsp] LSP server '" .. name .. "' started.", vim.log.levels.INFO)
  else
    vim.notify("[lsp] Failed to start LSP server '" .. name .. "'.", vim.log.levels.ERROR)
  end
end

local function lsp_stop(name)
  local force = true
  local clients = {}

  -- Default to stopping all servers on current buffer
  local allclients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
  if name == nil then
    clients = allclients
    vim.notify("[lsp] No server name provided, stopping all LSP servers", vim.log.levels.WARN)
  else
    clients = vim.tbl_filter(function(c) return name == c.name end, allclients)
  end

  -- Stop servers
  for _, c in ipairs(clients) do
    ---@diagnostic disable-next-line: param-type-mismatch
    c.stop(force)
    vim.notify("[lsp] Stopped '" .. c.name .. "'", vim.log.levels.INFO)
  end
end

local function lsp_restart(name)
  local clients = {}

  -- Default to restarting all active servers
  if name == nil then
    clients = vim
      .iter(vim.lsp.get_clients())
      :map(function(client) return client.name end)
      :totable()
    vim.notify("[lsp] No server name provided, restarting all LSP servers", vim.log.levels.WARN)
  else
    clients = { name }
  end

  --
  for _, name in ipairs(clients) do
    if vim.lsp.config[name] == nil then
      vim.notify(("[lsp] Invalid server name '%s'"):format(name))
    else
      vim.lsp.enable(name, false)
    end
  end

  local timer = assert(vim.uv.new_timer())
  timer:start(500, 0, function()
    for _, name in ipairs(clients) do
      vim.schedule_wrap(function(x)
        vim.lsp.enable(x)
        vim.notify(("[lsp] Restarted server '%s'"):format(name))
      end)(name)
    end
  end)
end

local function lsp_toggle(name)
  local running = false
  for _, client in ipairs(vim.lsp.get_clients()) do
    if client.name == name then
      running = true
      lsp_stop(name)
      return
    end
  end
  if not running then lsp_start(name) end
end

local function lsp_log()
  local log_path = vim.lsp.get_log_path()
  vim.cmd.tabnew(log_path)
  vim.cmd.normal("G")
  vim.keymap.set("n", "q", function() vim.api.nvim_win_close(0, true) end, { buffer = true })
  vim.notify("[lsp] Press 'q' to quit.", vim.log.levels.INFO)
end

-- TODO: maybe make this function accept a table of subcommands and functions to push them into the subcommands
local function lsp_cmd(opts)
  local args = vim.split(opts.args, " ")
  local subcmd = args[1]
  local name = args[2]

  if subcmd == "" or subcmd == "info" then
    lsp_info()
  elseif subcmd == "start" and name then
    lsp_start(name)
  elseif subcmd == "stop" then
    lsp_stop(name)
  elseif subcmd == "restart" then
    lsp_restart(name)
  elseif subcmd == "toggle" and name then
    lsp_toggle(name)
  elseif subcmd == "log" then
    lsp_log()
  else
    vim.notify("[lsp] Unknown Lsp subcommand: " .. tostring(subcmd), vim.log.levels.ERROR)
  end
end

vim.api.nvim_create_user_command("Lsp", lsp_cmd, {
  nargs = "*",
  complete = function(_, line)
    local subcommands = { "info", "start", "stop", "restart", "toggle", "log" }
    local split = vim.split(line, " ")
    if #split == 2 then
      return subcommands
    elseif #split == 3 then
      -- Scan lsp/ dir to see what configs are available
      local lsp_folder = vim.fs.joinpath(vim.fn.stdpath("config"), "lsp")
      local scandir = vim.uv.fs_scandir(lsp_folder)
      local lsps = {}
      while true do
        local name, t = vim.uv.fs_scandir_next(scandir)
        if not name then break end
        table.insert(lsps, vim.fn.fnamemodify(name, ":t:r"))
      end
      return lsps
    end
    return {}
  end,
})
