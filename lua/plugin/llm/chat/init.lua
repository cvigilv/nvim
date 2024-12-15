local job = require("plenary.job")

local M = {}
_G.claudio_chat = {}

-- Logic
---Processes input by replacing keywords with their corresponding values.
---@param input string The input string containing keywords to be replaced
---@param ui table The UI object containing reference to the buffer
---@return string The processed input with keywords replaced
local function process_keywords(input, ui)
  local function replace_keyword(keyword)
    if keyword == "#buffer" then
      -- Get the content of the buffer the chat is attached to
      local buffer_content =
        table.concat(vim.api.nvim_buf_get_lines(ui.ref_buf, 0, -1, false), "\n")
      return buffer_content
    elseif keyword:match("^#lua:") then
      -- Execute Lua code and return the result
      local lua_code = keyword:sub(6) -- Remove "#lua:" prefix
      local success, result = pcall(loadstring("return " .. lua_code))
      if success then
        return tostring(result)
      else
        return "Error executing Lua code: " .. tostring(result)
      end
    end
    -- Return the original keyword if not recognized
    return keyword
  end

  -- Replace keywords in the input
  local processed_input = input:gsub("#%w+:?[%w%.]*", replace_keyword)
  return processed_input
end

---Retrieves the contents of a buffer as a table of lines.
---@param buffer number The buffer handle
---@return table A table containing all lines of the buffer
local function get_buffer_contents(buffer)
  return vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
end

---Clears the contents of a buffer by setting all lines to empty.
---@param buffer number The buffer handle to clear
local function clear_buffer_contents(buffer)
  vim.api.nvim_buf_set_lines(buffer, 0, vim.api.nvim_buf_line_count(buffer), false, {})
end

---Writes a string at the cursor position in a specified window.
---@param contents string The string to be written at the cursor position
---@param winnr number The window number where the string will be written
local function write_string_at_cursor(contents, winnr)
  vim.schedule(function()
    vim.api.nvim_set_current_win(winnr)
    local cursor_position = vim.api.nvim_win_get_cursor(winnr)
    local row, col = cursor_position[1], cursor_position[2]

    local lines = vim.split(contents, "\n")

    vim.cmd("undojoin")
    vim.api.nvim_put(lines, "c", true, true)

    local num_lines = #lines
    local last_line_length = #lines[num_lines]
    vim.api.nvim_win_set_cursor(winnr, { row + num_lines - 1, col + last_line_length })
  end)
end

function M.write_string_at_extmark(str, extmark_id)
  vim.schedule(function()
    local extmark =
      vim.api.nvim_buf_get_extmark_by_id(0, ns_id, extmark_id, { details = false })
    local row, col = extmark[1], extmark[2]

    vim.cmd("undojoin")
    local lines = vim.split(str, "\n")
    vim.api.nvim_buf_set_text(0, row, col, row, col, lines)
  end)
end

