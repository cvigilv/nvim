---@module 'lib.jetls'
---@author Carlos Vigil-Vásquez
---@license MIT 2026

--- `jetls check` runs JETLS's diagnostics over a file from the command line, with
--- no language server involved. It is the cheap way to get JET's analysis of a
--- single file: the process exits once the check is done, instead of staying
--- resident the way the `jetls` server does.

local M = {}

--- Quickfix `type` for each severity `jetls check` tags its diagnostics with.
local SEVERITY_TYPES = { error = "E", warn = "W", info = "I", hint = "N" }

--- Files marking the directory `jetls check` resolves its relative paths against,
--- and where it looks for `Project.toml` and `.JETLSConfig.toml`.
local ROOT_MARKERS = { "Project.toml", "JuliaProject.toml" }

--- `jetls` colors its output even when stdout is a pipe, so the SGR escapes have
--- to come off before anything can be matched.
---@param line string
---@return string
local function uncolor(line) return (line:gsub("\27%[[%d;]*m", "")) end

--- Version of the `julia` on `$PATH`, as `major.minor`, which names the binary.
---@return string|nil
local function julia_minor()
  local julia = vim.fn.exepath("julia")
  if julia == "" then return nil end
  local out = vim.system({ julia, "--version" }, { text = true }):wait()
  if out.code ~= 0 then return nil end
  local major, minor = (out.stdout or ""):match("(%d+)%.(%d+)%.%d+")
  if not major then return nil end
  return major .. "." .. minor
end

--- The `jetls` executable, preferring the native `jetls-<major>.<minor>` build
--- matching the Julia on `$PATH` over the `jetls` app, which loads JETLS.jl from
--- source on every run.
---@return string|nil
M.executable = function()
  local minor = julia_minor()
  local native = minor and vim.fn.exepath("jetls-" .. minor) or ""
  if native ~= "" then return native end
  local app = vim.fn.exepath("jetls")
  return app ~= "" and app or nil
end

--- Turn `jetls check` output into quickfix items.
---
--- Each diagnostic is printed as a `# @ <path>:<line>,<column>` header, the source
--- excerpt, and an annotation line carrying the message after a `──` separator,
--- ending in `[<severity>]` or `[<severity>:<code>]`. Paths are relative to `root`.
---@param output string
---@param root string
---@return table[] items
M.parse = function(output, root)
  local items = {}
  local position = nil

  for raw in vim.gsplit(output, "\n", { plain = true }) do
    local line = uncolor(raw)
    local path, lnum, col = line:match("^# @ (.+):(%d+),(%d+)%s*$")
    if path then
      position = {
        filename = vim.fs.joinpath(root, path),
        lnum = tonumber(lnum),
        col = tonumber(col),
      }
    elseif position then
      -- The leading `.*` is greedy, so a `──` occurring in the highlighted source
      -- cannot be mistaken for the annotation's own separator. Requiring a known
      -- severity in the trailing tag keeps source text out of the results.
      local note = line:match(".*──%s+(.+)$")
      local message, tag = (note or ""):match("^(.-)%s*%[([^%]]+)%]$")
      local severity, code = (tag or ""):match("^(%a+):(.+)$")
      severity = severity or tag
      if message and SEVERITY_TYPES[severity] then
        items[#items + 1] = vim.tbl_extend("error", position, {
          type = SEVERITY_TYPES[severity],
          text = code and ("%s [%s]"):format(message, code) or message,
        })
        position = nil
      end
    end
  end

  return items
end

--- Run `jetls check` over the file backing `bufnr` and put its diagnostics in the
--- quickfix list.
---
--- The check reads the file from disk, so an unwritten buffer is refused rather
--- than analyzed in its last saved state.
---@param bufnr integer? Buffer to check, defaulting to the current one
M.check = function(bufnr)
  bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr

  local path = vim.api.nvim_buf_get_name(bufnr)
  if path == "" or not vim.uv.fs_stat(path) then
    vim.notify("[jetls] Buffer is not backed by a file on disk", vim.log.levels.ERROR)
    return
  end
  if vim.bo[bufnr].modified then
    vim.notify(
      "[jetls] Buffer has unwritten changes; `jetls check` reads the file from disk",
      vim.log.levels.ERROR
    )
    return
  end

  local exe = M.executable()
  if not exe then
    vim.notify("[jetls] No `jetls` executable found on $PATH", vim.log.levels.ERROR)
    return
  end

  local root = vim.fs.root(bufnr, ROOT_MARKERS) or vim.fs.dirname(path)
  local target = vim.fs.relpath(root, path) or path
  local cmd = { exe, "check", "--progress=none", "--context-lines=0", target }

  vim.notify(("[jetls] Checking '%s'..."):format(target), vim.log.levels.INFO)
  vim.system(cmd, { cwd = root, text = true }, function(out)
    local output = (out.stdout or "") .. (out.stderr or "")
    local items = M.parse(output, root)

    vim.schedule(function()
      -- A non-zero exit is how `jetls check` reports that it found something, so
      -- only an exit with nothing parsed out of the output is a real failure.
      if #items == 0 and out.code ~= 0 then
        vim.notify(
          ("[jetls] `jetls check` failed (exit %d):\n%s"):format(out.code, vim.trim(output)),
          vim.log.levels.ERROR
        )
        return
      end

      vim.fn.setqflist({}, " ", {
        title = ("jetls check %s"):format(target),
        items = items,
      })

      if #items == 0 then
        vim.notify(("[jetls] No diagnostics in '%s'"):format(target), vim.log.levels.INFO)
      else
        vim.cmd.copen()
        vim.notify(
          ("[jetls] %d diagnostic%s in '%s'"):format(#items, #items == 1 and "" or "s", target),
          vim.log.levels.INFO
        )
      end
    end)
  end)
end

return M
