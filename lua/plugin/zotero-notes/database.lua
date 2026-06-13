---@module "plugin.zotero-notes.database"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local M = {}

---@type table|nil Cached library data
local library_data = nil

--- Load and parse the Better BibTeX JSON library export
---@param path string Absolute path to library.json
---@return boolean success
function M.load(path)
  if vim.fn.filereadable(path) == 0 then
    vim.notify_once(("[zotero] library file not found at %s"):format(path), vim.log.levels.ERROR)
    return false
  end

  local content = table.concat(vim.fn.readfile(path), "\n")
  local ok, data = pcall(vim.json.decode, content)
  if not ok then
    vim.notify_once("[zotero] failed to parse library JSON: " .. tostring(data), vim.log.levels.ERROR)
    return false
  end

  library_data = data
  return true
end

--- Get all bibliography items from the loaded library
---@return table[] items List of items in the format expected by the picker
function M.get_items()
  if not library_data or not library_data.items then
    vim.notify_once("[zotero] library data not loaded.", vim.log.levels.WARN)
    return {}
  end

  local items = {}

  for _, raw in ipairs(library_data.items) do
    -- Skip standalone attachments and notes at the top level
    if raw.itemType ~= "attachment" and raw.itemType ~= "note" and raw.citationKey then
      -- Extract tags as plain strings
      local tags = {}
      for _, t in ipairs(raw.tags or {}) do
        table.insert(tags, t.tag)
      end

      -- Find first PDF attachment
      local attachment = nil
      for _, att in ipairs(raw.attachments or {}) do
        if att.path and att.path:match("%.pdf$") then
          attachment = { path = att.path }
          break
        end
      end

      table.insert(items, {
        key = raw.key,
        citekey = raw.citationKey,
        itemType = raw.itemType,
        title = raw.title or "",
        date = raw.date,
        DOI = raw.DOI,
        abstractNote = raw.abstractNote,
        pages = raw.pages,
        creators = raw.creators or {},
        tags = tags,
        attachment = attachment,
      })
    end
  end

  return items
end

return M
