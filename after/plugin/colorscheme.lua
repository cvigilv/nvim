---@module "after.plugin.colorscheme"
---@author Carlos Vigil-Vásquez
---@license MIT 2024-2025

local files = require("user.helpers.files")

-- Colorscheme overrides {{{
-- TODO: Replace this autocommand for custom version of colorscheme (`tempano` foreshadowing...)
local augroup_overrides =
  vim.api.nvim_create_augroup("carlos::colorscheme::overrides", { clear = true })
vim.api.nvim_create_autocmd("Colorscheme", {
  pattern = "iceberg",
  group = augroup_overrides,
  callback = function()
    if vim.api.nvim_get_option_value("bg", { scope = "global" }) == "light" then
      local hc = require("user.helpers.colors")

      -- Overrides
      local alloverrides = {
        -- Diff
        Added = { fg = "#005000", bg = "#ccefcf" },
        DiffAdd = { link = "Added" },
        GitGutterAdd = { link = "Added" },
        Changed = { bg = "#ffe5b9", fg = "#553d00" },
        DiffChange = { link = "Changed" },
        GitGutterChanged = { link = "Changed" },
        DiffText = { bg = "#ffd09f", fg = "#553d00", italic = true },
        Removed = { fg = "#8f1313", bg = "#ffd4d8" },
        DiffDelete = { link = "Removed" },
        GitGutterDelete = { link = "Removed" },
        -- UI
        WinBar = { bg = "#ffffff", fg = hc.get_hlgroup_table("StatusLine").bg },
        WinBarNC = { bg = "#ffffff", fg = hc.get_hlgroup_table("StatusLine").bg },
        StatusLine = hc.get_hlgroup_table("StatusLineNC"),
        TabLineFill = { bg = "#ffffff" },
        MsgArea = { bg = "#ffffff", fg = "#000000" },
        Type = hc.get_hlgroup_table("TabLine"),
      }
      hc.override_hlgroups(alloverrides)

      -- Modifications
      local allchanges = {
        ColorColumn = { link = "CursorLine" },
        TabLineSel = { bold = true },
        Keyword = { italic = true },
        Folded = { link = "Comment" },
        WinBar = { link = "Normal" },
        WinBarNC = { link = "Normal" },
        EndOfBuffer = { link = "CursorLine" },
        StatusLine = { bold = true },
        LineNr = { bold = true },
        Whitespace = { italic = true },
        WinSeparator = { link = "Comment" },
        NonText = { fg = hc.get_hlgroup_table("Comment").fg, italic = true },
        NormalFloat = { bg = "#ffffff" },
      }
      for hlgroup, overrides in pairs(allchanges) do
        hc.modify_hlgroup(hlgroup, overrides)
      end
    end
  end,
})
-- }}}

-- NOTE: This is version 0. This just syncs iceberg light and dark variants. Eventually, I
-- would like to synchronize the colorscheme by computing a custom colorscheme based on the
-- Normal highlight group using color blending.
-- Logic:
-- - On startup, read current colorscheme combination and load
-- - If colorscheme is changed, save current combination
-- - If background is changed, save current combination

-- Set current theme
local theme_file = vim.fn.stdpath("config") .. "/extras/theme"
local loaded_theme, theme = pcall(files.safe_read, theme_file)

local theme_colorscheme
local theme_background
if loaded_theme then
  ---@diagnostic disable-next-line: cast-local-type
  theme = vim.split(theme --[[@as string]], "\n", {})
  theme_colorscheme = theme[1]
  theme_background = theme[2]
else
  theme_colorscheme = "default"
  theme_background = "light"
end

vim.o.background = theme_background
vim.cmd.colorscheme(theme_colorscheme)

-- Autocommands for syncing theme with tmux and WezTerm
local augroup_sync = vim.api.nvim_create_augroup("carlos::colorscheme::sync", { clear = true })

---Synchronizes theme settings across Neovim, Wezterm, and Tmux.
---@param colorscheme string|nil The colorscheme to be set
---@param background string|nil The background setting (e.g., "light" or "dark")
local function synchronize_theme(colorscheme, background)
  colorscheme = colorscheme or vim.g.colors_name
  background = background or vim.api.nvim_get_option_value("bg", { scope = "global" })

  -- Neovim
  local nvim_theme = vim.fn.stdpath("config") .. "/extras/theme"
  files.safe_write(nvim_theme, { colorscheme, background }, "w")

  -- Wezterm
  local wezterm_theme = vim.fn.expand("$HOME/.config/wezterm/colorscheme")
  files.safe_write(wezterm_theme, { colorscheme, background }, "w")

  -- Tmux
  vim.cmd("silent !tmux source $HOME/.config/tmux/tmux_" .. background .. ".conf")
end

-- Sync on `colorscheme` change
vim.api.nvim_create_autocmd(
  "ColorScheme",
  { group = augroup_sync, pattern = "*", callback = function() synchronize_theme() end }
)

-- Sync on `background` change
vim.api.nvim_create_autocmd("OptionSet", {
  group = augroup_sync,
  pattern = "background",
  callback = function() synchronize_theme() end,
})
