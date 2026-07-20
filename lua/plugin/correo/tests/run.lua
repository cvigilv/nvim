---@module "plugin.correo.tests.run"
---@author Carlos Vigil-Vásquez
---@license MIT 2026

-- Self-contained test suite for correo.nvim. No external dependencies:
-- run with `nvim -l tests/run.lua` from the plugin directory (or any cwd).
-- A stub `himalaya` binary (tests/bin/himalaya) answers with fixtures and
-- logs its argv, so no network or real mailbox is ever touched.

-- {{{ Harness
local Results = { pass = 0, fail = 0, messages = {} }

--- Record an equality assertion
---@param desc string What is being checked
---@param got any Actual value
---@param want any Expected value
local eq = function(desc, got, want)
  if vim.deep_equal(got, want) then
    Results.pass = Results.pass + 1
  else
    Results.fail = Results.fail + 1
    table.insert(
      Results.messages,
      ("FAIL %s\n  want: %s\n  got:  %s"):format(desc, vim.inspect(want), vim.inspect(got))
    )
  end
end

--- Record a truthiness assertion
---@param desc string What is being checked
---@param cond any Value that must be truthy
local ok = function(desc, cond)
  eq(desc, cond and true or false, true)
end

--- Wait until `predicate` returns true (async helpers settle) or fail
---@param desc string What is being awaited
---@param predicate fun(): boolean Condition to wait for
local await = function(desc, predicate)
  local _done = vim.wait(5000, predicate, 10)
  ok(desc .. " (await)", _done)
end
-- }}}

-- {{{ Environment
local _script = debug.getinfo(1, "S").source:sub(2)
local _tests_dir = vim.fn.fnamemodify(_script, ":p:h")
local _plugin_dir = vim.fn.fnamemodify(_tests_dir, ":h")
local _lua_root = vim.fn.fnamemodify(_plugin_dir, ":h:h")
package.path = ("%s/?.lua;%s/?/init.lua;"):format(_lua_root, _lua_root) .. package.path

local _log_file = vim.fn.tempname()
local _stdin_file = vim.fn.tempname()
vim.env.CORREO_TEST_LOG = _log_file
vim.env.CORREO_TEST_STDIN = _stdin_file
-- Pin the timezone so date-rendering assertions are deterministic (local = UTC)
vim.env.TZ = "UTC0"

--- Read the stub's invocation log
---@return string[] lines One line per stub invocation
local read_log = function()
  return vim.fn.filereadable(_log_file) == 1 and vim.fn.readfile(_log_file) or {}
end

require("plugin.correo").setup({
  binary = _tests_dir .. "/bin/himalaya",
  account = "test",
  logging = { use_quickfix = false, use_console = false },
})
-- }}}

