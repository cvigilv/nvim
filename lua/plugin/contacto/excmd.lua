---@module "plugin.contacto.excmd"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local M = {}

--- Load contacts from JSON file
---@return table contacts Array of contact objects
local function load_contacts()
  local file = io.open(vim.g.contacto.config.dbpath, "r")
  if not file then return {} end

  local content = file:read("*a")
  file:close()

  if content == "" then return {} end

  local ok, contacts = pcall(vim.json.decode, content)
  if not ok then
    vim.notify("Error parsing contacts JSON: " .. contacts, vim.log.levels.ERROR)
    return {}
  end

  return contacts
end

--- Save contacts to JSON file
---@param contacts table Array of contact objects
local function save_contacts(contacts)
  local file = io.open(vim.g.contacto.config.dbpath, "w")
  if not file then
    vim.notify(
      "Error opening file for writing: " .. vim.g.contacto.config.dbpath,
      vim.log.levels.ERROR
    )
    return false
  end

  local json_content = vim.json.encode(contacts)
  file:write(json_content)
  file:close()
  return true
end

--- Find contact by id
---@param contacts table Array of contacts
---@param id string Contact ID to find
---@return table|nil contact Found contact or nil
---@return number|nil index Index of the contact in array
local function find_contact(contacts, id)
  for i, contact in ipairs(contacts) do
    if contact.id == id then return contact, i end
  end
  return nil, nil
end

--- Prompt user for input
---@param prompt string Prompt message
---@param default string|nil Default value
---@return string|nil input User input or nil if cancelled
local function prompt_user(prompt, default)
  local input = vim.fn.input(prompt .. (default and (" [" .. default .. "]") or "") .. ": ")
  if input == "" and default then return default end
  return input ~= "" and input or nil
end

--- Display contacts
---@param contacts table Array of contacts to display
local function display_contacts(contacts)
  if #contacts == 0 then
    print("No contacts found.")
    return
  end

  for _, contact in ipairs(contacts) do
    print("ID: " .. contact.id)
    if contact.properties.name then print("  Name: " .. contact.properties.name) end
    if contact.properties.nick or contact.properties.nickname then
      print("  Nick: " .. (contact.properties.nick or contact.properties.nickname))
    end
    if contact.properties.tags and #contact.properties.tags > 0 then
      print("  Tags: " .. table.concat(contact.properties.tags, ", "))
    end
    -- Display other properties
    for key, value in pairs(contact.properties) do
      if key ~= "name" and key ~= "nick" and key ~= "nickname" and key ~= "tags" then
        if type(value) == "table" then
          print("  " .. key .. ": " .. vim.json.encode(value))
        else
          print("  " .. key .. ": " .. tostring(value))
        end
      end
    end
    print("")
  end
end

--- Create a new contact
---@param args table Command arguments
---@param interactive boolean Whether to use interactive mode
M.create_contact = function(args, interactive)
  local id

  if interactive then
    id = prompt_user("Contact ID")
    if not id then
      print("Contact creation cancelled.")
      return
    end
  else
    if #args < 1 then
      vim.notify("Usage: :Contacto create <id>", vim.log.levels.ERROR)
      return
    end
    id = args[1]
  end

  local contacts = load_contacts()

  -- Check if contact already exists
  if find_contact(contacts, id) then
    vim.notify("Contact with ID '" .. id .. "' already exists.", vim.log.levels.ERROR)
    return
  end

  local new_contact = {
    id = id,
    properties = {},
  }

  if interactive then
    print("Enter properties for the contact (empty key to finish):")
    while true do
      local key = prompt_user("Property key")
      if not key or key == "" then break end

      local value = prompt_user("Property value")
      if value and value ~= "" then
        -- Try to parse as JSON for arrays/objects, otherwise keep as string
        local ok, parsed = pcall(vim.json.decode, value)
        new_contact.properties[key] = ok and parsed or value
      end
    end
  end

  table.insert(contacts, new_contact)

  if save_contacts(contacts) then
    print("Contact '" .. id .. "' created successfully.")
  else
    vim.notify("Failed to save contact.", vim.log.levels.ERROR)
  end
end

--- Read contacts
---@param args table Command arguments
---@param interactive boolean Whether to use interactive mode
M.read_contact = function(args, interactive)
  local id

  if interactive then
    id = prompt_user("Contact ID (empty for all contacts)")
  else
    id = args[1]
  end

  local contacts = load_contacts()

  if not id or id == "" then
    display_contacts(contacts)
    return
  end

  local contact = find_contact(contacts, id)
  if contact then
    display_contacts({ contact })
  else
    print("Contact with ID '" .. id .. "' not found.")
  end
