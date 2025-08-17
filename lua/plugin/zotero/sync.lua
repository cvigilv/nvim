-- Zotero to Denote sync using SQLite database
local database = require('plugin.zotero.database')

local M = {}

-- Configuration
local config = {
  denote_silo_path = "~/org/notes",
  zotero_db_path = "~/.local/share/zotero/zotero.sqlite",
  better_bibtex_db_path = "~/.local/share/zotero/better-bibtex.sqlite",
  default_time = "09:00:00",
  debug = false
}

-- Track used timestamps to ensure uniqueness
local used_timestamps = {}

-- Logging functions
local function log_error(msg)
  vim.notify(msg, vim.log.levels.ERROR, { title = "Zotero Sync" })
end

local function log_info(msg)
  vim.notify(msg, vim.log.levels.INFO, { title = "Zotero Sync" })
end

local function log_warn(msg)
  vim.notify(msg, vim.log.levels.WARN, { title = "Zotero Sync" })
end

local function log_debug(msg)
  if config.debug then
    print("[Zotero Debug] " .. msg)
  end
end

-- Progress messaging for async operations
local function progress_message(msg)
  vim.schedule(function()
    vim.api.nvim_echo({{string.format("[Zotero Sync] %s", msg), "Normal"}}, false, {})
  end)
end

local function progress_info(msg)
  vim.schedule(function()
    vim.notify(msg, vim.log.levels.INFO, { title = "Zotero Sync" })
  end)
end

local function progress_error(msg)
  vim.schedule(function()
    vim.notify(msg, vim.log.levels.ERROR, { title = "Zotero Sync" })
  end)
end

-- Text wrapping that respects vim's textwidth setting
local function wrap_text(text, width)
  width = width or vim.bo.textwidth
  if width == 0 then width = 80 end
  
  local lines = {}
  local current_line = ""
  
  for word in text:gmatch("%S+") do
    if #current_line > 0 and #current_line + #word + 1 > width then
      table.insert(lines, current_line)
      current_line = word
    elseif #current_line == 0 then
      current_line = word
    else
      current_line = current_line .. " " .. word
    end
  end
  
  if #current_line > 0 then
    table.insert(lines, current_line)
  end
  
  return table.concat(lines, "\n")
end

-- Comprehensive diacritic normalization for filenames
local function normalize_diacritics(str)
  if not str then return str end
  
  local diacritic_map = {
    -- Vowels
    ["à"] = "a", ["á"] = "a", ["â"] = "a", ["ã"] = "a", ["ä"] = "a", ["å"] = "a", ["ā"] = "a", ["ă"] = "a", ["ą"] = "a",
    ["À"] = "A", ["Á"] = "A", ["Â"] = "A", ["Ã"] = "A", ["Ä"] = "A", ["Å"] = "A", ["Ā"] = "A", ["Ă"] = "A", ["Ą"] = "A",
    ["è"] = "e", ["é"] = "e", ["ê"] = "e", ["ë"] = "e", ["ē"] = "e", ["ĕ"] = "e", ["ė"] = "e", ["ę"] = "e", ["ě"] = "e",
    ["È"] = "E", ["É"] = "E", ["Ê"] = "E", ["Ë"] = "E", ["Ē"] = "E", ["Ĕ"] = "E", ["Ė"] = "E", ["Ę"] = "E", ["Ě"] = "E",
    ["ì"] = "i", ["í"] = "i", ["î"] = "i", ["ï"] = "i", ["ĩ"] = "i", ["ī"] = "i", ["ĭ"] = "i", ["į"] = "i", ["ı"] = "i",
    ["Ì"] = "I", ["Í"] = "I", ["Î"] = "I", ["Ï"] = "I", ["Ĩ"] = "I", ["Ī"] = "I", ["Ĭ"] = "I", ["Į"] = "I", ["İ"] = "I",
    ["ò"] = "o", ["ó"] = "o", ["ô"] = "o", ["õ"] = "o", ["ö"] = "o", ["ø"] = "o", ["ō"] = "o", ["ŏ"] = "o", ["ő"] = "o",
    ["Ò"] = "O", ["Ó"] = "O", ["Ô"] = "O", ["Õ"] = "O", ["Ö"] = "O", ["Ø"] = "O", ["Ō"] = "O", ["Ŏ"] = "O", ["Ő"] = "O",
    ["ù"] = "u", ["ú"] = "u", ["û"] = "u", ["ü"] = "u", ["ũ"] = "u", ["ū"] = "u", ["ŭ"] = "u", ["ů"] = "u", ["ű"] = "u", ["ų"] = "u",
    ["Ù"] = "U", ["Ú"] = "U", ["Û"] = "U", ["Ü"] = "U", ["Ũ"] = "U", ["Ū"] = "U", ["Ŭ"] = "U", ["Ů"] = "U", ["Ű"] = "U", ["Ų"] = "U",
    ["ý"] = "y", ["ÿ"] = "y", ["ỳ"] = "y", ["ỹ"] = "y", ["ȳ"] = "y", ["ŷ"] = "y",
    ["Ý"] = "Y", ["Ÿ"] = "Y", ["Ỳ"] = "Y", ["Ỹ"] = "Y", ["Ȳ"] = "Y", ["Ŷ"] = "Y",
    
    -- Consonants
    ["ç"] = "c", ["ć"] = "c", ["ĉ"] = "c", ["ċ"] = "c", ["č"] = "c",
    ["Ç"] = "C", ["Ć"] = "C", ["Ĉ"] = "C", ["Ċ"] = "C", ["Č"] = "C",
    ["ń"] = "n", ["ņ"] = "n", ["ň"] = "n", ["ŉ"] = "n", ["ŋ"] = "n", ["ñ"] = "n",
    ["Ń"] = "N", ["Ņ"] = "N", ["Ň"] = "N", ["Ŋ"] = "N", ["Ñ"] = "N",
    ["ś"] = "s", ["ŝ"] = "s", ["ş"] = "s", ["š"] = "s",
    ["Ś"] = "S", ["Ŝ"] = "S", ["Ş"] = "S", ["Š"] = "S",
    ["ž"] = "z", ["ź"] = "z", ["ż"] = "z",
    ["Ž"] = "Z", ["Ź"] = "Z", ["Ż"] = "Z",
    
    -- Special characters
    ["æ"] = "ae", ["œ"] = "oe", ["ß"] = "ss",
    ["Æ"] = "AE", ["Œ"] = "OE",
  }
  
  local normalized = str
  for diacritic, replacement in pairs(diacritic_map) do
    normalized = normalized:gsub(diacritic, replacement)
  end
  
  return normalized
