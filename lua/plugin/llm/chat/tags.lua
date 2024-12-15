local M = {}

-- Lookup table for tag processing functions
local tag_processors = {

  buffer = function(current_buf)
    local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
    local content = table.concat(lines, "\n")
    local filetype = vim.bo[current_buf].filetype or "text"
    return string.format("```%s\n%s\n```", filetype, content)
  end,

  cwd_contents = function(current_buf)
    local contents = {}
    local cwd = vim.fn.getcwd()
    local files = vim.fn.globpath(cwd, "*", false, true, true)
    local current_file = vim.api.nvim_buf_get_name(current_buf)

    for _, file in ipairs(files) do
      if vim.fn.isdirectory(file) ~= 1 and file ~= current_file then
        local filename = vim.fn.fnamemodify(file, ":t")
        local filetype = vim.filetype.match({ filename = filename }) or "text"
        local file_contents = vim.fn.readfile(file)

        table.insert(
          contents,
          string.format(
            "File: %s\n\n```%s\n%s\n```\n",
            file,
            filetype,
            table.concat(file_contents, "\n")
          )
        )
      end
    end

    return table.concat(contents, "\n")
  end,
}

-- Function to process tags in the input
---Processes input by replacing tags with their corresponding content.
---@param input string The input string to process
---@param current_buf number The buffer number of the current buffer
---@return string The processed input with tags replaced
function M.process_tags(input, current_buf)
  local processed_input = input:gsub("#(%w+)", function(tag)
    local processor = tag_processors[tag]
    if processor then
      return processor(current_buf)
    else
      return "#" .. tag -- Return the original tag if no processor is found
    end
  end)

  return processed_input
end

return M
