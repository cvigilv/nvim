---@module "plugin.org-contact.core"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local A = require("orgmode.api")

local M = {}

M.get_nickname_heading = function(nickname)
  local contacts = A.load("/Users/carlos/org/contacts.org")
  for _, c in ipairs(contacts.headlines) do
    if c.properties.nickname == nickname then
      return c
    end
  end
  return nil
end

M.update_references = function(bufnr)
  -- Open contacts file
  local contacts_buf = vim.fn.bufadd("/Users/carlos/org/contacts.org")
  vim.fn.bufload(contacts_buf)

  -- Load input buffer as org file
  local org = A.load(vim.api.nvim_buf_get_name(bufnr))

  -- Iterate over lines looking for contact prefixes
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for i, line in ipairs(lines) do
    for match in string.gmatch(line, "@%a+[.]?%a+") do
      local heading = M.get_nickname_heading(match:gsub("^@", ""))
      if heading then
        local entries = vim.api.nvim_buf_get_lines(
          contacts_buf,
          heading.position.start_line,
          heading.position.end_line,
          true
        )
        local link = "- [[" .. org.filename .. "::" .. i .. "]]"

        if not vim.tbl_contains(entries, link) then
          local endline = heading.position.end_line
          vim.api.nvim_buf_set_lines(contacts_buf, endline - 1, endline - 1, true, { link })
          vim.api.nvim_buf_call(contacts_buf, function()
            vim.cmd("undojoin")
            vim.cmd("w")
          end)
        end
      end
    end
  end
end

return M
