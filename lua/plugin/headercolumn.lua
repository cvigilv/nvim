---@module "plugin.headercolumn"
---@author Carlos Vigil-Vásquez
---@license MIT 2025
-- A small plugin to put header characters on the statuscolumn

local M = {}

---Pad string to left
---@param s string String to pad
---@param l number String length
---@param c string Character to pad with, defaults to space
local function lpad(s, l, c) return string.rep(c or " ", l - #s) .. s end

--- Per-filetype configuration. `node` is the Treesitter container node for a
--- heading; its first child (anonymous-inclusive) is always the marker, whose
--- text length gives the heading level. `hl` is a `string.format` template
--- taking that level.
local configs = {
  org = { node = "headline", hl = "@org.headline.level%d" },
  markdown = { node = "atx_heading", hl = "@markup.heading.%d.markdown" },
  typst = { node = "heading", hl = "@markup.heading.%d.typst" },
}

--- NOTE: the objective of this custom status line is so we can partially conceal the heading markers,
--- such that the markers are placed in the status column, making them stay aligned with the rest of
--- the text.

--- Find the heading marker node covering buffer line `lrow` (0-indexed), if any.
--- Looks up the node spanning the first column of the line, then walks up until
--- the filetype's heading container is found, returning its marker child.
---
--- NOTE: a one-column-wide range `(lrow, 0, lrow, 1)` is used deliberately —
--- `vim.treesitter.get_node` (named-descendant, empty range) misses headings on
--- the very first line for some grammars (e.g. typst).
---@return TSNode? marker
local function heading_marker(bufnr, lrow, cfg, ft)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, ft)
  if not ok or not parser then return nil end
  local tree = parser:parse()[1]
  if not tree then return nil end
  local node = tree:root():descendant_for_range(lrow, 0, lrow, 1)
  while node and node:type() ~= cfg.node do
    node = node:parent()
  end
  if not node then return nil end
  return node:child(0)
end

--- Resolve a highlight group, falling back to the non-suffixed Treesitter group
--- if the filetype-specific one is not defined.
local function resolve_hl(template, level)
  local group = template:format(level)
  if vim.fn.hlexists(group) == 1 then return group end
  return ("@markup.heading.%d"):format(level)
end

--- Render the status-column cell for a single line.
local function header_count(bufnr, ft, lrow, cfg, maxwidth)
  local marker = heading_marker(bufnr, lrow, cfg, ft)
  if marker then
    local text = vim.treesitter.get_node_text(marker, bufnr)
    local level = #text
    return "%#" .. resolve_hl(cfg.hl, level) .. "#" .. lpad(text, maxwidth - 1, " ") .. "%*"
  end
  return string.rep(" ", maxwidth)
end

function M.setup(width)
  local cfg = configs[vim.bo.filetype]
  if not cfg then return end

  local ns_id = vim.api.nvim_create_namespace("headercolumn")
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)

  -- Conceal heading markers (and the following space) so they only show in the
  -- status column. Detection is Treesitter-based, so markers inside code blocks
  -- or other non-heading contexts are left untouched.
  local function add_conceal(bufnr)
    local ft = vim.bo[bufnr].filetype
    local c = configs[ft]
    if not c then return end
    vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

    local ok, parser = pcall(vim.treesitter.get_parser, bufnr, ft)
    if not ok or not parser then return end
    local tree = parser:parse()[1]
    if not tree then return end

    local query = vim.treesitter.query.parse(ft, ("(%s) @heading"):format(c.node))
    for _, node in query:iter_captures(tree:root(), bufnr, 0, -1) do
      local marker = node:child(0)
      if marker then
        local srow, scol, _, ecol = marker:range()
        local line = vim.api.nvim_buf_get_lines(bufnr, srow, srow + 1, false)[1] or ""
        vim.api.nvim_buf_set_extmark(bufnr, ns_id, srow, scol, {
          end_row = srow,
          end_col = math.min(ecol + 1, #line),
          conceal = "",
        })
      end
    end
  end

  -- Initial conceal
  add_conceal(0)

  -- Update conceal on buffer change
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    buffer = 0,
    callback = function() add_conceal(0) end,
  })

  -- Set statuscolumn
  _G.headercolumn_stc = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.bo[bufnr].filetype
    local c = configs[ft]
    if not c then return "" end

    local components = {
      " ",
      header_count(bufnr, ft, vim.v.lnum - 1, c, width - 2),
      " ",
    }

    return table.concat(components, "")
  end

  vim.api.nvim_set_option_value(
    "statuscolumn",
    "%{%v:lua.headercolumn_stc()%}",
    { scope = "local" }
  )
end

return M
