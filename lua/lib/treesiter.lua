---@module "lib.treesiter"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local M = {}

---Checks if the given lines contain a specific capture in a tree-sitter query.
---@param lines string[] A table of strings representing the lines of code to check
---@param capture_name string The name of the capture to search for
---@param query_string string The tree-sitter query string to use
---@param lang string The language to use for parsing
---@return boolean|nil found Returns true if the capture is found, false if not found,
---or nil if any required argument is missing
M.lines_contains_capture = function(lines, capture_name, query_string, lang)
  -- If any argument is not provided, early exit
  if not lines or not capture_name or not query_string or not lang then
    error("Must provide all arguments.")
    return
  end

  -- Parse the query
  local query = vim.treesitter.query.parse(lang, query_string)

  -- Create a temporary buffer and set its content
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  -- Get the syntax tree for the entire buffer
  local parser = vim.treesitter.get_parser(bufnr, lang)
  local tree = parser:parse()[1]
  local root = tree:root()

  -- Iterate over all captures
  for id, _, _ in query:iter_captures(root, 0, 0, -1) do
    -- Get the name of the capture
    local current_capture_name = query.captures[id]
    if current_capture_name == capture_name then
      vim.api.nvim_buf_delete(bufnr, { force = true })
      return true
    end
  end

  -- If we've gone through all captures and haven't returned true, return false
  vim.api.nvim_buf_delete(bufnr, { force = true })
  return false
end

---Retrieves the contents of a specified capture from a tree-sitter query on given lines of text.
---@param lines string[] A table of strings representing the lines of text to query
---@param capture_name string The name of the capture to retrieve
---@param query_string string The tree-sitter query string
---@param lang string The language of the text (e.g., "lua", "python")
---@return string[]|nil captures A flattened table of strings containing the captured text, or nil if no captures were found
M.get_capture_contents = function(lines, capture_name, query_string, lang)
  -- If any argument is not provided, early exit
  if not lines or not capture_name or not query_string or not lang then
    error("Must provide all arguments.")
    return
  end

  -- Parse the query
  local query = vim.treesitter.query.parse(lang, query_string)

  -- Create a temporary buffer and set its content
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("filetype", "markdown", { buf = bufnr })
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  -- Get the syntax tree for the entire buffer
  local parser = vim.treesitter.get_parser(bufnr, lang)
  local tree = parser:parse()[1]
  local root = tree:root()

  -- Iterate over all captures
  local mdblock = {}
  for id, node, _ in query:iter_captures(root, 0, 0, -1) do
    -- Get the name of the capture
    local current_capture_name = query.captures[id]
    if current_capture_name == capture_name then
      -- Get the text of the captured node
      local start_row, start_col, end_row, end_col = node:range()
      local text = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})
      table.insert(mdblock, vim.iter(text):flatten():totable())
    end
  end

  if #mdblock > 0 then return vim.iter(mdblock):flatten(math.huge):totable() end
end

return M
