---@module "plugin.correo.cli"
---@author Carlos Vigil-Vásquez
---@license MIT 2026

-- Generic asynchronous CLI runner. This module knows nothing about email or
-- Himalaya: it only executes an argv, normalizes the result and (optionally)
-- decodes JSON. Backend-specific knowledge lives in `himalaya.lua`.

---@class Correo.CLI.Result
---@field ok boolean Whether the command exited with code 0
---@field code integer Exit code of the command
---@field stdout string Raw standard output
---@field stderr string Raw standard error

local M = {}

--- Run a command asynchronously and hand a normalized result to `on_done`
---@param argv string[] Command and arguments to execute
---@param on_done fun(result: Correo.CLI.Result) Callback, invoked on the main event loop
---@param stdin string|nil Text fed to the command's standard input
M.run = function(argv, on_done, stdin)
  vim.system(
    argv,
    { text = true, stdin = stdin },
    vim.schedule_wrap(function(_out)
      on_done({
        ok = _out.code == 0,
        code = _out.code,
        stdout = _out.stdout or "",
        stderr = _out.stderr or "",
      })
    end)
  )
end

--- Format a failed result as a single human-readable error string
---@param argv string[] Command that was executed
---@param result Correo.CLI.Result Failed result
---@return string err Error message
local format_error = function(argv, result)
  return ("`%s` failed (%d): %s"):format(
    table.concat(argv, " "),
    result.code,
    vim.trim(result.stderr)
  )
end

--- Run a command asynchronously, expecting plain-text output
---@param argv string[] Command and arguments to execute
---@param on_done fun(output: string|nil, err: string|nil) Callback with trimmed stdout or an error
---@param stdin string|nil Text fed to the command's standard input
M.run_text = function(argv, on_done, stdin)
  M.run(argv, function(_result)
    if not _result.ok then
      on_done(nil, format_error(argv, _result))
      return
    end
    on_done(vim.trim(_result.stdout), nil)
  end, stdin)
end

--- Run a command asynchronously and JSON-decode its standard output
---@param argv string[] Command and arguments to execute
---@param on_done fun(data: any|nil, err: string|nil) Callback with decoded data or an error message
---@param stdin string|nil Text fed to the command's standard input
M.run_json = function(argv, on_done, stdin)
  M.run(argv, function(_result)
    if not _result.ok then
      on_done(nil, format_error(argv, _result))
      return
    end

    local _ok, _data = pcall(vim.json.decode, _result.stdout, {
      luanil = { object = true, array = true },
    })
    if not _ok then
      on_done(nil, "failed to decode JSON output: " .. tostring(_data))
      return
    end

    on_done(_data, nil)
  end, stdin)
end

return M
