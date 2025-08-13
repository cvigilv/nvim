local database = require('plugin.zotero.database')

local M = {}

-- Configuration
local config = {
  denote_silo_path = "~/zoteronotes",
  zotero_db_path = "~/.local/share/zotero/zotero.sqlite",
  better_bibtex_db_path = "~/.local/share/zotero/better-bibtex.sqlite",
  default_time = "09:00:00",
  debug = false
}

-- Helper Functions
local function sanitize_string(str)
  if not str or type(str) ~= "string" then
    return ""
  end
  -- Remove null bytes and other problematic characters
  str = str:gsub("%z", "") -- Remove null bytes
  str = str:gsub("[\1-\8\11\12\14-\31\127]", "") -- Remove other control characters
  return str
end

local function normalize_diacritics(str)
  local replacements = {
    ['á'] = 'a', ['à'] = 'a', ['ä'] = 'a', ['â'] = 'a', ['ã'] = 'a', ['å'] = 'a',
    ['é'] = 'e', ['è'] = 'e', ['ë'] = 'e', ['ê'] = 'e',
    ['í'] = 'i', ['ì'] = 'i', ['ï'] = 'i', ['î'] = 'i',
    ['ó'] = 'o', ['ò'] = 'o', ['ö'] = 'o', ['ô'] = 'o', ['õ'] = 'o', ['ø'] = 'o',
    ['ú'] = 'u', ['ù'] = 'u', ['ü'] = 'u', ['û'] = 'u',
    ['ç'] = 'c', ['ñ'] = 'n',
    ['Á'] = 'A', ['À'] = 'A', ['Ä'] = 'A', ['Â'] = 'A', ['Ã'] = 'A', ['Å'] = 'A',
    ['É'] = 'E', ['È'] = 'E', ['Ë'] = 'E', ['Ê'] = 'E',
    ['Í'] = 'I', ['Ì'] = 'I', ['Ï'] = 'I', ['Î'] = 'I',
    ['Ó'] = 'O', ['Ò'] = 'O', ['Ö'] = 'O', ['Ô'] = 'O', ['Õ'] = 'O', ['Ø'] = 'O',
    ['Ú'] = 'U', ['Ù'] = 'U', ['Ü'] = 'U', ['Û'] = 'U',
    ['Ç'] = 'C', ['Ñ'] = 'N'
  }
  
  for accented, plain in pairs(replacements) do
    str = str:gsub(accented, plain)
  end
  return str
end

local function generate_filename_title(title)
  if not title then return "" end
  
  title = sanitize_string(title)
  local normalized = normalize_diacritics(title)
  normalized = normalized:gsub("[^%w%s%-]", "")
  normalized = normalized:gsub("%s+", "_")
  normalized = normalized:gsub("_+", "_")
  normalized = normalized:gsub("^_+", "")
  normalized = normalized:gsub("_+$", "")
  
  return normalized:lower()
end

local function format_creators(creators)
  if not creators or type(creators) ~= "table" then
    return ""
  end

  local formatted = {}
  for _, creator in pairs(creators) do
    if creator and type(creator) == "table" then
      local name = ""
      if creator.firstName then
        name = sanitize_string(creator.firstName) .. " "
      end
      if creator.lastName then
        name = name .. sanitize_string(creator.lastName)
      end
      if name ~= "" then
        local sanitized_name = sanitize_string(name:gsub("^%s+", ""):gsub("%s+$", ""))
        if sanitized_name ~= "" then
          table.insert(formatted, sanitized_name)
        end
      end
    end
  end

  return table.concat(formatted, ", ")
end

local function format_tags(tags)
  if not tags or type(tags) ~= "table" then
    return ""
  end
  
  local formatted = {}
  for _, tag in pairs(tags) do
    if tag and type(tag) == "string" then
      local sanitized_tag = sanitize_string(tag)
      if sanitized_tag ~= "" then
        table.insert(formatted, sanitized_tag)
      end
    end
  end
  
  return table.concat(formatted, " ")
end

