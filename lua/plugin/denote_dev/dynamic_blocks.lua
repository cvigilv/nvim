---@module "plugin.denote.dynamic_blocks"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local M = {}

local function find_and_filter(path, patterns)
  local files = vim.fn.glob(path .. "/*", false, true)
  local matches = {}

  for _, filepath in ipairs(files) do
    local filename = vim.fn.fnamemodify(filepath, ":t")
    local filename_lower = string.lower(filename)

    local has_all_patterns = true
    for _, pattern in ipairs(patterns) do
      if not string.find(filename_lower, string.lower(pattern), 1, true) then
        has_all_patterns = false
        break
      end
    end

    if has_all_patterns then
      table.insert(matches, filepath)
    end
  end

  return matches
end

local function populate_links_block(bufnr, linerange, params)
  local links =
    find_and_filter("/Users/carlos/org", vim.split(params.regexp, "*", { trimempty = false }))

  local formatted_links = {}
  for _, l in ipairs(links) do
    l = vim.fs.basename(l)
    table.insert(formatted_links, "- [[file:" .. l .. "][" .. l:sub(1, 15) .. "]]")
  end
  vim.api.nvim_buf_set_lines(bufnr, linerange.startl+1, linerange.startl+1, false, formatted_links)
  return nil
end

local function populate_files_block(bufnr, linerange, params)
  print("Not implemented...")
  return nil
end

local function populate_backlinks_block(bufnr, linerange, params)
  print("Not implemented...")
  return nil
end

function M.update_dynamic_blocks(bufnr)
  print("Refreshing dynamic blocks")
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local query_string = [[
  (dynamic_block
    name: (expr) @name
    parameter: (expr) @parameter?
    (#match? @name "^denote")) @block
  ]]
  local query = vim.treesitter.query.parse("org", query_string)
  local parser = vim.treesitter.get_parser(bufnr, "org")
  local tree = parser:parse()[1]
  local root = tree:root()

  local blocks = {}
  local linerange = nil

  for id, node, _ in query:iter_captures(root, bufnr) do
    local capture_name = query.captures[id]
    local text = vim.treesitter.get_node_text(node, bufnr)

    if capture_name == "block"then
      local begin_line, _ = node:start()
      local end_line, _ = node:end_()
      linerange = { startl = begin_line, endl = end_line }
      -- Processes dynamic block
      if not vim.tbl_contains(blocks, begin_line .. ":" .. end_line) then
        -- Get parameters
        local block = {}
        local tokens = vim.split(vim.split(text, "\n")[1], " ")
        table.remove(tokens, 1)

        local current_param = nil
        for _, value in ipairs(tokens) do
          if value:sub(1, 1) == ":" then
            current_param = value:sub(2, -1)
          elseif current_param then
            block[current_param] = value
          else
            block["type"] = value
          end
        end

        -- Clear dynamic block
        vim.api.nvim_buf_set_lines(bufnr, begin_line+1, end_line-1, true, {})

        -- Populate dynamic block
        if block.type == "denote-links" then
          populate_links_block(bufnr, linerange, block)
        elseif block.type == "denote-files" then
          populate_files_block(bufnr, linerange, block)
        elseif block.type == "denote-backlinks" then
          populate_backlinks_block(bufnr, linerange, block)
        end

        table.insert(blocks, begin_line .. ":" .. end_line)
      end
    end
  end
end

return M
