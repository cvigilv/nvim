---@module "plugin.zk.cmp"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local U = require("plugin.zk.utils")

local function read_lines(file, start_row, end_row, res)
  local linenum = 1
  for line in io.lines(file) do
    if linenum >= start_row and linenum <= end_row then table.insert(res, line) end
    linenum = linenum + 1
    if linenum > end_row then break end
  end
end

local function _note_docs(item, opts)
  if item.context.path then
    local links = U.get_links(item.context.path, opts)
    local res = {
      "*"
        .. item.context.title
        .. "*"
        .. "\t"
        .. "# links: to="
        .. #links.to
        .. " / from="
        .. #links.from,
      "---",
    }
    read_lines(item.context.path, 1, 16, res)
    return res
  else
    return vim.api.nvim_buf_get_lines(0, 1, 16, false)
  end
end

local M = {}

M.setup = function(opts)
  -- CMP source "zk"
  local source = {}

  function source:is_available()
    -- Get the full path of the current buffer
    local current_buf = vim.api.nvim_get_current_buf()
    local buf_name = vim.api.nvim_buf_get_name(current_buf)

    -- Extract the directory path
    local dir_path = vim.fn.fnamemodify(buf_name, ":h")

    -- Normalize paths (convert to absolute paths)
    local normalized_dir_path = vim.fn.fnamemodify(dir_path, ":p")
    local normalized_folder = vim.fs.abspath(opts.path)

    -- Compare the paths
    return normalized_dir_path == normalized_folder
  end

  function source:resolve(item, callback)
    if item.type then
      local lines
      if item.type == "Note" then lines = _note_docs(item, opts) end
      if lines and #lines > 0 then
        item.documentation = {
          kind = "markdown",
          value = vim.fn.join(lines, "\n") .. "\n",
        }
      end
    end
    callback(item)
  end
  function source:complete(params, callback)
    local allmetadata = U.get_all_metadatas(opts)
    local items = {}
    local cursor_before_line = params.context.cursor_before_line

    -- Expand image links, e.g. `![txt](path)`
    if string.match(cursor_before_line, "!%[%]%([^%)]*$") then
      print("expanding image link")
      local current_buf = vim.api.nvim_get_current_buf()
      local buf_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(current_buf), ":p")
      local note_name = string.sub(vim.fs.basename(buf_name), 0, -4)
      local media_path = opts.media .. "/" .. note_name .. "/"
      local media_files = vim.split(vim.fn.glob(media_path .. "*"), "\n", { trimempty = true })
      if #media_files > 0 then
        for _, entry in ipairs(media_files) do
          table.insert(items, {
            type = "Media",
            kind = "Media",
            label = entry,
            insertText = entry,
            filterText = entry,
            context = { path = entry },
          })
        end
      else
        print("No media files found")
      end
    end

    -- Expand inline links, e.g. `[txt](path)`
    if string.match(cursor_before_line, "%]%([^%)]*$") then
      for _, entry in pairs(allmetadata) do
        table.insert(items, {
          type = "Note",
          label = entry.title,
          insertText = vim.fs.basename(entry.path),
          filterText = vim.fn.join(
            { entry.title, entry.type, table.concat(entry.tags, ";") },
            "|"
          ),
          context = entry,
        })
      end
    end

    callback(items)
  end

  function source:execute(completion_item, callback) callback(completion_item) end

  function source:get_debug_name() return "zk" end

  function source:get_trigger_characters() return { "[", "(" } end

  require("cmp").register_source("zk", source)
end

return M
