---@module 'carlos.helpers.statusline.components'
---@author Carlos Vigil-Vásquez
---@license MIT

M = {}

--- Get current vim mode
---@return string
M.mode = function()
  local mode_lut = { --{{{
    ["n"] = "NORMAL",
    ["no"] = "O-PENDING",
    ["nov"] = "O-PENDING",
    ["noV"] = "O-PENDING",
    ["no\22"] = "O-PENDING",
    ["niI"] = "NORMAL",
    ["niR"] = "NORMAL",
    ["niV"] = "NORMAL",
    ["nt"] = "NORMAL",
    ["ntT"] = "NORMAL",
    ["v"] = "VISUAL",
    ["vs"] = "VISUAL",
    ["V"] = "V-LINE",
    ["Vs"] = "V-LINE",
    ["\22"] = "V-BLOCK",
    ["\22s"] = "V-BLOCK",
    ["s"] = "SELECT",
    ["S"] = "S-LINE",
    ["\19"] = "S-BLOCK",
    ["i"] = "INSERT",
    ["ic"] = "INSERT",
    ["ix"] = "INSERT",
    ["R"] = "REPLACE",
    ["Rc"] = "REPLACE",
    ["Rx"] = "REPLACE",
    ["Rv"] = "V-REPLACE",
    ["Rvc"] = "V-REPLACE",
    ["Rvx"] = "V-REPLACE",
    ["c"] = "COMMAND",
    ["cv"] = "EX",
    ["ce"] = "EX",
    ["r"] = "REPLACE",
    ["rm"] = "MORE",
    ["r?"] = "CONFIRM",
    ["!"] = "SHELL",
    ["t"] = "TERMINAL",
  } --}}}
  local mode_code = vim.api.nvim_get_mode().mode
  if mode_lut[mode_code] == nil then return mode_code end

  return mode_lut[mode_code]
end

--- Get current path of oil buffer
---@return string
M.oil = function()
  return vim.fn.expand("%:h:h"):gsub("oil://", "")
    .. "/"
    .. "%#Bold#"
    .. vim.fn.expand("%:h:t"):gsub("oil://", "")
    .. "%#*#"
end

--- Get filepath relative to Git repo / CWD
---@return string
M.filepath = function()
  -- Get relevant paths
  local cwd = ""
  if vim.b.gitsigns_status_dict ~= nil then
    cwd = vim.b.gitsigns_status_dict["root"]
  else
    cwd = os.getenv("HOME") or ""
  end
  local path = vim.fn.expand("%:p:h"):gsub(cwd, "") .. "/"

  local contents = path

  return contents
end

--- Get current buffer filename
---@return string|nil
M.filename = function()
  -- Get relevant paths
  local filename = vim.fn.expand("%:t")

  local contents = ""
  contents = contents .. "%#Bold#" .. filename .. "%#*#"

  return filename
end

--- Get current git branch of buffer
---@return string|nil
M.gitbranch = function()
  if vim.b.gitsigns_status_dict ~= nil then
    return "󰊢 " .. vim.b.gitsigns_head
  else
    return nil
  end
end

--- Get current git status of buffer
---@return string|nil
M.gitstatus = function()
  if vim.b.gitsigns_status_dict ~= nil then
    -- Add status
    -- NOTE: Left the highlight groups in case I want to use them in a future
    local stylesheet = {
      ["added"] = { hl = "DiffAdd", symbol = "+" },
      ["changed"] = { hl = "DiffChange", symbol = "~" },
      ["removed"] = { hl = "DiffDelete", symbol = "-" },
      ["untracked"] = { hl = "DiagnosticWarn", symbol = "!" },
    }

    local status = {}
    if vim.b.gitsigns_status_dict["added"] ~= nil then
      for _, name in ipairs({ "added", "changed", "removed" }) do
        -- if vim.b.gitsigns_status_dict[name] > 0 then
        table.insert(status, stylesheet[name]["symbol"] .. vim.b.gitsigns_status_dict[name])
        -- end
      end
    else
      local name = "untracked"
      table.insert(status, "untracked" .. stylesheet[name]["symbol"])
    end

    local contents = table.concat(status, " ")
    if contents ~= "" then
      return table.concat(status, " ")
    else
      return nil
    end
  else
    return nil
  end
end

