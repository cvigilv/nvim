---@module 'claudio.chat.query'
---@author Carlos Vigil-Vasquez
---@license MIT

local Job = require("plenary.job")

local M = {}
local active_job = nil
local group = vim.api.nvim_create_augroup("DING_LLM", { clear = true })

-- Write a string at the current cursor position
function M.write_string_at_cursor(str)
  vim.schedule(function()
    local current_window = vim.api.nvim_get_current_win()
    local cursor_position = vim.api.nvim_win_get_cursor(current_window)
    local row, col = cursor_position[1], cursor_position[2]

    local lines = vim.split(str, "\n")

    vim.cmd("undojoin")
    vim.api.nvim_put(lines, "c", true, true)

    local num_lines = #lines
    local last_line_length = #lines[num_lines]
    vim.api.nvim_win_set_cursor(current_window, { row + num_lines - 1, col + last_line_length })
  end)
end

-- Handle Anthropic-specific data stream
function M.handle_anthropic_spec_data(data_stream, event_state)
  if event_state == "content_block_delta" then
    local json = vim.json.decode(data_stream)
    if json.delta and json.delta.text then M.write_string_at_cursor(json.delta.text) end
  end
end

-- Get the prompt from the options or use a default one
local function get_prompt(opts) return opts.prompt or "Default prompt" end

-- Parse the streaming response and call the appropriate handler
local function parse_and_call(line, curr_event_state, handle_data_fn)
  local event = line:match("^event: (.+)$")
  if event then return event end
  local data_match = line:match("^data: (.+)$")
  if data_match then handle_data_fn(data_match, curr_event_state) end
  return curr_event_state
end

-- Set up the escape key mapping to cancel the LLM streaming
local function setup_escape_mapping()
  vim.api.nvim_set_keymap(
    "n",
    "<Esc>",
    ":doautocmd User ClaudioChatEscape<CR>",
    { noremap = true, silent = true }
  )
end

-- Create an autocmd to handle LLM streaming cancellation
local function create_escape_autocmd()
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "ClaudioChatEscape",
    callback = function()
      if active_job then
        active_job:shutdown()
        print("LLM streaming cancelled")
        active_job = nil
      end
    end,
  })
end

-- Main function to invoke LLM and stream into editor
function M.invoke_llm_and_stream_into_editor(opts, make_curl_args_fn, handle_data_fn)
  vim.api.nvim_clear_autocmds({ group = group })

  local prompt = get_prompt(opts)
  local system_prompt = opts.system_prompt
  local args = make_curl_args_fn(opts, prompt, system_prompt)
  local curr_event_state = nil

  -- Shutdown existing job if any
  if active_job then
    active_job:shutdown()
    active_job = nil
  end

  -- Create and start a new job
  ---@diagnostic disable-next-line: missing-fields
  active_job = Job:new({
    command = "curl",
    args = args,
    on_stdout = function(_, out)
      curr_event_state = parse_and_call(out, curr_event_state, handle_data_fn)
    end,
    on_stderr = function(_, _) end,
    on_exit = function() active_job = nil end,
  })

  active_job:start()

  create_escape_autocmd()
  setup_escape_mapping()

  return active_job
end

return M