-- {{{ render.lua
local render = require("plugin.correo.render")
local _ui = vim.g.correo.opts.ui

local _seen_envelope = {
  id = "1",
  flags = { "Seen" },
  subject = "hello world",
  from = { name = "Alice", addr = "alice@example.com" },
  to = { name = nil, addr = "me@example.com" },
  date = "2026-07-17 19:17+00:00",
  has_attachment = false,
}

local _line = render.render_envelope(_seen_envelope, _ui)
ok("render: seen row has no unread icon", _line.text:find("●") == nil)
ok("render: date formatted", _line.text:find("17 Jul", 1, true) ~= nil)

-- Date column is timezone-aware: the offset is applied before the day is taken
-- (TZ=UTC0, so "local" here is UTC)
local _date_of = function(date)
  local _e = vim.deepcopy(_seen_envelope)
  _e.date = date
  local _s = render.render_envelope(_e, _ui).spans[4]
  return vim.trim(render.render_envelope(_e, _ui).text:sub(_s.first + 1, _s.last))
end
eq("render: wire UTC date kept on same day", _date_of("2026-07-17 19:17+00:00"), "17 Jul")
eq("render: negative offset rolls to next local day", _date_of("2026-07-17 23:30-02:00"), "18 Jul")
eq("render: positive offset rolls to previous local day", _date_of("2026-07-17 01:30+05:00"), "16 Jul")
eq("render: already-local offset is a no-op", _date_of("2026-07-17 12:00+00:00"), "17 Jul")
ok("render: sender rendered", _line.text:find("Alice", 1, true) ~= nil)
ok("render: subject rendered", _line.text:find("hello world", 1, true) ~= nil)
eq(
  "render: span highlight order",
  vim.tbl_map(function(s) return s.hl end, _line.spans),
  { "CorreoUnread", "CorreoFlagged", "CorreoAttachment", "CorreoDate", "CorreoFrom", "CorreoSubject" }
)
ok("render: spans cover the full line", _line.spans[#_line.spans].last == #_line.text)

local _unseen = vim.deepcopy(_seen_envelope)
_unseen.flags = {}
_unseen.subject = ""
local _unseen_line = render.render_envelope(_unseen, _ui)
ok("render: unseen row shows unread icon", _unseen_line.text:find("●", 1, true) ~= nil)
ok("render: empty subject placeholder", _unseen_line.text:find("(no subject)", 1, true) ~= nil)
eq(
  "render: unseen subject highlight",
  _unseen_line.spans[#_unseen_line.spans].hl,
  "CorreoSubjectUnread"
)

-- Custom format strings drive the layout
local _custom_ui = vim.tbl_deep_extend("force", vim.deepcopy(_ui), {
  mailbox = { format = "<%s>" },
})
eq(
  "render: custom format with literals",
  render.render_envelope(_seen_envelope, _custom_ui).text,
  "<hello world>"
)
local _unknown_ui = vim.tbl_deep_extend("force", vim.deepcopy(_ui), {
  mailbox = { format = "%x%s" },
})
eq(
  "render: unknown specifier kept literally",
  render.render_envelope(_seen_envelope, _unknown_ui).text,
  "xhello world"
)

-- Long senders are truncated to an exact display width
local _long_from = vim.deepcopy(_seen_envelope)
_long_from.from.name = ("x"):rep(60)
local _from_span = render.render_envelope(_long_from, _ui).spans[5]
local _from_text =
  render.render_envelope(_long_from, _ui).text:sub(_from_span.first + 1, _from_span.last)
eq("render: sender truncated to width", vim.fn.strdisplaywidth(_from_text), _ui.from_width)
ok("render: truncation marked with ellipsis", _from_text:find("…") ~= nil)
-- }}}

-- {{{ render.thread_envelopes
local _mk = function(id, subject, date)
  return {
    id = id,
    flags = {},
    subject = subject,
    from = { name = nil, addr = "a@example.com" },
    to = { name = nil, addr = "me@example.com" },
    date = date,
    has_attachment = false,
  }
end

local _thread_input = {
  _mk("t1", "Re: Topic", "2026-07-17 12:00+00:00"),
  _mk("t2", "standalone", "2026-07-16 12:00+00:00"),
  _mk("t3", "FWD: Re: topic", "2026-07-15 12:00+00:00"),
  _mk("t4", "topic", "2026-07-14 12:00+00:00"),
  _mk("t5", "", "2026-07-13 12:00+00:00"),
  _mk("t6", "", "2026-07-12 12:00+00:00"),
}
local _ordered, _folds = render.thread_envelopes(_thread_input)
eq(
  "threads: members adjacent, thread anchored at newest",
  vim.tbl_map(function(e) return e.id end, _ordered),
  { "t1", "t3", "t4", "t2", "t5", "t6" }
)
eq("threads: one fold per multi-member group", _folds, { { first = 1, last = 3 } })
local _no_threads, _no_folds = render.thread_envelopes({ _mk("a", "one", "2026-07-17 12:00+00:00") })
eq("threads: singleton produces no folds", { #_no_threads, _no_folds }, { 1, {} })
-- }}}

-- {{{ cli.lua
local cli = require("plugin.correo.cli")

local _result = nil
cli.run({ "sh", "-c", "printf hello" }, function(r) _result = r end)
await("cli.run completes", function() return _result ~= nil end)
eq("cli.run: ok/stdout", { _result.ok, _result.stdout }, { true, "hello" })

local _data, _err = nil, nil
cli.run_json({ "sh", "-c", "echo '[1,2,3]'" }, function(d, e) _data, _err = d, e end)
await("cli.run_json completes", function() return _data ~= nil or _err ~= nil end)
eq("cli.run_json: decoded array", _data, { 1, 2, 3 })

_data, _err = nil, nil
cli.run_json({ "sh", "-c", "echo 'Error: ' >&2; echo '   0: boom' >&2; exit 3" }, function(d, e)
  _data, _err = d, e
end)
await("cli.run_json failure completes", function() return _err ~= nil end)
ok("cli.run_json: failure code surfaced", _err:find("failed (3)", 1, true) ~= nil)
ok("cli.run_json: error cause extracted", _err:find("boom", 1, true) ~= nil)

_data, _err = nil, nil
cli.run_json({ "sh", "-c", "echo 'not json'" }, function(d, e) _data, _err = d, e end)
await("cli.run_json decode failure completes", function() return _err ~= nil end)
ok("cli.run_json: decode error surfaced", _err:find("decode", 1, true) ~= nil)

local _text = nil
cli.run_text({ "cat" }, function(t) _text = t end, "via stdin\n")
await("cli.run_text stdin completes", function() return _text ~= nil end)
eq("cli.run_text: stdin passthrough, trimmed", _text, "via stdin")
-- }}}

-- {{{ himalaya.lua (argv building + fixture parsing, via the stub binary)
local himalaya = require("plugin.correo.himalaya")

local _envelopes = nil
himalaya.list_envelopes(
  { account = "test", folder = "INBOX", page = 1, page_size = 50, query = "subject foo" },
  function(envs) _envelopes = envs end
)
await("himalaya.list_envelopes completes", function() return _envelopes ~= nil end)
eq("himalaya: fixture envelopes parsed", #_envelopes, 3)
eq("himalaya: envelope fields", _envelopes[1].id, "1")
local _log = read_log()
ok(
  "himalaya: argv has flags before trailing query",
  _log[#_log]:find("--output json subject foo$") ~= nil
)
ok("himalaya: account flag present", _log[#_log]:find("--account test", 1, true) ~= nil)

local _sent = nil
himalaya.send_template({ account = "test", template = "Subject: t\n\nbody\n" }, function(r)
  _sent = r
end)
await("himalaya.send_template completes", function() return _sent ~= nil end)
eq(
  "himalaya: template travelled over stdin",
  table.concat(vim.fn.readfile(_stdin_file), "\n"),
  "Subject: t\n\nbody"
)
ok("himalaya: template send used plain output", read_log()[#read_log()]:find("--output json") == nil)
-- }}}

-- {{{ mailbox.lua (state machine against the stub)
local mailbox = require("plugin.correo.mailbox")

mailbox.open({ account = "test", folder = "INBOX" })
await("mailbox renders", function()
  local _first = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""
  return _first:find("first mail", 1, true) ~= nil
end)
local _mb = vim.api.nvim_get_current_buf()
eq("mailbox: buffer name", vim.api.nvim_buf_get_name(_mb), "correo://test/INBOX")
eq("mailbox: three envelopes drawn", vim.api.nvim_buf_line_count(_mb), 3)
eq("mailbox: envelope resolution", mailbox.get_envelope_at(_mb, 2).id, "2")
eq("mailbox: no pending changes after draw", mailbox.has_pending_changes(_mb), false)

-- dd stages a delete; the envelope under the cursor follows content
vim.api.nvim_win_set_cursor(0, { 2, 0 })
vim.cmd("normal! dd")
local _ops = mailbox.gather_operations(_mb)
eq("mailbox: dd staged one delete", vim.tbl_map(function(e) return e.id end, _ops.deletes), { "2" })
eq("mailbox: line 2 resolves to shifted envelope", mailbox.get_envelope_at(_mb, 2).id, "3")
eq("mailbox: pending changes detected", mailbox.has_pending_changes(_mb), true)

-- Undo restores the line and unstages the delete
vim.cmd("normal! u")
eq("mailbox: undo unstages delete", #mailbox.gather_operations(_mb).deletes, 0)

-- Keymap staging: archive, copy, and explicit-target moves
vim.api.nvim_win_set_cursor(0, { 1, 0 })
mailbox.stage_archive_at_cursor(_mb)
eq(
  "mailbox: archive staged",
  vim.tbl_keys(mailbox.gather_operations(_mb).moves),
  { vim.g.correo.opts.archive_folder }
)
mailbox.stage_archive_at_cursor(_mb)
eq("mailbox: archive unstaged on toggle", next(mailbox.gather_operations(_mb).moves), nil)

mailbox.stage_move_at_cursor(_mb, "Sub folder")
eq("mailbox: explicit move staged", vim.tbl_keys(mailbox.gather_operations(_mb).moves), { "Sub folder" })
vim.api.nvim_win_set_cursor(0, { 2, 0 })
mailbox.stage_copy_at_cursor(_mb, "Archive")
eq("mailbox: copy staged separately", vim.tbl_keys(mailbox.gather_operations(_mb).copies), { "Archive" })

-- Commit: confirm is mocked to "Yes", operations reach the stub, buffer redraws
local _confirm = vim.fn.confirm
vim.fn.confirm = function() return 1 end ---@diagnostic disable-line: duplicate-set-field
mailbox.commit(_mb)
await("commit redraws", function() return mailbox.has_pending_changes(_mb) == false end)
vim.fn.confirm = _confirm
local _calls = table.concat(read_log(), "\n")
ok("mailbox: move committed", _calls:find("message move --account test --folder INBOX Sub folder 1", 1, true) ~= nil)
ok("mailbox: copy committed", _calls:find("message copy --account test --folder INBOX Archive 2", 1, true) ~= nil)

-- Search renames the buffer; reload resets it
mailbox.set_query(_mb, "subject nothing")
await("query rendered empty", function()
  return (vim.api.nvim_buf_get_lines(_mb, 0, 1, false)[1] or ""):find("empty folder") ~= nil
end)
eq(
  "mailbox: query in buffer name",
  vim.api.nvim_buf_get_name(_mb),
  "correo://test/INBOX [subject nothing]"
)
mailbox.reload(_mb)
await("reload restores listing", function() return vim.api.nvim_buf_line_count(_mb) == 3 end)
eq("mailbox: reload resets buffer name", vim.api.nvim_buf_get_name(_mb), "correo://test/INBOX")

-- Paging past the end reverts to the last valid page
mailbox.change_page(_mb, 1)
await("past-end paging settles", function()
  return mailbox.get_context(_mb) ~= nil and vim.api.nvim_buf_line_count(_mb) == 3
end)
eq("mailbox: past-end page reverted", vim.api.nvim_buf_get_name(_mb), "correo://test/INBOX")
-- }}}

-- {{{ mailbox threads (folds against the stub's Threads folder)
--- Toggle the threads option (vim.g values are copies: write the table back)
---@param enabled boolean Desired `ui.mailbox.threads` value
local set_threads = function(enabled)
  local _g = vim.g.correo
  _g.opts.ui.mailbox.threads = enabled
  vim.g.correo = _g
end

set_threads(true)
mailbox.open({ account = "test", folder = "Threads" })
await("threaded mailbox renders", function()
  return vim.api.nvim_buf_get_name(0) == "correo://test/Threads"
    and vim.api.nvim_buf_line_count(0) == 3
end)
local _tb = vim.api.nvim_get_current_buf()
eq(
  "threads: buffer ordered by thread",
  { mailbox.get_envelope_at(_tb, 1).id, mailbox.get_envelope_at(_tb, 2).id, mailbox.get_envelope_at(_tb, 3).id },
  { "t1", "t3", "t2" }
)
eq("threads: fold closed over the thread", { vim.fn.foldclosed(1), vim.fn.foldclosedend(1) }, { 1, 2 })
eq("threads: standalone line unfolded", vim.fn.foldlevel(3), 0)

local _foldline = vim.fn.foldtextresult(1)
ok("threads: foldtext shows subject", _foldline:find("Re: topic A", 1, true) ~= nil)
ok("threads: foldtext shows member count", _foldline:find("(2)", 1, true) ~= nil)

-- Tab expands and collapses the fold
vim.api.nvim_win_set_cursor(0, { 1, 0 })
mailbox.toggle_thread_at_cursor(_tb)
eq("threads: Tab expands", vim.fn.foldclosed(1), -1)
mailbox.toggle_thread_at_cursor(_tb)
eq("threads: Tab collapses again", vim.fn.foldclosed(1), 1)

-- dd on a collapsed thread stages deletion of every member
vim.cmd("normal! dd")
local _thread_deletes = vim.tbl_map(function(e) return e.id end, mailbox.gather_operations(_tb).deletes)
table.sort(_thread_deletes)
eq("threads: dd on closed fold stages whole thread", _thread_deletes, { "t1", "t3" })
vim.cmd("normal! u")
eq("threads: undo unstages the thread", #mailbox.gather_operations(_tb).deletes, 0)

-- Disabling threads restores a flat, unfolded listing
set_threads(false)
mailbox.reload(_tb)
await("flat reload settles", function()
  return mailbox.get_envelope_at(_tb, 1) ~= nil and mailbox.get_envelope_at(_tb, 1).id == "t1"
end)
eq("threads: disabled leaves no folds", vim.fn.foldlevel(1), 0)
-- }}}

-- {{{ Report
print(("\ncorreo.nvim tests: %d passed, %d failed"):format(Results.pass, Results.fail))
for _, _message in ipairs(Results.messages) do
  print(_message)
end
os.exit(Results.fail == 0 and 0 or 1)
-- }}}
