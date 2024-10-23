---@module "zk.utils"
---@author Carlos Vigil Vásquez
---@license MIT 2024

local M = {}

---Extracts tags from a given note file.
---@param note string Path to the note file
---@return string|nil title Title of note file
M.get_title = function(note)
  -- Read file content
  local contents = io.open(note, "r"):read("*a")

  if contents ~= nil then
    -- Search title in each line
    for _, line in ipairs(vim.split(contents, "\n", { trimempty = true })) do
      if line ~= "" and string.find(line, "^# ") ~= nil then
        local title = line:gsub("^# ", "")
        return title
      end
    end
  end

  return "Untitled"
end

---Extracts titles from a list of notes files.
---@param opts Zk.Config User config
---@return table tags Tags extracted from files, organized by file path
M.get_all_titles = function(opts)
  -- Get all notes in zettelkasten
  local all_notes = vim.split(vim.fn.glob(opts.path .. "*.md"), "\n", { trimempty = true })

  -- Get tags for each note in zettelaksten
  local all_notes_titles = {}
  for _, note in ipairs(all_notes) do
    all_notes_titles[note] = M.get_title(note)
  end

  return all_notes_titles
end

---Extracts tags from a given note file.
---@param note string Path to the note file
---@return table tags List of extracted tags
M.get_tags = function(note)
  -- Initialize empty tag collector
  local tags = {}

  -- Read file content
  local content = vim.fn.readfile(note)

  -- Search tags in each line
  for _, line in ipairs(content) do
    for tag in line:gmatch("#%w+[/%w+]*") do -- NOTE: this pattern extract #tag/subtag tags
      table.insert(tags, tag)
    end
  end

  return tags
end

---Extracts tags from a list of notes files.
---@param opts Zk.Config User config
---@return table tags Tags extracted from files, organized by file path
M.get_all_tags = function(opts)
  -- Get all notes in zettelkasten
  local all_notes = vim.split(vim.fn.glob(opts.path .. "*.md"), "\n", { trimempty = true })

  -- Get tags for each note in zettelaksten
  local all_note_tags = {}
  for _, note in ipairs(all_notes) do
    if not all_note_tags[note] then all_note_tags[note] = {} end
    table.insert(all_note_tags[note], M.get_tags(note))
  end

  return all_note_tags
end

---Determines the type of a note based on its content.
---@param note string Path to the note file
---@return string|nil type The type of the note ("Journal", "Idea", "Literature", "Map-of-Contents") or nil if no type is found
M.get_type = function(note)
  -- Read file content
  local content = vim.fn.readfile(note)

  -- Search tags in each line
  for _, line in ipairs(content) do
    if line:find("#journal") then
      return "Journal"
    elseif line:find("#idea") then
      return "Idea"
    elseif line:find("#literature") then
      return "Literature"
    elseif line:find("#moc") then
      return "Map-of-Contents"
    end
  end
  return "Invalid type"
end

---Extracts type of all notes in zettelkasten.
---@param opts Zk.Config User config
---@return table all_note_types Types extracted from files, organized by file path
M.get_all_types = function(opts)
  -- Get all notes in zettelkasten
  local all_notes = vim.split(vim.fn.glob(opts.path .. "*.md"), "\n", { trimempty = true })

  -- Get type for each note in zettelaksten
  local all_note_types = {}
  for _, note in ipairs(all_notes) do
    if not all_note_types[note] then all_note_types[note] = {} end
    table.insert(all_note_types[note], M.get_type(note))
  end

  return all_note_types
end

M.get_metadata = function(note)
  return {
    path = note,
    title = M.get_title(note),
    type = M.get_type(note),
    tags = M.get_tags(note),
  }
end

M.get_all_metadatas = function(opts)
  -- Get all notes in zettelkasten
  local all_notes = vim.split(vim.fn.glob(opts.path .. "*.md"), "\n", { trimempty = true })

  -- Get type for each note in zettelaksten
  local all_notes_metadata = {}
  for _, note in ipairs(all_notes) do
    all_notes_metadata[note] = M.get_metadata(note)
  end

  return all_notes_metadata
end

return M