---Sends a query to Claude AI and processes the streamed response.
---@param query table The user's query as a table of strings
---@param ui table UI components including input and response buffers and windows
---@param opts table Options for the API request, including model selection
---@see write_string_at_cursor
local function request_to_claude(query, ui, opts)
  local current_event_state = nil
  local current_response = ""

  ---Parses an SSE line and processes content block deltas.{{{
  ---@param line string The SSE line to parse
  ---@see vim.json.decode
  ---@see write_string_at_cursor
  local function parse_and_call(line)
    local event = line:match("^event: (.+)$")
    if event then
      current_event_state = event
      return
    end
    local data_match = line:match("^data: (.+)$")
    if data_match then
      if current_event_state == "content_block_delta" then
        local json = vim.json.decode(data_match)
        if json.delta and json.delta.text then
          write_string_at_cursor(json.delta.text, ui.response_win)
          current_response = current_response .. json.delta.text
        end
      end
    end
  end -- }}}
  -- Prepare message to send and append to history{{{
  local message = { role = "user", content = table.concat(query, "\n") }
  table.insert(_G.claudio_chat[tostring(ui.input_buf)].history, message) -- }}}
  -- Prepare arguments for curl command{{{
  local data = {
    model = opts.chat.model or "claude-3-5-sonnet-20240620",
    max_tokens = (1024 * 4),
    messages = _G.claudio_chat[tostring(ui.input_buf)].history,
    system = opts.chat.system_prompt,
    stream = true,
  }

  local args = {
    "-N",
    "-X",
    "POST",
    "-H",
    "Content-Type: application/json",
    "-H",
    "x-api-key: " .. os.getenv("ANTHROPIC_API_KEY"),
    "-H",
    "anthropic-version: 2023-06-01",
    "-d",
    vim.json.encode(data),
    "https://api.anthropic.com/v1/messages",
  } -- }}}
  -- Kill previous active job {{{
  if _G.claudio_chat[tostring(ui.input_buf)].job then
    _G.claudio_chat[tostring(ui.input_buf)].job:shutdown()
    _G.claudio_chat[tostring(ui.input_buf)].job = nil
  end -- }}}
  -- Launch job for prompt querying {{{
  _G.claudio_chat[tostring(ui.input_buf)].job = job:new({
    command = "curl",
    args = args,
    on_stdout = function(_, out) parse_and_call(out) end,
    on_stderr = function(_, _) end,
    on_exit = function()
      _G.claudio_chat[tostring(ui.input_buf)].job = nil
      table.insert(
        _G.claudio_chat[tostring(ui.input_buf)].history,
        { role = "assistant", content = current_response }
      )
    end,
  })

  _G.claudio_chat[tostring(ui.input_buf)].job:start() -- }}}
  -- Setup keybind to kill response streaming{{{
  vim.api.nvim_create_autocmd("User", {
    pattern = "ClaudioChat_CancelStreaming",
    callback = function()
      if _G.claudio_chat[tostring(ui.input_buf)].job then
        _G.claudio_chat[tostring(ui.input_buf)].job:shutdown()
        _G.claudio_chat[tostring(ui.input_buf)].job = nil
      end
    end,
    once = true,
  })

  vim.keymap.set(
    "n",
    "<Esc>",
    ":doautocmd User ClaudioChat_CancelStreaming<CR>",
    { buffer = ui.response_buf, noremap = true, silent = true }
  ) -- }}}
end

---Sends a query to Claude AI and displays the response in a Neovim buffer.
---@param ui table|nil The UI components for displaying the chat. If nil, uses the global UI for the current buffer.
---@param opts table|nil Options for the query. If nil, uses default options.
---@see request_to_claude
---@see get_buffer_contents
---@see clear_buffer_contents
local function send_query(ui, opts)
  ui = ui or _G.claudio_chat[tostring(vim.api.nvim_get_current_buf())].ui

  -- Get query and clear input window
  local query = get_buffer_contents(ui.input_buf)
  clear_buffer_contents(ui.input_buf)

  -- TODO: Add tags to easily include relevant context information (buffer contents, filetype,
  --       working directory files, etc.)
  -- Process keywords in the query
  query = vim.split(process_keywords(table.concat(query, "\n"), ui), "\n")

  -- Add formatted query to response window
  vim.api.nvim_buf_set_lines(
    ui.response_buf,
    -1,
    -1,
    false,
    vim
      .iter({ "", "---", "", "# User", "", query, "", "# Assistant", "", "" })
      :flatten()
      :totable()
  )

  local num_lines = vim.api.nvim_buf_line_count(ui.response_buf)
  vim.api.nvim_win_set_cursor(ui.response_win, { num_lines, 0 })

  -- Send prompt to Anthropic and stream response
  request_to_claude(query, ui, opts)
end

---Closes chat UI by deleting buffers and windows.
---@param ui table List of buffer and windows comprising the chat UI
local function close_chat_ui(ui)
  -- Delete buffers
  local del_buf = function(buf) vim.api.nvim_buf_delete(buf, { force = true, unload = false }) end
  pcall(del_buf, ui.input_buf)
  pcall(del_buf, ui.response_buf)

  -- Close windows
  local del_win = function(win) vim.api.nvim_win_close(win, true) end
  pcall(del_win, ui.input_win)
  pcall(del_win, ui.response_win)

  _G.claudio_chat[ui.ref_buf] = nil
