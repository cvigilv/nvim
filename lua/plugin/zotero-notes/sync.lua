-- Modified from https://github.com/adam-coates/telescope-zotero.nvim/blob/3cdc7ce73b53e55e03e5a0d332764f299647c57b/lua/zotero/init.lua
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
--
--
-- Modifications are licensed under MIT Licensem authored by Carlos Vigil-Vásquez:
-- * Removed all operations related to bib file management on pick
-- * Added logic to Telescope picker to open or create note from reference item
-- * Hardcoded some options to defaults provided in original code

local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local action_state = require("telescope.actions.state")
local actions = require("telescope.actions")
local database = require("plugin.zotero-notes.database")

local M = {}

---Extract year for date entry
---@param date string Date to parse
---@return string year Year of date entry or ' ¿? ' is not found
local function extract_year(date)
  local year = date:match("(%d%d%d%d)")
  if year ~= nil then
    return year
  else
    return " ¿? "
  end
end

---Gets available attachments for Zotero biliography item
---@param item table Zotero bilbiography item
local function get_attachment_options(item)
  local options = {}
  -- Add option to open PDF...
  if item.attachment and item.attachment.path then
    table.insert(options, {
      type = "pdf",
      path = item.attachment.path,
      link_mode = item.attachment.link_mode,
    })
  end
  -- DOI...
  if item.DOI then
    table.insert(options, { type = "doi", url = "https://doi.org/" .. item.DOI })
  end
  -- and option to open entry in Zotero.
  table.insert(options, { type = "zotero", key = item.key })
  return options
end

---Opens URL of Zotero item
---@param url string The URL to open
---@param filetype string|nil Filetype of URL to open (defaults to system's opener program)
local function open_url(url, filetype)
  local open_cmd
  if vim.fn.has("win32") == 1 then
    open_cmd = "start"
  elseif vim.fn.has("macunix") == 1 then
    open_cmd = "open"
  else -- Assume Unix
    open_cmd = "xdg-open"
  end
  vim.notify(
    "[zotero] Opening URL with: " .. open_cmd .. " " .. vim.fn.shellescape(url),
    vim.log.levels.INFO
  )
  vim.fn.jobstart({ open_cmd, url }, { detach = true })
end

---Opens item in Zotero
---@param item_key table The key of the Zotero bibliography item to open
local function open_in_zotero(item_key)
  local zotero_url = "zotero://select/library/items/" .. item_key
  open_url(zotero_url)
end

---Opens attachments for a Zotero bibliography item
---@param item table The Zotero bibliography item containing attachment information
---@param opts ZoteroNotes.Configuration Plugin configuration
local function open_attachment(item, opts)
  local options = get_attachment_options(item)

  local function execute_option(choice)
    if choice.type == "pdf" then
      local file_path = choice.path
      
      -- Handle storage: prefixed paths (legacy support)
      if file_path:match("^storage:") then
        local zotero_storage = vim.fn.expand("~/.Zotero/storage")
        -- Remove the 'storage:' prefix
        file_path = file_path:gsub("^storage:", "")
        -- Use wildcard search for the PDF file in subdirectories
        local search_path = zotero_storage .. "/*/" .. file_path
        local matches = vim.fn.glob(search_path, true, true)
        if #matches > 0 then
          file_path = matches[1]
        else
          vim.notify("[zotero] File not found: " .. search_path, vim.log.levels.ERROR)
          return
        end
      end
      
      -- For full paths from JSON, use wildcard search to find the file
      if not vim.fn.filereadable(file_path) then
        -- Extract filename from path and search using wildcard
        local filename = file_path:match("([^/]+)$") or file_path
        local zotero_storage = vim.fn.expand("~/.Zotero/storage")
        local search_path = zotero_storage .. "/*/" .. filename
        local matches = vim.fn.glob(search_path, true, true)
        if #matches > 0 then
          file_path = matches[1]
        else
          vim.notify("[zotero] File not found: " .. search_path, vim.log.levels.ERROR)
          return
        end
      end
      
      vim.notify("[zotero] Opening PDF: " .. file_path, vim.log.levels.INFO)
      open_url(file_path, "pdf")
    elseif choice.type == "doi" then
      vim.ui.open(choice.url)
    elseif choice.type == "zotero" then
      open_in_zotero(choice.key)
    end
  end

  if #options == 1 then
    -- If there's only one option, execute it immediately
    execute_option(options[1])
  elseif #options > 1 then
    -- If there are multiple options, use ui.select

    vim.ui.select(options, {
      prompt = "Choose action:",
      format_item = function(option)
        if option.type == "pdf" then
          return "Open PDF"
        elseif option.type == "doi" then
          return "Open DOI link"
        elseif option.type == "zotero" then
          return "Open in Zotero"
        end
      end,
    }, execute_option)
  else
    -- If there are no options, notify the user
    vim.notify("[zotero] No attachments or links available for this item", vim.log.levels.INFO)
  end
end

---Telescope picker entry maker
---@param pre_entry table Zotero bibliography item
---@return table entry
local function make_entry(pre_entry)
  -- Process entry
  local creators = pre_entry.creators or {}
  local author = creators[1] or {}
  local last_name = author.lastName or "NA"
  local year = pre_entry.year or pre_entry.date or "NA"
  year = extract_year(year)
  pre_entry.year = year

  -- Check if entry has attachments
  local icon
  local options = get_attachment_options(pre_entry)
  local icon_tbl = { " ", " ", " " }
  for _, entry in ipairs(options) do
    if entry.type == "zotero" then
      icon_tbl[1] = "Z"
    elseif entry.type == "doi" then
      icon_tbl[2] = "D"
    elseif entry.type == "pdf" then
      icon_tbl[3] = "P"
    end
  end
  icon = table.concat(icon_tbl, "")

  -- Create display maker
  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = #icon },
      { width = 24, right_justify = true },
      { remaining = true },
    },
  })

  local function make_display(_)
    return displayer({
      { icon, "SpecialChar" },
      { last_name .. ", " .. year, "Norma" },
      { pre_entry.title, "Comment" },
    })
  end

  -- Return entry maker
  local ordinal = string.format("%s %s %s %s", icon, last_name, year, pre_entry.title)
  return {
    value = pre_entry,
    display = make_display,
    ordinal = ordinal,
  }
