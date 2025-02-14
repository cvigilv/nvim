local utils = require("plugin.zk.utils")

local get_tags = function()
  -- Get all tags
  local all_tags = vim
    .iter(vim.tbl_values(utils.get_all_tags({
      path = os.getenv("ZETTELDIR") --[[@as string]],
    })))
    :flatten()
    :flatten()
    :totable()

  -- Keep only unique tags
  local seen = {}
  local unique_tags = {}

  for _, value in ipairs(all_tags) do
    if type(value) == "string" and not seen[value] then
      seen[value] = true
      table.insert(unique_tags, value)
    end
  end

  -- Convert to cmp format
  local tags_to_items = {}
  for _, tag in ipairs(unique_tags) do
    table.insert(tags_to_items, { label = tag })
  end

  return tags_to_items
end

local tags = get_tags()

local source = {}

function source:is_available()
  -- Get the full path of the current buffer
  local current_buf = vim.api.nvim_get_current_buf()
  local buf_name = vim.api.nvim_buf_get_name(current_buf)

  -- Extract the directory path
  local dir_path = vim.fn.fnamemodify(buf_name, ":h")

  -- Normalize paths (convert to absolute paths)
  local normalized_dir_path = vim.fn.fnamemodify(dir_path, ":p")
  local normalized_folder = vim.fn.fnamemodify(vim.uv.fs_realpath(os.getenv("ZETTELDIR")), ":p")

  -- Compare the paths
  return normalized_dir_path == normalized_folder
end

function source:get_debug_name() return "zk" end
function source:get_trigger_characters() return { "#" } end
function source:resolve(completion_item, callback) callback(completion_item) end
function source:complete(params, callback)
  local items = {}
  local cursor_before_line = params.context.cursor_before_line

  if cursor_before_line:sub(1, 1) == "#" then items = tags end
  callback(items)
end
function source:execute(completion_item, callback) callback(completion_item) end

-- require("cmp").register_source("zk", source)
