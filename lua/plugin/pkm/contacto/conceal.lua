---@module "plugin.pkm.contacto.conceal"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local ns_id = vim.api.nvim_create_namespace("contacto.conceal")

local M = {}

--- Function to apply concealment to current buffer, excluding cursor line
---@param opts Contacto.Configuration
local function conceal(opts, mappings)
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1 -- Convert to 0-based

  -- Clear existing extmarks
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

  -- Get all lines in the buffer
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Process each line
  for line_num, line_text in ipairs(lines) do
    local zero_based_line = line_num - 1

    -- Skip the cursor line
    if zero_based_line == cursor_line then goto continue end

    local col = 1

    -- Find all @... patterns in the line
    while true do
      local start_col, end_col = string.find(line_text, "@[%w%.]+", col)
      if not start_col then break end

      local pattern = string.sub(line_text, start_col, end_col)
      local replacement = mappings[pattern]

      if replacement then
        -- Create extmark with concealment
        vim.api.nvim_buf_set_extmark(bufnr, ns_id, zero_based_line, start_col - 1, {
          end_col = end_col,
          conceal = "",
          virt_text = {
            { "", "@contacto.cap" },
            { replacement, "@contacto.contact" },
            { "", "@contacto.cap" },
          },
          virt_text_pos = "inline",
        })
      end

      col = end_col + 1
    end

    ::continue::
  end
end

-- Setup concealment of contacts
---@param opts Contacto.Configuration User provided configuration table
M.setup = function(opts)
  -- Auto-apply concealment when entering buffer and after editing
  local augroup = vim.api.nvim_create_augroup("contacto.conceal", { clear = true })

  --- Get contacts
  local contacts = require("plugin.pkm.contacto.utils.json").read(opts.dbpath) --[[@as table]]
  local mappings = {}
  if contacts ~= "" then
    for _, entry in pairs(contacts) do
      if entry.properties ~= nil then
        mappings["@" .. entry.id] = entry.properties.nick or entry.name or entry.id
      end
    end
    conceal(opts, mappings)
    vim.api.nvim_create_autocmd({
      "BufEnter",
      "InsertLeave",
      "CursorMoved",
      "CursorMovedI",
    }, {
      group = augroup,
      buffer = vim.api.nvim_get_current_buf(),
      desc = "Conceal contacts",
      callback = function() conceal(opts, mappings) end,
    })
  end
end

return M