end

-- Sanitize string for filename
local function sanitize_for_filename(str)
  if not str then return "unknown" end
  
  return normalize_diacritics(str)
    :gsub("%s+", "-")
    :gsub("[^%w%-_]", "")
    :gsub("%-+", "-")
    :gsub("^%-", "")
    :gsub("%-$", "")
    :lower()
end

-- Format highlight with quotes and equation detection
local function format_highlight_with_quotes(text)
  if not text or text == "" then
    return text
  end
  
  -- Wrap in quotes and check for equations
  local quoted_text = '"' .. text .. '"'
  
  -- Detect centered equations (contains mathematical notation)
  if text:match("[∑∏∫∂∆∇±≤≥≠≈∞]") or text:match("[%w%s]*=%s*[%w%s]*") then
    return quoted_text .. "\n"  -- Add newline for equations
  else
    return quoted_text
  end
end

-- Process note content with HTML cleaning and text wrapping
local function process_note_content(content)
  if not content or content == "" then
    log_debug("process_note_content: empty or nil content")
    return ""
  end
  
  log_debug("process_note_content: original content length: " .. #content)
  log_debug("process_note_content: original content: " .. tostring(content))
  
  -- Handle case where content is already plain text (no HTML)
  if not content:find("<") then
    log_debug("process_note_content: content has no HTML tags, treating as plain text")
    -- Just wrap the text and return
    local wrapped = wrap_text(content)
    log_debug("process_note_content: wrapped plain text: " .. tostring(wrapped))
    return wrapped
  end
  
  -- Clean HTML tags while preserving structure
  content = content:gsub("<br>", "\n")
  content = content:gsub("<br/>", "\n")
  content = content:gsub("<br />", "\n")
  content = content:gsub("</p>%s*<p>", "\n\n")
  content = content:gsub("<p>", "")
  content = content:gsub("</p>", "")
  
  log_debug("process_note_content: after HTML tag cleaning: " .. tostring(content))
  
  -- Handle HTML entities
  content = content:gsub("&lt;", "<")
  content = content:gsub("&gt;", ">")
  content = content:gsub("&amp;", "&")
  content = content:gsub("&quot;", '"')
  content = content:gsub("&apos;", "'")
  content = content:gsub("&#39;", "'")
  content = content:gsub("&nbsp;", " ")
  content = content:gsub("&#(%d+);", function(n)
    return string.char(tonumber(n))
  end)
  
  log_debug("process_note_content: after entity decoding: " .. tostring(content))
  
  -- Convert Zotero links to org-mode format
  content = content:gsub('<a href="(zotero://[^"]*)"[^>]*>([^<]*)</a>', "[[%1][%2]]")
  content = content:gsub('<a href="(https?://[^"]*)"[^>]*>([^<]*)</a>', "[[%1][%2]]")
  content = content:gsub('<a href="([^"]*)"[^>]*>([^<]*)</a>', "[[%1][%2]]")
  
  -- Remove any remaining HTML tags
  content = content:gsub("<[^>]+>", "")
  
  log_debug("process_note_content: after link conversion and tag removal: " .. tostring(content))
  
  -- Split into paragraphs and wrap each one
  local paragraphs = {}
  for paragraph in content:gmatch("[^\n\n]+") do
    paragraph = paragraph:gsub("\n", " ")
    paragraph = paragraph:gsub("%s+", " ")
    paragraph = paragraph:match("^%s*(.-)%s*$")
    
    if paragraph and paragraph ~= "" then
      table.insert(paragraphs, wrap_text(paragraph))
    end
  end
  
  local result = table.concat(paragraphs, "\n\n")
  log_debug("process_note_content: final result length: " .. #result)
  log_debug("process_note_content: final result: " .. tostring(result))
  
  return result
end

-- Parse date to timestamp
local function parse_date(date_str)
  if not date_str then
    log_debug("No date string provided")
    return nil
  end
  
  log_debug("Parsing date: " .. date_str)
  
  local year, month, day = date_str:match("(%d%d%d%d)%-(%d%d)%-(%d%d)")
  if not year then
    year = date_str:match("(%d%d%d%d)")
    month, day = "01", "01"
  end
  
  if year then
    local time_parts = vim.split(config.default_time, ":")
    local timestamp = os.time({
      year = tonumber(year),
      month = tonumber(month) or 1,
      day = tonumber(day) or 1,
      hour = tonumber(time_parts[1]) or 9,
      min = tonumber(time_parts[2]) or 0,
      sec = tonumber(time_parts[3]) or 0,
    })
    log_debug("Parsed timestamp: " .. timestamp)
    return timestamp
  end
  
  log_debug("Could not parse date, using current time")
  return os.time()
end

-- Generate unique Denote identifier
local function generate_denote_id(timestamp)
  local base_time = timestamp or os.time()
  local counter = 0
  
  while true do
    local test_time = base_time + counter
    local id = os.date("%Y%m%dT%H%M%S", test_time)
    
    if not used_timestamps[id] then
      used_timestamps[id] = true
      log_debug("Generated Denote ID: " .. id)
      return id, test_time
    end
    
    counter = counter + 1
  end
end

-- Extract first author's last name for filename (sanitized)
local function get_first_author_lastname(creators)
  if not creators or type(creators) ~= "table" then
    log_debug("No creators found")
    return "unknown"
  end
  
  log_debug("Processing creators")
  
  for _, creator in pairs(creators) do
    if creator and type(creator) == "table" then
      if creator.creatorType == "author" and creator.lastName then
        log_debug("Found author: " .. creator.lastName)
        return sanitize_for_filename(creator.lastName)
      end
    end
  end
  
  -- Fall back to first creator
  for _, creator in pairs(creators) do
    if creator and type(creator) == "table" and creator.lastName then
      log_debug("Using first creator: " .. creator.lastName)
      return sanitize_for_filename(creator.lastName)
    end
  end
  
  log_debug("No valid author found")
  return "unknown"
end

-- Extract first author's last name for display (unsanitized)
local function get_first_author_display_name(creators)
  if not creators or type(creators) ~= "table" then
    return "Unknown"
  end
  
  for _, creator in pairs(creators) do
    if creator and type(creator) == "table" then
      if creator.creatorType == "author" and creator.lastName then
        return creator.lastName
      end
    end
  end
  
  -- Fall back to first creator
  for _, creator in pairs(creators) do
    if creator and type(creator) == "table" and creator.lastName then
      return creator.lastName
    end
  end
  
  return "Unknown"
end

-- Generate Denote-compliant filename: TIMESTAMP==SIGNATURE--TITLE.org
local function generate_filename(item, timestamp_id)
  log_debug("Generating filename for item: " .. (item.title or "unknown"))
  
  local author = get_first_author_lastname(item.creators)
  local title = sanitize_for_filename(item.title or "untitled")
  local combined_title = author .. "-" .. title
  
  local filename = string.format("%s==refs--%s.org", timestamp_id, combined_title)
  log_debug("Generated filename: " .. filename)
  return filename
end

-- Format date for org-mode frontmatter
local function format_org_date(timestamp)
  if not timestamp then
    return os.date("[%Y-%m-%d %A %H:%M:%S]")
  end
  return os.date("[%Y-%m-%d %A %H:%M:%S]", timestamp)
end

-- Create aligned frontmatter with proper order
local function create_frontmatter(data)
  local lines = {}
  local fields = {"title", "date", "filetags", "identifier", "signature", "doi"}
  
  -- Find max key length for alignment
  local max_length = 0
  for _, key in ipairs(fields) do
    if data[key] and #key > max_length then
      max_length = #key
    end
  end
  
  -- Create aligned lines
  for _, key in ipairs(fields) do
    if data[key] then
      local uppercase_key = key:upper()
      local padding = string.rep(" ", max_length - #uppercase_key)
      table.insert(lines, string.format("#+%s:%s %s", uppercase_key, padding, data[key]))
    end
  end
  
  return lines
end

-- Format author and title for display
local function format_first_author_with_title(creators, title, date)
  if not creators or type(creators) ~= "table" then 
    local year = date and date:match("^(%d%d%d%d)") or ""
    if year ~= "" then
      return string.format("Unknown, %s - %s", year, title or "Untitled")
    else
      return title or "Untitled"
    end
  end
  
  local first_author = nil
  for _, creator in pairs(creators) do
    if creator and type(creator) == "table" then
      if creator.creatorType == "author" then
        first_author = creator.lastName or "Unknown"
        break
      end
    end
  end
  
  -- Fall back to first creator
  if not first_author then
    for _, creator in pairs(creators) do
      if creator and type(creator) == "table" and creator.lastName then
        first_author = creator.lastName
        break
      end
    end
  end
  
  first_author = first_author or "Unknown"
  local year = date and date:match("^(%d%d%d%d)") or ""
  
  if year ~= "" then
    return string.format("%s, %s - %s", first_author, year, title or "Untitled")
  else
    return string.format("%s - %s", first_author, title or "Untitled")
  end
end

-- Format annotations for org content
local function format_annotations(annotations, item_key)
  if not annotations or type(annotations) ~= "table" or #annotations == 0 then
    return "No annotations found."
  end
  
  local content_parts = {}
  local current_page = nil
  
  for _, annotation in ipairs(annotations) do
    -- Debug: log annotation structure
    if config.debug then
      log_debug("Processing annotation: " .. vim.inspect(annotation))
    end
    
    -- Track current page but don't create subheadings
    if annotation.pageLabel and annotation.pageLabel ~= current_page then
      current_page = annotation.pageLabel
    end
    
    -- Helper function to create annotation link
    local function create_annotation_link()
      -- Use the proper Zotero annotation URL format with PDF key
      local pdf_key = annotation.pdfKey or item_key  -- Fallback to item key if no PDF key
      
      if annotation.annotationKey and annotation.pageLabel and pdf_key then
        return string.format(" [[zotero://open-pdf/library/items/%s?page=%s&annotation=%s][(see in pdf)]]", 
          pdf_key, annotation.pageLabel, annotation.annotationKey)
      elseif annotation.pageLabel and pdf_key then
        return string.format(" [[zotero://open-pdf/library/items/%s?page=%s][(see in pdf)]]", pdf_key, annotation.pageLabel)
      else
        return string.format(" [[zotero://select/library/items/%s][(see in pdf)]]", item_key)
      end
    end
    
    -- Zotero annotation types: 1=highlight, 2=note, 3=image
    -- Handle highlights (type = 1)
    if (annotation.type == 1 or annotation.type == "highlight") and annotation.text then
      log_debug("Found highlight with text: " .. tostring(annotation.text))
      local clean_text = process_note_content(annotation.text)
      log_debug("Processed text: " .. tostring(clean_text))
      if clean_text and clean_text ~= "" then
        -- Wrap all annotations in quotes
        local formatted_text = format_highlight_with_quotes(clean_text)
        table.insert(content_parts, formatted_text .. create_annotation_link())
      else
        table.insert(content_parts, "[Empty highlight text]")
      end
      
      if annotation.comment and annotation.comment ~= "" then
        log_debug("Found comment: " .. tostring(annotation.comment))
        local clean_comment = process_note_content(annotation.comment)
        log_debug("Processed comment: " .. tostring(clean_comment))
        if clean_comment and clean_comment ~= "" then
          table.insert(content_parts, string.format("    Note: %s", clean_comment))
        end
      end
      
    -- Handle notes (type = 2)  
    elseif (annotation.type == 2 or annotation.type == "note") and annotation.comment then
      log_debug("Found note with comment: " .. tostring(annotation.comment))
      local clean_comment = process_note_content(annotation.comment)
      log_debug("Processed note comment: " .. tostring(clean_comment))
      if clean_comment and clean_comment ~= "" then
        table.insert(content_parts, string.format("Note: %s%s", clean_comment, create_annotation_link()))
      else
        table.insert(content_parts, "[Empty note]")
      end
    
    -- Handle other annotation types
    elseif annotation.text then
      log_debug("Found annotation with text (type " .. tostring(annotation.type) .. "): " .. tostring(annotation.text))
      local clean_text = process_note_content(annotation.text)
      if clean_text and clean_text ~= "" then
        local formatted_text = format_highlight_with_quotes(clean_text)
        table.insert(content_parts, formatted_text .. create_annotation_link())
      end
    end
    
    table.insert(content_parts, "")
  end
  
  return table.concat(content_parts, "\n")
end

-- Generate complete org-mode content with annotations
local function generate_org_content_with_annotations(item, timestamp_id, annotations)
  local lines = {}
  
  -- Create frontmatter
  local formatted_title = format_first_author_with_title(item.creators, item.title, item.date)
  local pub_timestamp = parse_date(item.date)
  
  local frontmatter = {
    title = formatted_title,
    date = format_org_date(pub_timestamp),
    signature = "refs",
    filetags = "",
    identifier = timestamp_id,
  }
  
  if item.DOI then
    frontmatter.doi = item.DOI
  end
  
  local frontmatter_lines = create_frontmatter(frontmatter)
  for _, line in ipairs(frontmatter_lines) do
    table.insert(lines, line)
  end
  table.insert(lines, "")
  
  -- Main heading with author, year, and title
  local year = item.date and item.date:match("^(%d%d%d%d)") or ""
  local first_author_display = get_first_author_display_name(item.creators)
  
  local main_title = string.format("* %s, %s - %s", 
    first_author_display, 
    year,
    item.title or "Untitled")
  table.insert(lines, main_title)
  
  -- Add links section
  if item.key then
    local links = {}
    if item.citekey then
      table.insert(links, string.format("cite:%s", item.citekey))
    end
    table.insert(links, string.format("[[zotero://select/library/items/%s][Open in Zotero]]", item.key))
    table.insert(lines, table.concat(links, " | "))
  end
  table.insert(lines, "")
  
  -- Summary section (empty for user to fill)
  table.insert(lines, "** Summary")
  table.insert(lines, "")
  table.insert(lines, "")
  
  -- Annotations section
  table.insert(lines, "** Annotations")
  local annotations_content = format_annotations(annotations, item.key)
  table.insert(lines, annotations_content)
  table.insert(lines, "")
  
  -- Reference metadata section
  table.insert(lines, "** Reference")
  
  if item.key then
    table.insert(lines, string.format("- [[zotero://select/library/items/%s][Open in Zotero Desktop]]", item.key))
  end
  
  if item.url then
    table.insert(lines, string.format("- [[%s][Original URL]]", item.url))
  end
  if item.DOI then
    table.insert(lines, string.format("- DOI: [[https://doi.org/%s][%s]]", item.DOI, item.DOI))
  end
  if item.publicationTitle then
    table.insert(lines, "- Publication: " .. item.publicationTitle)
  end
  if item.volume then table.insert(lines, "- Volume: " .. item.volume) end
  if item.issue then table.insert(lines, "- Issue: " .. item.issue) end
  if item.pages then table.insert(lines, "- Pages: " .. item.pages) end
  
  -- Add tags/keywords
  if item.tags and type(item.tags) == "table" then
    local tag_list = {}
    for _, tag in pairs(item.tags) do
      if tag and type(tag) == "string" and tag ~= "" then
        table.insert(tag_list, tag)
      end
    end
    if #tag_list > 0 then
      table.insert(lines, "- Keywords: " .. table.concat(tag_list, ", "))
    end
  end
  
  return table.concat(lines, "\n")
end

-- Main sync function
function M.sync()
  progress_info("Starting Zotero sync from SQLite database...")
  log_debug("Config: " .. vim.inspect(config))
  
  -- Reset used timestamps
  used_timestamps = {}
  
  -- Connect to databases
  if not database.connect({
    zotero_db_path = config.zotero_db_path,
    better_bibtex_db_path = config.better_bibtex_db_path
  }) then
    progress_error("Failed to connect to Zotero databases")
    return
  end
  
  log_debug("Successfully connected to databases")
  
  -- Get items from database
  local items = database.get_items()
  if not items or #items == 0 then
    progress_error("No items found in database")
    return
  end
  
  progress_info(string.format("Found %d items with citation keys", #items))
  
  -- Ensure output directory exists
  local denote_path = vim.fn.expand(config.denote_silo_path)
  if vim.fn.isdirectory(denote_path) == 0 then
    vim.fn.mkdir(denote_path, "p")
  end
  
  -- Sync statistics
  local stats = {
    created_count = 0,
    skipped_count = 0,
    error_count = 0,
    no_annotations_count = 0,
    start_time = os.time()
  }
  
  -- Process items
  for index, item in ipairs(items) do
    -- Progress update every 10 items
    if index % 10 == 0 or index == #items then
      progress_message(string.format("Processing item %d/%d...", index, #items))
    end
    
    -- Debug: Log item type
    log_debug(string.format("Processing item %d/%d: %s (%s)", index, #items, 
      item.title or "No title", item.itemType))
    
    -- Skip items without titles
    if not item.title or item.title == "" then
      log_debug("Skipping item without title")
      stats.skipped_count = stats.skipped_count + 1
      goto continue
    end
    
    -- Get annotations for this item
    local annotations, err = database.get_annotations(item.key)
    if err then
      log_debug("Error getting annotations: " .. err)
      annotations = {}
    end
    
    -- Skip items without annotations
    if not annotations or type(annotations) ~= "table" or #annotations == 0 then
      log_debug("No annotations found for: " .. item.title)
      stats.no_annotations_count = stats.no_annotations_count + 1
      goto continue
    end
    
    -- Generate file
    local timestamp = parse_date(item.date)
    local timestamp_id, _ = generate_denote_id(timestamp)
    
    local ok, filename = pcall(generate_filename, item, timestamp_id)
    if not ok then
      progress_error("Failed to generate filename for '" .. item.title .. "'")
      stats.error_count = stats.error_count + 1
      goto continue
    end
    
    local filepath = denote_path .. "/" .. filename
    
    -- Skip if file exists
    if vim.fn.filereadable(filepath) == 1 then
      log_debug("File already exists: " .. filename)
      stats.skipped_count = stats.skipped_count + 1
      goto continue
    end
    
    -- Generate and write content
    local ok2, content = pcall(generate_org_content_with_annotations, item, timestamp_id, annotations)
    if not ok2 then
      progress_error("Failed to generate content for '" .. item.title .. "': " .. tostring(content))
      stats.error_count = stats.error_count + 1
      goto continue
    end
    
    local file = io.open(filepath, "w")
    if file then
      file:write(content)
      file:close()
      stats.created_count = stats.created_count + 1
      log_debug("Created: " .. filename)
    else
      progress_error("Failed to write: " .. filename)
      stats.error_count = stats.error_count + 1
    end
    
    ::continue::
  end
  
  -- Show summary
  local elapsed = os.time() - stats.start_time
  local summary = string.format(
    "Sync complete in %ds: %d created, %d skipped, %d without annotations, %d errors",
    elapsed, stats.created_count, stats.skipped_count, stats.no_annotations_count, stats.error_count
  )
  progress_info(summary)
end

-- Setup function
function M.setup(user_config)
  config = vim.tbl_deep_extend("force", config, user_config or {})
  
  log_debug("Setup called with config: " .. vim.inspect(config))
  
  -- Expand paths
  config.zotero_db_path = vim.fn.expand(config.zotero_db_path)
  config.better_bibtex_db_path = vim.fn.expand(config.better_bibtex_db_path)
  config.denote_silo_path = vim.fn.expand(config.denote_silo_path)
  
  -- Create denote silo directory if needed
  if vim.fn.isdirectory(config.denote_silo_path) == 0 then
    log_info("Creating denote silo directory: " .. config.denote_silo_path)
    vim.fn.mkdir(config.denote_silo_path, "p")
  end
  
  log_debug("Setup completed successfully")
  return true
end

-- Enable/disable debug mode
function M.set_debug(enabled)
  config.debug = enabled
  log_info("Debug mode " .. (enabled and "enabled" or "disabled"))
end

return M