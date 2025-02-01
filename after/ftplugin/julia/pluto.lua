---@module "after.ftplugin.julia.pluto"
---@author Carlos Vigil-Vásquez
---@license MIT 2025

local S = require("carlos.helpers.string")
local T = require("carlos.helpers.treesiter")

-- Functions {{{1
-- Combine adjacent elements in a table based on a mapping {{{2
local function merge_contiguous_cells(tbl, mapper)
  local merged_tbl = {}
  local current_key = nil
  local current_values = {}

  for idx, lines in pairs(tbl) do
    if mapper[idx] then
      if current_key then
        -- Append lines to the existing cell
        vim.list_extend(current_values, lines)
      else
        -- Initialize a new cell
        current_key = idx
        current_values = vim.deepcopy(lines)
      end
    else
      if current_key then
        -- Finalize the current cell and add it to the result
        merged_tbl[current_key] = current_values
        current_key = nil
        current_values = {}
      end
      -- Include non-mapped cell as-is
      merged_tbl[idx] = lines
    end
  end

  -- Handle any remaining open cell
  if current_key then merged_tbl[current_key] = current_values end

  -- Reset numbering and return merged table
  return vim.iter(merged_tbl):totable()
end

-- Convert Pluto notebook into Literate.jl script {{{2
local function pluto2literate()
  -- Constants
  local mdblock_query = [[
    (prefixed_string_literal
      prefix: (identifier)
      (#eq? identifier "md")
      (content) @pluto.mdblock.contents
    )
  ]]

  -- Get current buffer contents
  local bufnr = vim.api.nvim_get_current_buf()
  local contents = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Check if buffer is a Pluto notebook
  if contents[1] ~= "### A Pluto.jl notebook ###" then return false end

  -- Assign contents to cells, removing last cell (Pluto's "Cell order", not used)
  local current_cell = 0
  local cells = {}
  for _, line in ipairs(contents) do
    if vim.startswith(line, "# ╔═╡") then
      current_cell = current_cell + 1
      cells[current_cell] = {}
    elseif current_cell > 0 and line ~= "" then
      table.insert(cells[current_cell], line)
    end
  end
  table.remove(cells)

  -- Combine Markdown blocks
  local cell_with_mdblocks = {}
  for idx, lines in pairs(cells) do
    cell_with_mdblocks[idx] =
      T.lines_contains_capture(lines, "pluto.mdblock.contents", mdblock_query, "julia")
  end
  cells = merge_contiguous_cells(cells, cell_with_mdblocks)

  -- Parse cells and processes them
  for idx, lines in pairs(cells) do
    -- Handle Pluto Markdown blocks
    if T.lines_contains_capture(lines, "pluto.mdblock.contents", mdblock_query, "julia") then
      -- Remove double tick escape sequences (fricking Julia and it's ticks for diferent types)
      vim.print(lines)
      lines = vim
        .iter(lines)
        :map(function(l)
          if l:match("^md\"\"\".*\"\"\"$") or l == "md\"\"\"" then
            return l -- Return the line unchanged
          end

          return ((l:gsub("\\\"", "\"")):gsub("^md\"(.+)\"$", "md\"\"\"%1\"\"\""))
        end)
        :totable()
      vim.print(lines)
      local mdblock =
        T.get_capture_contents(lines, "pluto.mdblock.contents", mdblock_query, "julia")

      -- Format buffer
      local format_buf = vim.api.nvim_create_buf(false, true)
      ---@diagnostic disable-next-line: param-type-mismatch
      vim.api.nvim_buf_set_lines(format_buf, 0, -1, false, mdblock)
      vim.api.nvim_set_option_value("filetype", "markdown", { buf = format_buf })

      local ok, conform = pcall(require, "conform")
      if ok then
        local formatted = conform.format({ bufnr = format_buf, quiet = true })
        if formatted then
          vim.api.nvim_buf_call(format_buf, function()
            vim.cmd("set tw=88")
            vim.cmd("normal! gggqG")
          end)
          mdblock = vim.api.nvim_buf_get_lines(format_buf, 0, -1, false)
        end
      end

      ---@diagnostic disable-next-line: param-type-mismatch
      cells[idx] = vim.tbl_map(function(c) return "# " .. c end, mdblock)

    -- Remove begin/end keywords
    elseif vim.iter(lines):any(function(v) return v:find("^begin") or v:find("^end") end) then
      cells[idx] = S.dedent_lines(
        vim
          .iter(lines)
          :filter(function(v) return not (v:find("^begin") or v:find("^end")) end)
          :totable()
      )

    -- Delete cell if related to package management
    elseif vim.startswith(lines[1], "PLUTO") then
      cells[idx] = nil
    end
  end

  -- Last bit of processing
  local lines = vim
    .iter(cells)
    -- Add spacing between cells
    :map(function(lines)
      local padded_lines = vim.deepcopy(lines)
      table.insert(padded_lines, "")
      return padded_lines
    end)
    -- Flatten cells into iterator of lines
    :flatten()
    -- Filter out remaining Pluto-esque lines
    :filter(
      function(l)
        return not (
          vim.startswith(l, "# ╠")
          or vim.startswith(l, "# ╔")
          or (string.find(l, "Pluto") and not string.find(l, "@bind"))
        )
      end
    )
    -- Convert into table
    :totable()

  -- Handle @bind macro by adding boilerplate
  if vim.iter(cells):flatten():any(function(l) return l:find("@bind") end) then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
      "# Mock version of @bind that gives bound variables a default value (instead of an error).",
      "macro bind(def, element)",
      "    return quote",
      "        local iv = try",
      "        Base.loaded_modules[Base.PkgId(Base.UUID(\"6e696c72-6542-2067-7265-42206c756150\"), \"AbstractPlutoDingetjes\")].Bonds.initial_value",
      "        catch",
      "            b -> missing",
      "        end",
      "        local el = $(esc(element))",
      "        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)",
      "        el",
      "    end",
      "end",
      "",
    })
  else
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
  end

  -- Put contents in buffer
  vim.api.nvim_buf_set_lines(bufnr, vim.api.nvim_buf_line_count(0), -1, false, lines)

  -- Format buffer
  local ok, conform = pcall(require, "conform")
  if ok then conform.format({ bufnr = 0, quiet = true }) end

  return true
end

-- Ex-Commands {{{1
vim.api.nvim_create_user_command("Pluto2Literate", pluto2literate, {
  desc = "Converts Pluto notebook into Literate.jl compliant script",
})
