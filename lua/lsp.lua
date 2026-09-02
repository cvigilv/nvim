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

  for _, n in ipairs(clients) do
    if vim.lsp.config[n] == nil then
      vim.notify(("[lsp] Invalid server name '%s'"):format(n))
    else
      vim.lsp.enable(n, false)
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
  local log_path = vim.lsp.log.get_filename()
  vim.cmd.tabnew(log_path)
  vim.cmd.normal("G")
  vim.keymap.set("n", "q", function() vim.api.nvim_win_close(0, true) end, { buffer = true })
  vim.notify("[lsp] Press 'q' to quit.", vim.log.levels.INFO)
end

local subcommands = {
  info = lsp_info,
  log = lsp_log,
  restart = lsp_restart,
  start = lsp_start,
  stop = lsp_stop,
  toggle = lsp_toggle,
}

--- Subcommands taking an LSP server name as their second argument
local takes_server = { restart = true, start = true, stop = true, toggle = true }

--- Names of every `lsp/<name>.lua` config found on the runtimepath
---@return string[]
local function server_names()
  local names, seen = {}, {}
  for _, path in ipairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
    local name = vim.fn.fnamemodify(path, ":t:r")
    if not seen[name] then
      seen[name] = true
      names[#names + 1] = name
    end
  end
  table.sort(names)
  return names
end

local function lsp_cmd(opts)
  local subcmd = opts.fargs[1] or "info"
  local name = opts.fargs[2]

  local fn = subcommands[subcmd]
  if not fn then
    vim.notify("[lsp] Unknown Lsp subcommand: " .. subcmd, vim.log.levels.ERROR)
    return
  end
  if takes_server[subcmd] then
    fn(name)
  else
    fn()
  end
end

vim.api.nvim_create_user_command("Lsp", lsp_cmd, {
  nargs = "*",
  desc = "Inspect and control LSP servers",
  complete = function(arg_lead, cmdline, cursor_pos)
    -- Completion functions must filter on `arg_lead` themselves; Neovim returns
    -- the list verbatim.
    local args = vim.split(cmdline:sub(1, cursor_pos), "%s+", { trimempty = true })

    -- Drop the command name, and the partial argument being completed
    local completed = #args - 1 - (arg_lead == "" and 0 or 1)

    local candidates = {}
    if completed == 0 then
      candidates = vim.tbl_keys(subcommands)
      table.sort(candidates)
    elseif completed == 1 and takes_server[args[2]] then
      candidates = server_names()
    end

    return vim.tbl_filter(function(c) return vim.startswith(c, arg_lead) end, candidates)
  end,
})
