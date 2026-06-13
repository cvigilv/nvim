---@module "plugin.zotero-notes.config"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

---@class ZoteroNotes.Configuration
---@field denote_silo_path string
---@field library_json_path string

---@type ZoteroNotes.Configuration
local defaults = {
  denote_silo_path = "~/denote",
  library_json_path = "~/Zotero/better-bibtex/library.json",
}

local M = {}

--- Update defaults with user configuration
---@param opts ZoteroNotes.Configuration User provided configuration table
---@return ZoteroNotes.Configuration opts Updated default configuration table with user configuration
M.update_config = function(opts)
  -- Merge-in user configuration to default configuration
  opts = opts and vim.tbl_deep_extend("force", {}, defaults, opts) or defaults

  -- Validate setup
  vim.validate({
    -- Options
    ["denote_silo_path"] = { opts.denote_silo_path, "string" },
    ["library_json_path"] = { opts.library_json_path, "string" },
  })

  -- Process some options
  opts.library_json_path = vim.fn.expand(opts.library_json_path)
  opts.denote_silo_path = vim.fn.expand(opts.denote_silo_path)

  if vim.fn.isdirectory(opts.denote_silo_path) == 0 then
    vim.fn.mkdir(opts.denote_silo_path, "p")
  end

  return opts
end

return M
