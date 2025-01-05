---@module "user.helpers.files"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local M = {}

---Reads the content of a file and returns it as a string.
---@param file_path string Path to the file to be read
---@return string|nil contents File content as a string, or nil if file cannot be read
---@return string|nil message Error message if file cannot be read, or nil on success
M.safe_read = function(file_path)
  assert(type(file_path) == "string")

  local uv = vim.uv or vim.loop
  ---@diagnostic disable-next-line: undefined-field
  local handler, message = io.open(uv.fs_realpath(file_path), "r")
  if not handler then return nil, message end
  local contents = handler:read("*a"):gsub("\r\n?", "\n"):gsub("\n$", "")
  handler:close()
  return contents, nil
end

---Safely writes contents to a file.
---@param file_path string The path of the file to write
---@param contents table A table of strings to write to the file
---@param mode string The mode to open the file in (default: "w")
---@return boolean|nil success True if write was successful, nil otherwise
---@return string|nil error Error message if write failed, nil otherwise
M.safe_write = function(file_path, contents, mode)
  assert(type(file_path) == "string")
  assert(type(contents) == "table")
  assert(type(mode) == "string")

  local uv = vim.uv or vim.loop
  ---@diagnostic disable-next-line: undefined-field
  local handler, message = io.open(file_path, mode)
  if not handler then return nil, message end
  handler:write(vim.fn.join(contents, "\n"))
  handler:close()
  return true
end

return M
