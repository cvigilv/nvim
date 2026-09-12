---@module "lib.cmds"
---@author Carlos Vigil-Vásquez
---@license MIT 2026

local M = {}

---@alias lib.cmds.CompletionTree table<string|integer, string|number|lib.cmds.CompletionTree>

---Collect the choices at one level and map choices with nested tables to their children.
---@param items lib.cmds.CompletionTree
---@return string[] choices
---@return table<string, lib.cmds.CompletionTree> children
local function level_choices(items)
  local choices = {}
  local children = {}
  local seen = {}

  local function add(choice, child)
    if not seen[choice] then
      choices[#choices + 1] = choice
      seen[choice] = true
    end
    if child then children[choice] = child end
  end

  local sequence_length = #items
  for index = 1, sequence_length do
    local value = items[index]
    if type(value) == "string" or type(value) == "number" then add(tostring(value)) end
  end

  local keyed_choices = {}
  for key, value in pairs(items) do
    local is_sequence_item = type(key) == "number"
      and key % 1 == 0
      and key >= 1
      and key <= sequence_length
    if not is_sequence_item and (type(key) == "string" or type(key) == "number") then
      keyed_choices[#keyed_choices + 1] = {
        choice = tostring(key),
        child = type(value) == "table" and value or nil,
      }
    end
  end
  table.sort(keyed_choices, function(a, b) return a.choice < b.choice end)
  for _, item in ipairs(keyed_choices) do
    add(item.choice, item.child)
  end

  return choices, children
end

---Find the choices available after following a path through the completion tree.
---@param items lib.cmds.CompletionTree
---@param path string[]
---@param level? integer
---@return string[]
local function choices_at(items, path, level)
  level = level or 1
  local choices, children = level_choices(items)
  if level > #path then return choices end

  local child = children[path[level]]
  if not child then return {} end
  return choices_at(child, path, level + 1)
end

---Create a nested completion function for a user command.
---@param items lib.cmds.CompletionTree Nested keyed tables and lists of leaf choices
---@param fuzzy boolean Whether to use fuzzy matching instead of prefix matching
---@return fun(arg_lead: string, cmd_line: string, cursor_pos: integer): string[]
function M.make_user_completion(items, fuzzy)
  return function(arg_lead, cmd_line, cursor_pos)
    local args = vim.split(cmd_line:sub(1, cursor_pos), "%s+", { trimempty = true })
    local completed = #args - 1 - (arg_lead == "" and 0 or 1)
    local path = {}
    for index = 1, completed do
      path[index] = args[index + 1]
    end

    local choices = choices_at(items, path)
    if arg_lead == "" then return choices end
    if fuzzy then return vim.fn.matchfuzzy(choices, arg_lead) end
    return vim.tbl_filter(function(choice) return vim.startswith(choice, arg_lead) end, choices)
  end
end

return M
