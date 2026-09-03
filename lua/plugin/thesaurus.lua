---@module "plugin.thesaurus"
---@author Carlos Vigil-Vásquez
---@license MIT 2026
-- MyThes-backed completion for Neovim's built-in thesaurus interface

local M = {}

local indexes = {}
local warned = false

local function lowercase(word) return vim.fn.tolower(word) end

local language_patterns = {
  { "th_en_US_v2.dat", "th_en_US.dat", "th_en_US*.dat" },
  {
    "th_es_MX_v2.dat",
    "th_es_MX.dat",
    "th_es_AR_v2.dat",
    "th_es_AR.dat",
    "th_es_ES_v2.dat",
    "th_es_ES.dat",
    "th_es_*.dat",
  },
}

local function search_paths()
  local paths = {
    vim.fn.expand("~/.local/share/mythes"),
    vim.fn.expand("~/.nix-profile/share/mythes"),
    "/etc/profiles/per-user/" .. (vim.env.USER or "") .. "/share/mythes",
    "/run/current-system/sw/share/mythes",
    "/opt/homebrew/share/mythes",
    "/usr/local/share/mythes",
    "/usr/share/mythes",
    "/usr/lib/libreoffice/share/extensions",
    "/opt/libreoffice/share/extensions",
    "/run/current-system/sw/lib/libreoffice/share/extensions",
    "/Applications/LibreOffice.app/Contents/Resources/extensions",
  }
  if vim.env.MYTHES_PATH then
    vim.list_extend(paths, vim.split(vim.env.MYTHES_PATH, ":", { trimempty = true }))
  end
  return paths
end

local function find_thesauri()
  local found = {}
  for _, patterns in ipairs(language_patterns) do
    local match
    for _, root in ipairs(search_paths()) do
      if vim.fn.isdirectory(root) == 1 then
        for _, pattern in ipairs(patterns) do
          local candidates = vim.fn.glob(root .. "/" .. pattern, false, true)
          if #candidates == 0 and root:lower():find("libreoffice", 1, true) then
            candidates = vim.fn.glob(root .. "/**/" .. pattern, false, true)
          end
          if #candidates > 0 then
            table.sort(candidates)
            match = candidates[1]
            break
          end
        end
      end
      if match then break end
    end
    if match then table.insert(found, match) end
  end
  return found
end

local function index_for(dat_path)
  if indexes[dat_path] then return indexes[dat_path] end

  local index = {}
  local idx_path = vim.fn.fnamemodify(dat_path, ":r") .. ".idx"
  local file = io.open(idx_path, "r")
  if not file then
    indexes[dat_path] = index
    return index
  end

  file:read("*l")
  file:read("*l")
  for line in file:lines() do
    local term, offset = line:match("^(.-)|(%d+)$")
    if term and offset then index[lowercase(term)] = tonumber(offset) end
  end
  file:close()
  indexes[dat_path] = index
  return index
end

local function preserve_case(word, base)
  local first = vim.fn.strcharpart(base, 0, 1)
  if first ~= lowercase(first) then
    return vim.fn.toupper(vim.fn.strcharpart(word, 0, 1)) .. vim.fn.strcharpart(word, 1)
  end
  return word
end

local function lookup(dat_path, base)
  local offset = index_for(dat_path)[lowercase(base)]
  if not offset then return {} end

  local file = io.open(dat_path, "r")
  if not file then return {} end
  file:seek("set", offset)

  local count = tonumber((file:read("*l") or ""):match("|(%d+)$")) or 0
  local items = {}
  for _ = 1, count do
    local fields = vim.split(file:read("*l") or "", "|", { plain = true, trimempty = true })
    local kind = table.remove(fields, 1)
    for _, synonym in ipairs(fields) do
      local word = vim.trim(synonym:gsub("%s*%b()", ""):gsub("%s+", " "))
      if word ~= "" and lowercase(word) ~= lowercase(base) then
        table.insert(items, {
          word = preserve_case(word, base),
          abbr = synonym,
          menu = kind ~= "-" and (kind:match("^%((.+)%)$") or kind) or nil,
        })
      end
    end
  end
  file:close()
  return items
end

---Complete synonyms through |i_CTRL-X_CTRL-T|.
---@param findstart 0|1
---@param base string
---@return integer|table
function M.complete(findstart, base)
  if findstart == 1 then
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    return vim.fn.match(line:sub(1, col), [[\k*$]])
  end

  local paths = vim.opt_local.thesaurus:get()
  if #paths == 0 then
    if not warned then
      warned = true
      vim.notify("No MyThes en_US or Spanish dictionaries found", vim.log.levels.WARN)
    end
    return {}
  end

  local seen = {}
  local items = {}
  for _, path in ipairs(paths) do
    for _, item in ipairs(lookup(path, base)) do
      local key = lowercase(item.word)
      if not seen[key] then
        seen[key] = true
        table.insert(items, item)
      end
    end
  end
  return items
end

---Configure thesaurus completion for the current buffer.
function M.setup_buffer()
  vim.opt_local.thesaurus = find_thesauri()
  vim.opt_local.thesaurusfunc = "v:lua.require'plugin.thesaurus'.complete"
end

return M
