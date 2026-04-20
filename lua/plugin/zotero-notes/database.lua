-- Copied from https://github.com/adam-coates/telescope-zotero.nvim/blob/3cdc7ce73b53e55e03e5a0d332764f299647c57b/lua/zotero/database.lua
-- MIT License
--
-- Copyright (c) 2024 Jannik Buhr
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local sqlite = require("sqlite.db")

local M = {}

-- Load and decode the Better-BibTeX JSON library file
-- Reloads on each call to ensure fresh data
---@param library_path string Path to library.json
---@return table|nil decoded JSON data or nil if failed
local function load_library(library_path)
  library_path = vim.fn.expand(library_path)
  
  -- Check if file exists
  if vim.fn.filereadable(library_path) == 0 then
    vim.notify_once(("[zotero] Library file not found at %s"):format(library_path))
    return nil
  end
  
  -- Read file as lines and join
  local ok, lines = pcall(vim.fn.readfile, library_path)
  if not ok then
    vim.notify_once(("[zotero] Could not read library file at %s"):format(library_path))
    return nil
  end
  
  -- Decode JSON using vim.json
  local json_str = table.concat(lines, "\n")
  local ok_decode, library = pcall(vim.json.decode, json_str)
  if not ok_decode then
    vim.notify_once(("[zotero] Failed to decode JSON library: %s"):format(library))
    return nil
  end
  
  return library
end

M.connect = function(opts)
  M.library_path = opts.bibtex_library_path
  
  -- Validate that the file exists
  if vim.fn.filereadable(vim.fn.expand(M.library_path)) == 0 then
    vim.notify_once(("[zotero] Library file not found at %s"):format(M.library_path))
    return false
  end
  
  return true
end


function M.get_items()
  local items = {}
  
  -- Load the JSON library file
  local library = load_library(M.library_path)
  if not library or not library.items then
    vim.notify_once("[zotero] Could not load items from library.", vim.log.levels.WARN)
    return {}
  end
  
  -- Process each item from the JSON
  for _, json_item in ipairs(library.items) do
    -- Skip attachment items (we only want bibliographic items)
    if json_item.itemType ~= "attachment" then
      -- Only include items that have a citation key
      if json_item.citationKey then
        local item = {
          key = json_item.key or json_item.itemKey,
          itemType = json_item.itemType,
          title = json_item.title,
          citekey = json_item.citationKey,
          creators = {},
          tags = {},
          attachment = {},
        }
        
        -- Add optional fields if they exist
        if json_item.date then item.date = json_item.date end
        if json_item.abstractNote then item.abstractNote = json_item.abstractNote end
        if json_item.pages then item.pages = json_item.pages end
        if json_item.DOI then item.DOI = json_item.DOI end
        if json_item.volume then item.volume = json_item.volume end
        if json_item.issue then item.issue = json_item.issue end
        if json_item.publicationTitle then item.publicationTitle = json_item.publicationTitle end
        if json_item.url then item.url = json_item.url end
        
        -- Process creators
        if json_item.creators and type(json_item.creators) == "table" then
          for idx, creator in ipairs(json_item.creators) do
            item.creators[idx] = {
              firstName = creator.firstName or "",
              lastName = creator.lastName or "",
              creatorType = creator.creatorType or "author",
            }
          end
        end
        
        -- Process tags (extract tag names from tag objects)
        if json_item.tags and type(json_item.tags) == "table" then
          for _, tag_entry in ipairs(json_item.tags) do
            if type(tag_entry) == "table" and tag_entry.tag then
              table.insert(item.tags, tag_entry.tag)
            elseif type(tag_entry) == "string" then
              -- Handle both object and string formats
              table.insert(item.tags, tag_entry)
            end
          end
        end
        
        -- Process attachments (find PDF)
        if json_item.attachments and type(json_item.attachments) == "table" then
          for _, attachment in ipairs(json_item.attachments) do
            -- Look for PDF attachments
            if attachment.path and (attachment.path:match("%.pdf$") or attachment.path:match("storage:")) then
              item.attachment = {
                path = attachment.path,
                contentType = attachment.contentType or "application/pdf",
              }
              break
            end
          end
        end
        
        table.insert(items, item)
      end
    end
  end
  
  return items
end