end

---Creates a UI for a chat interface in Neovim.
---@param ref_buf number|nil Reference buffer (defaults to current buffer)
---@param ref_win number|nil Reference window (defaults to current window)
---@param opts Claudio.Configuration Configuration options for the UI
---@return table ui UI components including buffers and windows
function M.create_ui(ref_buf, ref_win, opts)
  -- Default to current buffer and window
  ref_buf = ref_buf or vim.api.nvim_get_current_buf()
  ref_win = ref_win or vim.api.nvim_get_current_win()

  -- Build UI {{{
  -- Create chat buffers and windows
  local response_buf = vim.api.nvim_create_buf(false, true)
  local input_buf = vim.api.nvim_create_buf(false, true)

  local response_win = vim.api.nvim_open_win(response_buf, true, { split = "right" })
  local input_win =
    vim.api.nvim_open_win(input_buf, true, { split = "below", win = response_win })

  -- Set size
  vim.cmd("vertical resize " .. 96)
  vim.cmd("resize " .. 8)

  -- Set buffer and window options
  for _, buf in ipairs({ input_buf, response_buf }) do
    vim.api.nvim_set_option_value("textwidth", 80, { buf = buf })
    vim.api.nvim_set_option_value("filetype", "markdown", { buf = buf })
    vim.api.nvim_set_option_value("wrapmargin", 0, { buf = buf })
    vim.api.nvim_set_option_value("buftype", "", { buf = buf })
  end

  for _, win in ipairs({ input_win, response_win }) do
    vim.api.nvim_set_option_value("wrap", true, { win = win })
    vim.api.nvim_set_option_value("linebreak", true, { win = win })
    vim.api.nvim_set_option_value("number", false, { win = win })
    vim.api.nvim_set_option_value("relativenumber", false, { win = win })
  end

  -- Find the next available number for buffer names
  local function get_next_buffer_number(base_name)
    local i = 1
    while true do
      local test_name = base_name .. i
      if vim.fn.bufnr(test_name) == -1 then return i end
      i = i + 1
    end
  end

  local chat_number = get_next_buffer_number("ClaudioChat")
  local input_number = get_next_buffer_number("ClaudioInput")

  vim.api.nvim_buf_set_name(response_buf, "ClaudioChat" .. chat_number)
  vim.api.nvim_buf_set_name(input_buf, "ClaudioInput" .. input_number)

  -- Build UI table
  local ui = {
    ref_buf = ref_buf,
    ref_win = ref_win,
    input_buf = input_buf,
    input_win = input_win,
    response_buf = response_buf,
    response_win = response_win,
  }

  -- Register open UI
  _G.claudio_chat[tostring(input_buf)] = { ui = ui, history = {}, job = nil }

  -- }}}
  -- Autocommands {{{
  -- Setup autocommand to close Chat UI in together
  for _, bufnr in ipairs({ response_buf, input_buf }) do
    vim.api.nvim_create_autocmd("QuitPre", {
      buffer = bufnr,
      callback = function() close_chat_ui(ui) end,
      once = true,
    })
  end

  -- Setup autocommand to close Chat UI if buffer it is attached to closes
  vim.api.nvim_create_autocmd("QuitPre", {
    buffer = ref_buf,
    callback = function() close_chat_ui(ui) end,
    once = true,
  }) -- }}}
  -- Keybinds {{{
  -- <Tab> to jump between windows
  vim.keymap.set(
    "n",
    "<Tab>",
    function() vim.api.nvim_set_current_win(response_win) end,
    { silent = true, noremap = true, buffer = input_buf }
  )
  vim.keymap.set(
    "n",
    "<Tab>",
    function() vim.api.nvim_set_current_win(input_win) end,
    { silent = true, noremap = true, buffer = response_buf }
  )

  -- <C-s> to send query
  vim.keymap.set(
    { "i", "n" },
    "<C-s>",
    function() send_query(ui, opts) end,
    { silent = true, noremap = true, buffer = input_buf }
  )
  -- }}}

  return ui
end

return M
