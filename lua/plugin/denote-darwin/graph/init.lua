---@module "plugin.denote-darwin.graph"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local M = {}

local Frontmatter = require("denote.frontmatter")
local Naming = require("denote.naming")

local function keyed_table_to_csv(tbl, header)
  -- Get header keys from the first row
  if header == nil then
    header = {}
    for k in pairs(tbl[1]) do
      table.insert(header, k)
    end
  end
  vim.print(header)

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

local dir = "~/org"
local notes = vim.fn.glob(dir .. "/*", true, true, true)

-- 1. Get data entries
local data = vim
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
    return data
  end)
  :totable()

local valid_identifiers = vim.iter(data):map(function(e) return e.identifier end):totable()
vim.print(#valid_identifiers)

-- 2. Get links
local cache_links = function()
  local dir = vim.g.denote.directory --[[@as string]]
  local uv = vim.loop
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
      local count = #vim.tbl_keys(_G.denote_cache_links or {})
      require("denote.core.logger").info(
        "Populated Denote links cache with " .. count .. " links"
      )
    end)
  end)
end
cache_links()

local edges = (
  vim.iter(_G.denote_cache_links):fold({}, function(acc, k, v)
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
)


local links_csv = keyed_table_to_csv(edges, { "id", "source", "target" })
local nodes_csv = keyed_table_to_csv(data, { "identifier", "title", "keywords", "signature" })

local file = io.open("/Users/carlos/org/.org/cosma/links.csv", "w+") -- Open file for writing
if file then
  file:write(links_csv)
  file:close()
else
  print("Failed to open file for writing")
end
file = io.open("/Users/carlos/org/.org/cosma/nodes.csv", "w+") -- Open file for writing
if file then
  file:write(nodes_csv)
  file:close()
else
  print("Failed to open file for writing")
end

return M
