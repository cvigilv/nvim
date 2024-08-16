-- NOTE: Adapted from https://www.reddit.com/r/neovim/comments/16sqyjz/finally_we_can_have_highlighted_folds/
_G.foldtext = function() --{{{
  local fold_start = vim.v.foldstart
  local fold_end = vim.v.foldend
  local line = vim.api.nvim_buf_get_lines(0, fold_start - 1, fold_start, false)[1]

  -- Prepare Treesitter parsing
  local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
  local parser = vim.treesitter.get_parser(0, lang)
  local query = vim.treesitter.query.get(parser:lang(), "highlights")

  -- Early return if no treesitter parser available
  if query == nil then return vim.fn.foldtext() end

  -- Parse line with treesitter
  local tree = parser:parse({ fold_start - 1, fold_start })[1]
  local result = {}

  local line_pos = 0
  local prev_range = nil

  for id, node, _ in query:iter_captures(tree:root(), 0, fold_start - 1, fold_start) do
    local name = query.captures[id]
    local start_row, start_col, end_row, end_col = node:range()
    if start_row == fold_start - 1 and end_row == fold_start - 1 then
      local range = { start_col, end_col }
      if start_col > line_pos then
        table.insert(result, { line:sub(line_pos + 1, start_col), "Folded" })
      end
      line_pos = end_col
      local text = vim.treesitter.get_node_text(node, 0)
      if prev_range ~= nil and range[1] == prev_range[1] and range[2] == prev_range[2] then
        result[#result] = { text, "@" .. name }
      else
        table.insert(result, { text, "@" .. name })
      end
      prev_range = range
    end
  end

  -- Add fold information
  -- TODO: Add diagnostics symbols if fold contains line with status
  local fold_info = string.format(" 󰁂 %d lines ", fold_end - fold_start + 1)

  table.insert(result, { " ", "Normal" })
  table.insert(result, { fold_info, "TabLine" })

  return result
end -- }}}

vim.opt.foldtext = "v:lua.foldtext()"
