---@module "plugin.denote-darwin.graph"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local M = {}

--- Convert denote silo to cosma compliant nodes
---@return table nodes Cosma compliant table with nodes data
local function denote_to_nodes()
  local Naming = require("denote.naming")
  local Frontmatter = require("denote.frontmatter")

  local dir = vim.g.denote.directory
  local notes = vim.fn.glob(dir .. "/*", true, true, true)
  return vim
    .iter(notes)
    :map(function(f)
      local ft = vim.filetype.match({ filename = f })
      local data = vim.tbl_extend(
        "force",
        Naming.parse_filename(f) or {},
        Frontmatter.parse_frontmatter(f, ft) or {}
      )
      if data.keywords ~= nil and type(data.keywords) == "table" then
        data.keywords = table.concat(data.keywords, ",") or ""
      end

      -- Rename keys
      data.id = vim.deepcopy(data.identifier)
      ---@diagnostic disable-next-line: param-type-mismatch
      data["tags:keywords"] = vim.deepcopy(data.keywords)
      data["type:signature"] = vim.deepcopy(data.signature)
      data.identifier = nil
      data.keywords = nil
      data.signature = nil

      return data
    end)
    :totable()
end

--- Convert denote silo to cosma compliant links
---@return table links Cosma compliant table with link data
local function denote_to_links(nodes)
  local Naming = require("denote.naming")

  local valid_identifiers = vim.iter(nodes):map(function(e) return e.id end):totable()
  local dir = vim.g.denote.directory --[[@as string]]
  local uv = vim.uv
  uv.fs_scandir(dir, function(err, req)
    if err or not req then
      vim.schedule(
        function()
          require("denote.core.logger").info(
            "Failed to scan directory: " .. (err or "unknown error"),
            vim.log.levels.ERROR
          )
        end
      )
      return
    end

    local files = {}
    while true do
      local name, typ = uv.fs_scandir_next(req)
      if not name then break end
      if typ == "file" then
        local ext = name:match("%.([^.]+)$")
        if ext and vim.tbl_contains({ "txt", "md", "org", "norg" }, ext) then
          table.insert(files, dir .. name)
        end
      end
    end

    -- Process files on main thread (for Lua module safety)
    vim.schedule(function()
      for _, filepath in ipairs(files) do
        require("denote.links").get_links(filepath)
      end
    end)
  end)

  return vim.iter(_G.denote_cache_links):fold({}, function(acc, k, v)
    if #v > 0 then
      for _, l in ipairs(v) do
        local source = Naming.parse_filename(k).identifier
        local target = Naming.parse_filename(l.path).identifier
        if
          target ~= ""
          and vim.tbl_contains(valid_identifiers, source)
          and vim.tbl_contains(valid_identifiers, target)
        then
          table.insert(acc, {
            id = source .. "-" .. target,
            source = source,
            target = target,
          })
        end
      end
    end
    return acc
  end)
end

--- Convert a lua table with keys to a CSV string
---@param tbl table Table to convert
---@param header string[] Keys to add to CSV
---@return string csv CSV string of table
local function keyed_table_to_csv(tbl, header)
  -- Get header keys from the first row if missing
  if header == nil then
    header = {}
    for k in pairs(tbl[1]) do
      table.insert(header, k)
    end
  end

  -- Write header row
  local lines = {}
  table.insert(lines, table.concat(header, ","))

  -- Write data rows
  for _, row in ipairs(tbl) do
    local values = {}
    for _, key in ipairs(header) do
      local s = tostring(row[key] or "")
      if s:find("[,\"]") then s = "\"" .. s:gsub("\"", "\"\"") .. "\"" end
      table.insert(values, s)
    end
    table.insert(lines, table.concat(values, ","))
  end

  return table.concat(lines, "\n")
end

--- Open a graph view of the Denote silo using cosma
-- TODO: Automatically open in current node position if in denote.
--       e.g. file:///Users/carlos/Insync/itmightbecarlos@gmail.com/Google_Drive/org/.org/cosmoscope.html?focus=2#20251025t002556
-- TODO: See if it makes sense to save graph to neovim cache
-- TODO: Generate config file on the fly
function M.modelize_silo()
  -- Get current denote file
  local indenote = ""
  local filename = vim.api.nvim_buf_get_name(0)
  if string.find(filename, vim.uv.fs_realpath(vim.g.denote.directory), 1, true) ~= nil then
    print("Inside of note!")
    print(vim.fs.basename(filename):sub(1, 15))
    print("?focus=2#" .. vim.fs.basename(filename):sub(1, 15):lower())
    indenote = "?focus=2#" .. vim.fs.basename(filename):sub(1, 15):lower()
  end

  -- Get data
  local nodes = denote_to_nodes()
  local links = denote_to_links(nodes)

  -- Convert and save as CSV
  local links_csv = keyed_table_to_csv(links, { "id", "source", "target" })
  local nodes_csv =
    keyed_table_to_csv(nodes, { "id", "title", "tags:keywords", "type:signature" })

  local file = io.open("/Users/carlos/org/.org/cosma/links.csv", "w+") -- Open file for writing
  if file then
    file:write(links_csv)
    file:close()
  else
    error("Failed to open file for writing")
  end

  file = io.open("/Users/carlos/org/.org/cosma/nodes.csv", "w+") -- Open file for writing
  if file then
    file:write(nodes_csv)
    file:close()
  else
    error("Failed to open file for writing")
  end

  os.execute("cosma modelize -p pkm")
  os.execute("open \"file:///Users/carlos/org/.org/cosmoscope.html" .. indenote .. "\"")
end

return M
