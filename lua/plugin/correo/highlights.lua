---@module "plugin.correo.highlights"
---@author Carlos Vigil-Vásquez
---@license MIT 2026

-- Highlight groups used by the mailbox renderer. All groups are defined with
-- `default = true` so user/colorscheme overrides always win.

local M = {}

--- Define the plugin's highlight groups
---@param opts Correo.Configuration Plugin configuration
M.setup = function(opts)
  local _ = opts -- Reserved for future highlight configuration
  local _groups = {
    CorreoUnread = { link = "DiagnosticInfo" },
    CorreoFlagged = { link = "WarningMsg" },
    CorreoAttachment = { link = "Special" },
    CorreoDate = { link = "Number" },
    CorreoFrom = { link = "Identifier" },
    CorreoSubject = { link = "Normal" },
    CorreoSubjectUnread = { link = "Title" },
    CorreoStaged = { bold = true },
    CorreoStagedLine = { link = "Visual" },
    CorreoListingInfo = { link = "Comment" },
  }
  for _name, _def in pairs(_groups) do
    vim.api.nvim_set_hl(0, _name, vim.tbl_extend("keep", _def, { default = true }))
  end
end

return M