end

--- Helper function to get best available annotation link key
---@param annotation table Annotation object with keys
---@return string key Best available key for linking
local function get_annotation_link(annotation)
  if annotation.annotationKey then
    return annotation.annotationKey
  elseif annotation.pdfKey then
    return annotation.pdfKey
  else
    return annotation.parentKey
  end
end

--- Strip HTML tags from text
---@param html string HTML text
---@return string plain Plain text without HTML tags
local function strip_html(html)
  if not html then return "" end
  -- Remove HTML tags
  local plain = html:gsub("<[^>]+>", "")
  -- Decode common HTML entities
  plain = plain:gsub("&nbsp;", " ")
  plain = plain:gsub("&lt;", "<")
  plain = plain:gsub("&gt;", ">")
  plain = plain:gsub("&amp;", "&")
  plain = plain:gsub("&quot;", '"')
  return plain
end

---Creates new note based on selected Zotero bibliography item
---@param entry table Zotero bibliography item
local function create_note(entry, opts)
  -- Extract required information
  local year = entry.value.year
  local author = entry.value.creators[1].lastName
  local title = author .. ", " .. year .. " - " .. entry.value.title
  local item_key = entry.value.key

  -- Generate denote compliant filename
  local timestamp = require("denote.naming").generate_timestamp()
  local components = {
    identifier = timestamp,
    date = require("denote.frontmatter").format_date_field(
      timestamp --[[@as string]],
      require("denote.frontmatter").format_date_org
    ),
    title = title,
    keywords = "",
    signature = "refs",
    extension = ".org",
  }
  local filename = require("denote.naming").generate_filename(components)

  -- Create file content array
  local content = vim.split(
    require("denote.frontmatter").generate_org_frontmatter(components),
    "\n",
    { trimempty = true }
  )
  
  -- Add DOI and citation
  table.insert(content, "#+doi:        " .. (entry.value.DOI or ""))
  table.insert(content, "#+citation:   " .. entry.value.citekey)
  table.insert(content, "")
  table.insert(content, "* " .. title)
  table.insert(content, "")

  -- SECTION 1: Abstract (JSON -> SQLite -> empty)
  table.insert(content, "** Abstract")
  local abstract = entry.value.abstractNote
  if not abstract then
    -- Fallback to SQLite
    local ok, sqlite_abstract = pcall(database.get_abstract_from_sqlite, item_key)
    if ok and sqlite_abstract then
      abstract = sqlite_abstract
    end
  end
  if abstract then
    table.insert(content, abstract)
  end
  table.insert(content, "")

  -- SECTION 2: Summary
  table.insert(content, "** Summary")
  table.insert(content, "")
  table.insert(content, "# here go your notes...")
  table.insert(content, "")

  -- SECTION 3: Annotations
  table.insert(content, "** Annotations")
  table.insert(content, "")
  
  -- Get annotations from SQLite
  local ok_annotations, annotations = pcall(database.get_annotations_from_sqlite, item_key)
  if not ok_annotations then
    vim.api.nvim_echo({
      { "[zotero] Warning: Failed to retrieve annotations", "WarningMsg" }
    }, false, {})
    annotations = {}
  end
  
  -- Get item notes from SQLite
  local ok_notes, item_notes = pcall(database.get_notes_from_sqlite, item_key)
  if not ok_notes then
    vim.api.nvim_echo({
      { "[zotero] Warning: Failed to retrieve item notes", "WarningMsg" }
    }, false, {})
    item_notes = {}
  end
  
  -- Combine and process annotations
  if annotations and #annotations > 0 then
    for _, annot in ipairs(annotations) do
      -- Add highlight in quote block
      if annot.text and annot.text ~= "" then
        table.insert(content, "#+BEGIN_QUOTE")
        table.insert(content, annot.text)
        table.insert(content, "#+END_QUOTE")
        table.insert(content, "")
      end
      
      -- Add comment/note as raw text
      if annot.comment and annot.comment ~= "" then
        table.insert(content, annot.comment)
        table.insert(content, "")
      end
      
      -- Add link
      local link_key = get_annotation_link(annot)
      table.insert(content, "[[zotero://select/library/items/" .. link_key .. "]]")
      table.insert(content, "")
    end
  end
  
  -- Add item notes
  if item_notes and #item_notes > 0 then
    for _, note in ipairs(item_notes) do
      local note_text = strip_html(note.text)
      if note_text and note_text ~= "" then
        table.insert(content, note_text)
        table.insert(content, "")
        table.insert(content, "[[zotero://select/library/items/" .. note.parentKey .. "]]")
        table.insert(content, "")
      end
    end
  end

  -- SECTION 4: Zotero link at bottom
  table.insert(content, "[[zotero://select/library/items/" .. entry.value.key .. "]]")
  table.insert(content, "")

  -- Write file and open
  vim.fn.writefile(content, vim.fs.joinpath(opts.denote_silo_path, filename))
  vim.cmd("e " .. vim.fs.joinpath(opts.denote_silo_path, filename))
  vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(0), 0 })
