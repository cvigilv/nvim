---@module "spec.personal"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

return {
  { -- diferente
    dir = os.getenv("GITDIR") .. "/diferente.nvim",
    ft = "gitcommit",
    config = true,
  },
  { -- esqueleto
    dir = os.getenv("GITDIR") .. "/esqueleto.nvim",
    enabled = true,
    opts = {
      autouse = false,
      directories = { --[[ @as table ]]
        vim.fn.stdpath("config") .. "/extras/skeletons/protera",
        vim.fn.stdpath("config") .. "/extras/skeletons/personal",
      },
      wildcards = {
        expand = true,
        lookup = {
          -- Denote
          ["denote-title"] = function()
            local Denote = require("denote.internal")
            local filename = vim.api.nvim_buf_get_name(0)
            local fields = Denote.parse_filename(filename, false)
            return "#+TITLE:      " .. (fields.title or "")
          end,
          ["denote-date"] = function()
            local Denote = require("denote.internal")
            local filename = vim.api.nvim_buf_get_name(0)
            local fields = Denote.parse_filename(filename, false)
            return "#+DATE:       " .. (fields.date or "")
          end,
          ["denote-keywords"] = function()
            local Denote = require("denote.internal")
            local filename = vim.api.nvim_buf_get_name(0)
            local fields = Denote.parse_filename(filename, true)
            if fields.keywords ~= nil then
              return "#+FILETAGS:   " .. ":" .. table.concat(fields.keywords, ":") .. ":"
            end
            return "#+FILETAGS:   "
          end,
          ["denote-signature"] = function()
            local Denote = require("denote.internal")
            local filename = vim.api.nvim_buf_get_name(0)
            local fields = Denote.parse_filename(filename, false)
            return "#+SIGNATURE:  " .. (fields.signature or "")
          end,
          ["denote-identifier"] = function()
            local Denote = require("denote.internal")
            local filename = vim.api.nvim_buf_get_name(0)
            local fields = Denote.parse_filename(filename, false)
            return "#+IDENTIFIER: " .. fields.identifier
          end,

          -- GitHub
          ["gh-username"] = "cvigilv",
          ["gh-root"] = function()
            -- Get the full path of the current buffer
            local buffer_path = vim.api.nvim_buf_get_name(0)

            -- If the buffer has no path (e.g., a new unsaved buffer), return nil
            if buffer_path == "" then return nil end

            -- Get the directory of the current buffer
            local buffer_dir = vim.fn.fnamemodify(buffer_path, ":h")

            -- Use vim.fn.systemlist to run the git command
            local git_root = vim.fn.systemlist(
              "git -C " .. vim.fn.shellescape(buffer_dir) .. " rev-parse --show-toplevel"
            )[1]

            -- Check if the command was successful
            if vim.v.shell_error ~= 0 then return nil end

            -- Return the git root directory
            return vim.fn.fnamemodify(git_root, ":t")
          end,

          -- Zettelkasten
          ["zk-year"] = function() return string.sub(vim.fn.expand("%:t:r"), 1, 4) end,
          ["zk-month"] = function() return string.sub(vim.fn.expand("%:t:r"), 5, 6) end,
          ["zk-day"] = function() return string.sub(vim.fn.expand("%:t:r"), 7, 8) end,

          -- Lua
          ["lua-module-modname"] = function()
            -- Get full path of the current buffer and split it into parts
            local buffer_path = vim.fn.expand("%:p:r")
            local path_components =
              vim.split(buffer_path, "/", { trimempty = true, plain = true })

            -- Find the last index of "lua" in the path
            local lua_root_index = nil
            for i = #path_components, 1, -1 do -- HINT: this iterates over the table in reverse order
              if path_components[i] == "lua" then
                lua_root_index = i
                break
              end
            end

            -- If "lua" is not found in the path, display an error and return an empty string
            if not lua_root_index then
              vim.api.nvim_echo({
                { "Error", "[esqueleto.nvim]" },
                { "Normal", "Could not resolve module string for current buffer." },
              }, true, {})

              return ""
            end

            -- Create a new table with path components after the last "lua" instance
            local module_components = {}
            for i = lua_root_index + 1, #path_components do
              if path_components[i] ~= "init" then
                table.insert(module_components, path_components[i])
              end
            end

            -- Join the module components with dots to form the module string
            return table.concat(module_components, ".")
          end,
          ["lua-module-name"] = function()
            -- Get full path of the current buffer and split it into parts
            local buffer_path = vim.fn.expand("%:p:r")
            local path_components =
              vim.split(buffer_path, "/", { trimempty = true, plain = true })

            -- Find the last index of "lua" in the path
            local lua_root_index = nil
            for i = #path_components, 1, -1 do -- HINT: this iterates over the table in reverse order
              if path_components[i] == "lua" then
                lua_root_index = i
                break
              end
            end

            -- Return the path component found before "lua"
            return string.gsub(
              path_components[lua_root_index + 1],
              "(%a)([%w']*)",
              function(first, rest) return string.upper(first) .. rest end
            )
          end,
        },
      },
      advanced = {
        ignored = {},
        ignore_os_files = true,
        ignore_patterns = { "^/tmp", "Luapad.lua$", "Claudio", "^/var" },
      },
    },
  },
}