--- Connect to Zotero SQLite database
---@param opts table Options with zotero_db_path field
---@return boolean success True if connection successful, false otherwise
function M.connect_sqlite(opts)
  local db_path = vim.fn.expand(opts.zotero_db_path)
  
  -- Check if file exists
  if vim.fn.filereadable(db_path) == 0 then
    return false
  end
  
  -- Try to open database in read-only mode
  local ok, db = pcall(sqlite.open, db_path, { immutable = 1 })
  if not ok then
    return false
  end
  
  M.sqlite_db = db
  return true
end

--- Get abstract from SQLite database
---@param item_key string Zotero item key
---@return string|nil abstract Abstract text or nil if not found
function M.get_abstract_from_sqlite(item_key)
  if not M.sqlite_db then
    return nil
  end
  
  local ok, result = pcall(function()
    local query = [[
      SELECT idv.value
      FROM items i
      LEFT JOIN itemData id ON (i.itemID = id.itemID AND id.fieldID = (
        SELECT fieldID FROM fieldsCombined WHERE fieldName='abstractNote'))
      LEFT JOIN itemDataValues idv ON id.valueID = idv.valueID
      WHERE i.key = ?
    ]]
    
    local rows = M.sqlite_db:eval(query, item_key)
    if rows and #rows > 0 and rows[1] and rows[1][1] then
      return rows[1][1]
    end
    return nil
  end)
  
  if not ok then
    return nil
  end
  
  return result
end

--- Get annotations from SQLite database
---@param item_key string Zotero item key
---@return table annotations Array of annotation objects
function M.get_annotations_from_sqlite(item_key)
  if not M.sqlite_db then
    return {}
  end
  
  local ok, result = pcall(function()
    -- First, get the parent item's PDF attachments
    local query = [[
      SELECT ia.itemID, ia.type, ia.text, ia.comment, ia.color, ia.pageLabel, ia.sortIndex, 
             ann_item.key AS annotationKey, pdf_item.key AS pdfKey, parent_item.key AS parentKey
      FROM items parent_item
      JOIN itemAttachments att ON (parent_item.itemID = att.parentItemID)
      JOIN items pdf_item ON (att.itemID = pdf_item.itemID)
      JOIN itemAnnotations ia ON (att.itemID = ia.parentItemID)
      JOIN items ann_item ON (ia.itemID = ann_item.itemID)
      WHERE parent_item.key = ?
      ORDER BY ia.pageLabel, ia.sortIndex
    ]]
    
    local rows = M.sqlite_db:eval(query, item_key)
    local annotations = {}
    
    if rows then
      for _, row in ipairs(rows) do
        -- Annotation type: 1=highlight, 2=note, 3=image, 4=ink, 5=underline, 6=text
        local annot_type = "note"
        if row[2] == 1 or row[2] == 5 then  -- highlight or underline
          annot_type = "highlight"
        end
        
        table.insert(annotations, {
          type = annot_type,
          text = row[3],  -- highlighted text
          comment = row[4],  -- user's comment/note
          color = row[5],
          page = row[6],  -- page label
          position = row[7],  -- sort index
          annotationKey = row[8],
          pdfKey = row[9],
          parentKey = row[10],
        })
      end
    end
    
    return annotations
  end)
  
  if not ok then
    return {}
  end
  
  return result or {}
end

--- Get item notes from SQLite database
---@param item_key string Zotero item key
---@return table notes Array of note objects
function M.get_notes_from_sqlite(item_key)
  if not M.sqlite_db then
    return {}
  end
  
  local ok, result = pcall(function()
    -- Get standalone item notes (not PDF annotations)
    local query = [[
      SELECT note_item.key, note_item.note
      FROM items parent_item
      JOIN itemNotes note_item ON (parent_item.itemID = note_item.parentItemID)
      WHERE parent_item.key = ?
    ]]
    
    local rows = M.sqlite_db:eval(query, item_key)
    local notes = {}
    
    if rows then
      for _, row in ipairs(rows) do
        table.insert(notes, {
          type = "item_note",
          parentKey = row[1],  -- note item key
          text = row[2],  -- note content (may contain HTML)
        })
      end
    end
    
    return notes
  end)
  
  if not ok then
    return {}
  end
  
  return result or {}
end

return M