end

--- Update a contact
---@param args table Command arguments
---@param interactive boolean Whether to use interactive mode
M.update_contact = function(args, interactive)
  local id, properties = nil, {}

  if interactive then
    id = prompt_user("Contact ID")
    if not id then
      print("Contact update cancelled.")
      return
    end

    print("Enter properties to update (empty key to finish):")
    while true do
      local key = prompt_user("Property key")
      if not key or key == "" then break end

      local value = prompt_user("Property value")
      if value and value ~= "" then
        -- Try to parse as JSON for arrays/objects, otherwise keep as string
        local ok, parsed = pcall(vim.json.decode, value)
        properties[key] = ok and parsed or value
      end
    end
  else
    if #args < 3 or #args % 2 == 0 then
      vim.notify(
        "Usage: :Contacto update <id> <key1> <value1> [key2] [value2] ...",
        vim.log.levels.ERROR
      )
      return
    end

    id = args[1]
    for i = 2, #args, 2 do
      local key = args[i]
      local value = args[i + 1]
      if value then
        -- Try to parse as JSON for arrays/objects, otherwise keep as string
        local ok, parsed = pcall(vim.json.decode, value)
        properties[key] = ok and parsed or value
      end
    end
  end

  if vim.tbl_isempty(properties) then
    print("No properties to update.")
    return
  end

  local contacts = load_contacts()
  local contact, index = find_contact(contacts, id)

  if not contact then
    vim.notify("Contact with ID '" .. id .. "' not found.", vim.log.levels.ERROR)
    return
  end

  -- Update properties
  for key, value in pairs(properties) do
    contact.properties[key] = value
  end

  contacts[index] = contact

  if save_contacts(contacts) then
    print("Contact '" .. id .. "' updated successfully.")
  else
    vim.notify("Failed to save contact.", vim.log.levels.ERROR)
  end
end

--- Delete a contact
---@param args table Command arguments
---@param interactive boolean Whether to use interactive mode
M.delete_contact = function(args, interactive)
  local id

  if interactive then
    id = prompt_user("Contact ID")
    if not id then
      print("Contact deletion cancelled.")
      return
    end
  else
    if #args < 1 then
      vim.notify("Usage: :Contacto delete <id>", vim.log.levels.ERROR)
      return
    end
    id = args[1]
  end

  local contacts = load_contacts()
  local contact, index = find_contact(contacts, id)

  if not contact then
    vim.notify("Contact with ID '" .. id .. "' not found.", vim.log.levels.ERROR)
    return
  end

  -- Confirm deletion in interactive mode
  if interactive then
    local confirm = prompt_user("Delete contact '" .. id .. "'? (y/N)", "N")
    if confirm:lower() ~= "y" and confirm:lower() ~= "yes" then
      print("Contact deletion cancelled.")
      return
    end
  end

  table.remove(contacts, index)

  if save_contacts(contacts) then
    print("Contact '" .. id .. "' deleted successfully.")
  else
    vim.notify("Failed to save contact.", vim.log.levels.ERROR)
  end
end

--- Setup function to create user commands
---@param opts Contacto.Configuration User configuration
M.setup = function(opts)
  -- Create main command with subcommands
  local logger = require("plugin.contacto.logging").new(opts.logging, true)
  logger.info("Creating 'Contacto[!]' user command")
  vim.api.nvim_create_user_command("Contacto", function(cmd_opts)
    local args = cmd_opts.fargs
    local interactive = cmd_opts.bang

    if #args == 0 then
      vim.notify(
        "Usage: :Contacto[!] <create|read|update|delete> [args...]",
        vim.log.levels.ERROR
      )
      return
    end

    local subcommand = args[1]
    local subargs = vim.list_slice(args, 2)

    if subcommand == "create" then
      M.create_contact(subargs, interactive)
    elseif subcommand == "read" then
      M.read_contact(subargs, interactive)
    elseif subcommand == "update" then
      M.update_contact(subargs, interactive)
    elseif subcommand == "delete" then
      M.delete_contact(subargs, interactive)
    else
      vim.notify("Unknown subcommand: " .. subcommand, vim.log.levels.ERROR)
      vim.notify("Available subcommands: create, read, update, delete", vim.log.levels.INFO)
    end
  end, {
    desc = "Contacto CRUD",
    nargs = "*",
    bang = true,
    complete = function(arg_lead, cmd_line, _)
      local args = vim.split(cmd_line, "%s+")
      if #args <= 2 then
        return vim.tbl_filter(
          function(item) return item:match("^" .. arg_lead) end,
          { "create", "read", "update", "delete" }
        )
      end
      return {}
    end,
  })
end

return M