--- Get attached LSP name of current buffer
--- TODO: Remove deprecated code
---@return string
M.lsp = function()
  local msg = "󰌘 "
  ---@diagnostic disable-next-line: deprecated
  local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
  ---@diagnostic disable-next-line: deprecated
  local clients = vim.lsp.get_clients()

  -- Return non-"null-ls" servers
  local buf_clients = {}
  for _, client in ipairs(clients) do
    ---@diagnostic disable-next-line: undefined-field
    local filetypes = client.config.filetypes
    if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
      buf_clients[#buf_clients + 1] = client.name:gsub("_", "-")
    end
  end

  -- Return complete list of formatters
  if vim.tbl_count(buf_clients) > 0 then
    return msg .. vim.fn.join(buf_clients, ",")
  else
    return msg .. "No LSP"
  end
end

M.env = function()
  local function getMutualPath(path1, path2)
    -- Split paths into components
    local function splitPath(path)
      local components = {}
      for component in path:gmatch("[^/\\]+") do
        table.insert(components, component)
      end
      return components
    end

    local components1 = splitPath(path1)
    local components2 = splitPath(path2)

    -- Find common components
    local commonComponents = {}
    local minLength = math.min(#components1, #components2)

    for i = 1, minLength do
      if components1[i] == components2[i] then
        table.insert(commonComponents, components1[i])
      else
        break
      end
    end

    -- Reconstruct mutual path
    return table.concat(commonComponents, "/")
  end

  local function get_relative_path(from_path, to_path)
    -- Normalize paths (replace backslashes with forward slashes)
    from_path = from_path:gsub("\\", "/")
    to_path = to_path:gsub("\\", "/")

    -- Split paths into segments
    local from_segments = {}
    for segment in from_path:gmatch("[^/]+") do
      table.insert(from_segments, segment)
    end

    local to_segments = {}
    for segment in to_path:gmatch("[^/]+") do
      table.insert(to_segments, segment)
    end

    -- Find common prefix
    local common_length = 0
    for i = 1, math.min(#from_segments, #to_segments) do
      if from_segments[i] ~= to_segments[i] then break end
      common_length = i
    end

    -- Build relative path
    local relative_path = {}
    for i = common_length + 1, #from_segments do
      table.insert(relative_path, "..")
    end
    for i = common_length + 1, #to_segments do
      table.insert(relative_path, to_segments[i])
    end

    -- Join segments
    return table.concat(relative_path, "/")
  end

  local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
  if buf_ft == "python" then
    local parent_dir = vim.fn.getcwd()
    local exe_path = vim.fn.exepath("python3")

    -- return getMutualPath(parent_dir, exe_path)
    return "(" .. get_relative_path(parent_dir, exe_path) .. ")"
  end
end

--- Get diagnostics status of current buffer
---@return string
M.diagnostics = function()
  local contents = ""

  local severity = { ERROR = 0, WARN = 0, INFO = 0, HINT = 0 }
  local icons = { ERROR = "E", WARN = "W", INFO = "I", HINT = "H" }
  for level, _ in pairs(severity) do
    severity[level] =
      vim.tbl_count(vim.diagnostic.get(0, { severity = vim.diagnostic.severity[level] }))
    contents = contents .. icons[level] .. severity[level] .. " "
  end

  return contents
end

--- Generates a small Harpoon cheat for easier navigation
---@return string|nil
M.harpoon_cheat = function()
  if vim.bo.buftype ~= "" then return end -- not a normal buffer, no harpoon status

  local ok, harpoon = pcall(require, "harpoon")
  if not ok then return end -- no harpoon, no harpoon status

  local list = harpoon:list()
  local contents = "[󰛢 "

  if #list.items == 0 then return nil end -- no items in the list, no harpoon status

  local current_file = vim.fn.expand("%:p:.")
  local harpoon_keys = { "h", "j", "k", "l" }
  if #list.items < 5 then
    for idx, item in ipairs(list.items) do
      if item.value == current_file then
        contents = contents .. "%#Bold#" .. harpoon_keys[idx] .. "%#*#"
      else
        contents = contents .. harpoon_keys[idx]
      end
    end
  else
    for idx = 1, 4, 1 do
      local item = list.items[idx]
      if item.value == current_file then
        contents = contents .. "%#Bold#" .. harpoon_keys[idx] .. "%#*#"
      else
        contents = contents .. harpoon_keys[idx]
      end
    end
    contents = contents .. "+"
  end

  return contents .. "]"
end

--- Get file icon of current buffer
---@return string
M.fileicon = function()
  local filename = vim.fn.expand("%:t")
  local extension = vim.fn.expand("%:e")
  local icon, _ = require("nvim-web-devicons").get_icon(filename, extension)
  if icon ~= nil then
    return icon .. " "
  else
    return ""
  end
end

--- Return vim status of current buffer
---@return string Buffer status
M.filestatus = function() return "%m%r%w%h%q" end

--- Get position of cursor in current buffer
---@return string Cursor location
M.location = function()
  local position = vim.api.nvim_win_get_cursor(0)
  local row = position[1]
  local col = position[2]

  return "L" .. row .. ":C" .. col
end

--- Retrieves the current recording macro register.
-- If no macro is being recorded, returns an empty string.
-- If a macro is being recorded, returns the register with a symbol prefix.
-- @return string The current recording macro register with a symbol prefix, or an empty string if no macro is being recorded.
M.recording_macro = function()
  local recording_register = vim.fn.reg_recording()
  if recording_register == "" then
    return nil
  else
    return "󰑋 '" .. recording_register .. "'"
  end
end

return M
