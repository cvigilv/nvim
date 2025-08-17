---@module "plugin.pkm.contacts.utils.json"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local M = {}

M.read = function(filepath)
  -- Check if file exists
  if vim.fn.filereadable(filepath) == 0 then
    error("File does not exist or is not readable: " .. filepath)
    return nil
  end

  -- Read file using Neovim's API
  local ok, content = pcall(vim.fn.readfile, filepath)
  if not ok then
    error("Failed to read file: " .. content)
    return nil
  end

  -- Join lines into single string
  local json_string = table.concat(content, "\n")

  -- Parse JSON
  local success, result = pcall(vim.json.decode, json_string)
  if not success then
    error("Failed to parse JSON: " .. result)
    return nil
  end

  return result
end

return M