local function wrap_text(text, width)
  if not text or text == "" then
    return ""
  end
  
  text = sanitize_string(text)

  local lines = {}
  for line in text:gmatch("[^\r\n]+") do
    if #line <= width then
      table.insert(lines, line)
    else
      local current_pos = 1
      while current_pos <= #line do
        local end_pos = current_pos + width - 1
        if end_pos >= #line then
          table.insert(lines, line:sub(current_pos))
          break
        else
          local wrap_pos = end_pos
          while wrap_pos > current_pos and line:sub(wrap_pos, wrap_pos) ~= " " do
            wrap_pos = wrap_pos - 1
          end
          if wrap_pos == current_pos then
            wrap_pos = end_pos
          end
          
          local line_part = sanitize_string(line:sub(current_pos, wrap_pos):gsub("%s+$", ""))
          if line_part ~= "" then
            table.insert(lines, line_part)
          end
          current_pos = wrap_pos + 1
          while current_pos <= #line and line:sub(current_pos, current_pos) == " " do
            current_pos = current_pos + 1
          end
        end
      end
    end
  end
  
  return table.concat(lines, "\n")
end

local function clean_html_content(content)
  if not content then return "" end
  
  content = sanitize_string(content)
  
  content = content:gsub('<span class="highlight"[^>]*>', "")
  content = content:gsub("</span>", "")
  content = content:gsub("<br[^>]*>", "\n")
  content = content:gsub("</?p[^>]*>", "\n")
  content = content:gsub("<[^>]*>", "")
  content = content:gsub("&nbsp;", " ")
  content = content:gsub("&amp;", "&")
  content = content:gsub("&lt;", "<")
  content = content:gsub("&gt;", ">")
  content = content:gsub("&quot;", '"')
  content = content:gsub("&#39;", "'")
  
  content = content:gsub("\n\n+", "\n\n")
  content = content:gsub("^%s+", "")
  content = content:gsub("%s+$", "")
  
  return content
end

local function process_annotations(annotations, textwidth)
  if not annotations or type(annotations) ~= "table" or #annotations == 0 then
    return ""
  end
  
  local content_parts = {}
  local current_page = nil
  
  for _, annotation in ipairs(annotations) do
    if annotation.pageLabel and annotation.pageLabel ~= current_page then
      current_page = annotation.pageLabel
      table.insert(content_parts, string.format("** Page %s", current_page))
    end
    
    if annotation.type == "highlight" and annotation.text then
      local clean_text = clean_html_content(annotation.text)
      local wrapped_text = wrap_text(clean_text, textwidth)
      table.insert(content_parts, wrapped_text)
      
      if annotation.comment and annotation.comment ~= "" then
        local clean_comment = clean_html_content(annotation.comment)
        local wrapped_comment = wrap_text(clean_comment, textwidth)
        table.insert(content_parts, string.format("    Note: %s", wrapped_comment))
      end
      
    elseif annotation.type == "note" and annotation.comment then
      local clean_comment = clean_html_content(annotation.comment)
      local wrapped_comment = wrap_text(clean_comment, textwidth)
      table.insert(content_parts, string.format("Note: %s", wrapped_comment))
    end
    
    table.insert(content_parts, "")
  end
  
  return table.concat(content_parts, "\n")
end

local function generate_denote_filename(item, date_str)
  local time_part = config.default_time:gsub(":", "")
  local datetime = date_str .. "T" .. time_part
  
  local title_part = generate_filename_title(item.title or "untitled")
  if title_part == "" then
    title_part = "untitled"
  end
  
  local keywords_part = ""
  if item.tags and type(item.tags) == "table" then
    local tag_parts = {}
    for _, tag in pairs(item.tags) do
      if tag and type(tag) == "string" then
        local clean_tag = generate_filename_title(tag)
        if clean_tag ~= "" then
          table.insert(tag_parts, clean_tag)
        end
      end
    end
    if #tag_parts > 0 then
      keywords_part = "__" .. table.concat(tag_parts, "_")
    end
  end
  
  return datetime .. "--" .. title_part .. keywords_part .. ".org"
end

local function create_denote_content(item, annotations_content)
  local textwidth = vim.o.textwidth > 0 and vim.o.textwidth or 78
  
  local content_parts = {
    "#+title: " .. sanitize_string(item.title or "Untitled"),
    "#+date: " .. os.date("%Y-%m-%d"),
    "#+filetags: " .. format_tags(item.tags or {}),
    ""
  }
  
  if item.abstractNote then
    table.insert(content_parts, "* Abstract")
    local wrapped_abstract = wrap_text(item.abstractNote, textwidth)
    table.insert(content_parts, wrapped_abstract)
    table.insert(content_parts, "")
  end
  
  table.insert(content_parts, "* Bibliographic Information")
  
  local authors = format_creators(item.creators or {})
  if authors ~= "" then
    table.insert(content_parts, "- Authors: " .. authors)
  end
  
  if item.publicationTitle then
    table.insert(content_parts, "- Publication: " .. sanitize_string(item.publicationTitle))
  end
  
  if item.date then
    table.insert(content_parts, "- Date: " .. sanitize_string(item.date))
  end
  
  if item.pages then
    table.insert(content_parts, "- Pages: " .. sanitize_string(item.pages))
  end
  
  if item.DOI then
    table.insert(content_parts, "- DOI: " .. sanitize_string(item.DOI))
  end
  
  if item.url then
    table.insert(content_parts, "- URL: " .. sanitize_string(item.url))
  end
  
  if item.citekey then
    table.insert(content_parts, "- Citation Key: " .. sanitize_string(item.citekey))
  end
  
  table.insert(content_parts, "")
  
  if annotations_content and annotations_content ~= "" then
    table.insert(content_parts, "* Notes and Annotations")
    table.insert(content_parts, annotations_content)
  end
  
  return table.concat(content_parts, "\n")