end

---Processes selected Zotero bibliography item
---@param entry table Zotero bibliography item
local function process_selection(entry, opts)
  -- Convert entry to denote compliant title
  local year = entry.value.year
  local author = entry.value.creators[1].lastName
  local title = author .. ", " .. year .. " - " .. entry.value.title
  local dtitle = require("denote.naming").as_component_string(title, "title") --[[@as string]]

  -- Check if note exists, using year and title, otherwise create
  local notes = vim.fn.glob(opts.denote_silo_path .. "*" .. dtitle .. "*", true, true, true)
  if #notes > 0 then
    vim.cmd("e " .. notes[1])
  else
    create_note(entry, opts)
  end
end

--- Create or open note associated to Zotero entry
function M.picker(opts)
  -- Connect to library
  if
    not database.connect({
      bibtex_library_path = opts.bibtex_library_path,
    })
  then
    error("Failed to connect to Zotero library")
    return
  end

  -- Connect to SQLite database (optional, continue if fails)
  database.connect_sqlite({
    zotero_db_path = opts.zotero_db_path,
  })

  -- Get items from library
  local items = database.get_items()
  if not items or #items == 0 then
    error("No items found in database")
    return
  end

  -- Launch picker
  pickers
    .new(opts.telescope, {
      finder = finders.new_table({
        entry_maker = make_entry,
        prompt_prefix = "[Zotero Notes] ",
        prompt_title = false,
        results = items,
        title = false,
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        -- <CR>: Process selected item
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local entry = action_state.get_selected_entry()
          process_selection(entry, opts)
        end)
        -- o/<C-o>: Open item
        map("i", "<C-o>", function()
          local entry = action_state.get_selected_entry()
          open_attachment(entry.value, opts)
        end)
        map("n", "o", function()
          local entry = action_state.get_selected_entry()
          open_attachment(entry.value, opts)
        end)
        return true
      end,
    })
    :find()
end

return M
