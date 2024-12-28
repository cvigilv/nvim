---@module "plugin.afuera.helpers"
---@author Carlos Vigil-Vásquez
---@license MIT 2024

local log = require("plugin.afuera.log").new({}, true)

local afuera_nr = vim.api.nvim_create_namespace("afuera")

---Sets or modifies the winhighlight option for a given window.
---@param winnr number The window number to modify
---@param add string|nil The highlight group to add
---@param remove string|nil The highlight group to remove
local function set_winhighlight(winnr, add, remove)
  -- Get current winhighlight
  local current_winhighlight = vim.api.nvim_get_option_value("winhighlight", { win = winnr })
  if current_winhighlight == "" then
    current_winhighlight = {}
  else
    current_winhighlight = vim.split(current_winhighlight, ",")
  end
  log.info("winhighlight = " .. table.concat(current_winhighlight, ","))

  -- Modify winhighlight option
  add = add or ""
  remove = remove or ""
  local winhighlight = table.concat(
    vim
      .iter({ current_winhighlight, { add } })
      :flatten()
      :filter(function(v) return v ~= remove end)
      :filter(function(v) return v ~= "" end)
      :fold({}, function(acc, k, _)
        if not vim.tbl_contains(acc, k, {}) then table.insert(acc, k) end
        return acc
      end),
    ","
  )
  vim.api.nvim_set_option_value("winhighlight", winhighlight, { scope = "local", win = winnr })
  log.info(
    "new winhighlight = "
      .. tostring(vim.api.nvim_get_option_value("winhighlight", { win = winnr }))
  )
end

--- Set the colorcolumn value for the given window
---@param winnr number Window number
---@param value string colorcolumn value
local function set_colorcolumn(winnr, value)
  local opts = { scope = "local", win = winnr }
  log.info("colorcolumn = " .. vim.api.nvim_get_option_value("colorcolumn", opts))
  vim.api.nvim_set_option_value("colorcolumn", value, opts)
  log.info("new colorcolumn = " .. vim.api.nvim_get_option_value("colorcolumn", opts))
end

--- Set characters highlight for a given window
---@param winnr number Window number
---@param on boolean Whether the highlight is on
---@param start? number Horizontal OOB region first column
local function set_highlight(winnr, on, start, opts)
  if on then
    log.info("Added OOB character highlight")
    pcall(
      vim.fn.matchadd,
      opts.oob_char_hl,
      "\\%>" .. start - 1 .. "v.",
      10,
      afuera_nr,
      { window = winnr }
    )
  else
    log.info("Removed OOB character highlight")
    pcall(vim.fn.matchdelete, afuera_nr, winnr)
  end
end

local M = {}

M.activate_oob_mode = function(winnr, opts)
  log.info("Activating OOB mode in winnr=" .. winnr)

  -- Activate horizontal OOB highlight
  local colorcolumn_start = tonumber(opts.defaults.colorcolumn) or 96
  set_colorcolumn(winnr, table.concat(vim.fn.range(colorcolumn_start, 256), ","))
  set_highlight(winnr, true, colorcolumn_start, opts)

  -- Activate vertical OOB highlight
  set_winhighlight(winnr, "EndOfBuffer:ColorColumn", "EndOfBuffer:Normal")
end

M.deactivate_oob_mode = function(winnr, opts)
  log.info("Deactivating OOB mode in winnr=" .. winnr)

  -- Deactivate horizontal OOB highlight
  set_colorcolumn(winnr, tostring(opts.defaults.colorcolumn))
  set_highlight(winnr, false, nil, opts)

  -- Deactivate vertical OOB highlight
  set_winhighlight(winnr, "EndOfBuffer:Normal", "EndOfBuffer:ColorColumn")
end

---Sets the out-of-buffer (OOB) mode for a specific buffer and window.
---@param bufnr number|string Buffer number
---@param winnr number Window number
---@param opts table Options table containing state information
---@see M.activate_oob_mode
---@see M.deactivate_oob_mode
function M.set_oob_mode(bufnr, winnr, opts)
  log.info(string.format("Setting OOB mode for buffer %d, window %d", bufnr, winnr))
  log.info(string.format("Current state: %s", tostring(opts.state[tostring(bufnr)])))

  if opts.state[tostring(bufnr)] then
    M.activate_oob_mode(winnr, opts)
  else
    M.deactivate_oob_mode(winnr, opts)
  end

  log.info("OOB mode set successfully")
end

return M