end

local function ensure_directory(path)
  local expanded_path = vim.fn.expand(path)
  if vim.fn.isdirectory(expanded_path) == 0 then
    if config.debug then
      vim.notify(string.format("[zotero] Creating directory: %s", expanded_path))
    end
    vim.fn.mkdir(expanded_path, "p")
  end
end

local function file_exists(path)
  local file = io.open(path, "r")
  if file then
    file:close()
    return true
  end
  return false
end

-- Main sync function
function M.sync()
  if config.debug then
    vim.notify("[zotero] Starting Zotero sync...")
  end
  
  if not database.connect({
    zotero_db_path = config.zotero_db_path,
    better_bibtex_db_path = config.better_bibtex_db_path
  }) then
    vim.notify("[zotero] Failed to connect to databases", vim.log.levels.ERROR)
    return
  end
  
  if config.debug then
    vim.notify("[zotero] Successfully connected to databases")
  end
  
  local items = database.get_items()
  if not items or #items == 0 then
    vim.notify("[zotero] No items found in database")
    return
  end
  
  if config.debug then
    vim.notify(string.format("[zotero] Found %d items", #items))
  end
  
  ensure_directory(config.denote_silo_path)
  
  local date_str = os.date("%Y%m%d")
  local processed_count = 0
  local error_count = 0
  
  for i, item in ipairs(items) do
    if config.debug and i % 10 == 0 then
      vim.notify(string.format("[zotero] Processing item %d/%d", i, #items))
    end
    
    local success, err = pcall(function()
      local annotations, db_err = database.get_annotations(item.key)
      if db_err or not annotations or type(annotations) ~= "table" then
        if config.debug and db_err then
          vim.notify(string.format("[zotero] Error fetching annotations for %s: %s", item.key, db_err))
        end
        annotations = {}
      end
      
      local textwidth = vim.o.textwidth > 0 and vim.o.textwidth or 78
      local annotations_content = process_annotations(annotations or {}, textwidth)
      
      local filename = generate_denote_filename(item, date_str)
      local filepath = vim.fn.expand(config.denote_silo_path) .. "/" .. filename
      
      if not file_exists(filepath) then
        local content = create_denote_content(item, annotations_content)
        
        local file = io.open(filepath, "w")
        if file then
          file:write(content)
          file:close()
          processed_count = processed_count + 1
          
          if config.debug then
            vim.notify(string.format("[zotero] Created: %s", filename))
          end
        else
          if config.debug then
            vim.notify(string.format("[zotero] Failed to write file: %s", filepath), vim.log.levels.ERROR)
          end
          error_count = error_count + 1
        end
      else
        if config.debug then
          vim.notify(string.format("[zotero] Skipped existing file: %s", filename))
        end
      end
    end)
    
    if not success then
      error_count = error_count + 1
      if config.debug then
        vim.notify(string.format("[zotero] Error processing item %s: %s", item.key or "unknown", err), vim.log.levels.ERROR)
      end
    end
  end
  
  vim.notify(string.format("[zotero] Sync complete: %d files created, %d errors", processed_count, error_count))
end

-- Setup function
function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
  
  if config.debug then
    vim.notify("[zotero] Configuration loaded:")
    vim.notify(string.format("  denote_silo_path: %s", config.denote_silo_path))
    vim.notify(string.format("  zotero_db_path: %s", config.zotero_db_path))
    vim.notify(string.format("  better_bibtex_db_path: %s", config.better_bibtex_db_path))
  end
end

-- Debug toggle
function M.set_debug(enabled)
  config.debug = enabled
  vim.notify(string.format("[zotero] Debug mode: %s", enabled and "enabled" or "disabled"))
end

return M