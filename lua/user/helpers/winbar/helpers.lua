---@module "user.winbar.helpers"
---@author Carlos Vigil-Vásquez
---@license MIT

M = {}

-- Setup custom colors for statusline
M.setup_winbar_hlgroups = function()
  local function overrider()
    local hc = require("user.helpers.colors")

    local hlgroups = {
      WinBarOOB = {
        fg = hc.get_hlgroup_table("Normal").fg,
        bg = hc.get_hlgroup_table("TabLineFill").bg,
      },
      WinBarOOBBold = {
        fg = hc.get_hlgroup_table("Normal").fg,
        bg = hc.get_hlgroup_table("TabLineFill").bg,
        bold = true,
      },
      WinBarOOBNC = {
        fg = hc.get_hlgroup_table("Comment").fg,
        bg = hc.get_hlgroup_table("TabLineFill").bg,
      },
      WinBarOOBNCBold = {
        fg = hc.get_hlgroup_table("Comment").fg,
        bg = hc.get_hlgroup_table("TabLineFill").bg,
      },
      WinBarCaps = {
        fg = hc.get_hlgroup_table("WinBar").bg,
        bg = hc.get_hlgroup_table("TabLineFill").bg,
      },
    }

    hc.override_hlgroups(hlgroups)
  end

  overrider()

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("user::ui", { clear = false }),
    pattern = "*",
    callback = overrider,
  })
end

return M
