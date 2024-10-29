---@module "zk.factory"
---@author Carlos Vigil Vásquez
---@license MIT 2024

--- Get look-up table of dates found in notes
---@param directory string|string[]
---@return table
local function get_date_lut(directory)
  -- Get files associated to journal notes
  local pattern = directory .. "/[0-9][0-9][0-9][0-9][0,1][0-9][0-3][0-9][a-zA-Z].md"
  local notes = vim.split(vim.fn.glob(pattern), "\n", { trimempty = true })

  -- Construct lookup table for last note ID per date
  local lut_dates = {}
  for _, notepath in ipairs(notes) do
    -- Get date and note ID from filename
    local date = vim.fn.fnamemodify(notepath, ":t:r"):sub(0, 8)
    local id = vim.fn.fnamemodify(notepath, ":t:r"):sub(9)

    -- Add note ID if not found or update to last note ID
    if not vim.tbl_contains(lut_dates, date) then
      lut_dates[date] = id
    else
      if id > lut_dates[date] then lut_dates[date] = id end
    end
  end

  return lut_dates
end

--- Get the identifier of a note given a date and list of known notes
---@param date string|osdate
---@param lut table
---@return string
local function next_note_id(date, lut)
  if vim.tbl_contains(vim.tbl_keys(lut), date) then
    -- Get byte number of current last note ID
    local charbyte = lut[date]:byte()

    -- Jump from uppercase to lowercase IDs
    if charbyte == 90 then
      charbyte = 48
    elseif charbyte == 122 then
      charbyte = 64
    end

    -- Compute next node ID
    local nextid = string.char(charbyte + 1)

    return nextid
  else
    return "A"
  end
end

--- Return file name of a note given a date and list of known notes
---@param date string|osdate
---@param lut table
---@return string
local function next_note_name(date, lut) return date .. next_note_id(date, lut) end

--- Return file path for the next note given a directory, date and list of known notes
---@param dir any
---@param date string|osdate
---@param lut table
---@return string
local function next_note_path(dir, date, lut)
  return dir .. "/" .. next_note_name(date, lut) .. ".md"
end

local M = {}

--- Creates a new note with associated media directory.
---@param opts Zk.Config User configuration table
M.create_new_note = function(opts)
  -- Get current date to assign as default
  local currentdate = os.date("%Y%m%d", os.time())
  local date = vim.fn.input("Date in YYYYMMDD format: ", currentdate)

  -- Only create a new note if the date pattern is valid
  if string.find(date, "[0-9][0-9][0-9][0-9][0,1][0-9][0-3][0-9]") ~= nil then
    local note_media = opts.media .. "/" .. next_note_name(date, get_date_lut(opts.path))
    pcall(os.execute, "rm -r " .. note_media .. "; mkdir " .. note_media)
    vim.cmd("e " .. next_note_path(opts.media, date, get_date_lut(opts.path)))
  else
    error("Date is in incorrect format!", 1)
  end
end

return M
