---@module "plugin.correo.compose"
---@author Carlos Vigil-Vásquez
---@license MIT 2026

-- Compose flow: reply, forward and new messages. Himalaya generates a raw
-- template (headers + MML body) which is edited as a plain `mail` buffer at
-- /tmp/<account>.<kind>.<id>; `:w` asks for confirmation and sends the buffer
-- through `template send`. Himalaya never spawns its own editor.

local himalaya = require("plugin.correo.himalaya")
local log = require("plugin.correo.log")

---@class Correo.Compose.Context
---@field account string|nil Account the message will be sent from
---@field folder string|nil Folder of the source message (nil for a new message)
---@field kind "write"|"reply"|"forward"|"draft" Compose flavour
---@field envelope Correo.Himalaya.Envelope|nil Envelope being replied to/forwarded/edited
---@field reply_all boolean|nil Whether a reply targets all recipients
---@field mailbox_bufnr integer|nil Mailbox to refresh after a draft is consumed

-- Per-buffer context, keyed by buffer number
---@type table<integer, Correo.Compose.Context>
local State = {}

local M = {}

--- Build the on-disk path for a compose buffer
---@param ctx Correo.Compose.Context Compose context
---@return string path Path shaped as /tmp/<account>.<kind>.<id|timestamp>
local build_path = function(ctx)
  local _suffix = ctx.envelope and ctx.envelope.id or tostring(os.time())
  return ("/tmp/%s.%s.%s"):format(ctx.account or "default", ctx.kind, _suffix)
end

--- Configure buffer options, autocmds and cleanup for a compose buffer
---@param bufnr integer Compose buffer handle
local configure_buffer = function(bufnr)
  -- `acwrite` routes `:w` to our BufWriteCmd, which confirms and sends
  vim.bo[bufnr].buftype = "acwrite"
  vim.bo[bufnr].filetype = "mail"
  vim.bo[bufnr].swapfile = false

  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = bufnr,
    callback = function() M.send(bufnr) end,
  })

  vim.keymap.set("n", vim.g.correo.opts.keymaps.attach, function() M.attach(bufnr) end, {
    buffer = bufnr,
    desc = "correo: attach a file",
  })

  -- Drop per-buffer context when the buffer goes away
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = bufnr,
    callback = function() State[bufnr] = nil end,
  })
end

--- Delete the original draft once it was sent or superseded (no-op otherwise)
---@param ctx Correo.Compose.Context Compose context
---@param on_done fun() Continuation, called even if the deletion failed
local delete_original_draft = function(ctx, on_done)
  if ctx.kind ~= "draft" or ctx.envelope == nil then
    on_done()
    return
  end
  himalaya.delete_messages({
    account = ctx.account,
    folder = ctx.folder,
    ids = { ctx.envelope.id },
  }, function(_, _err)
    if _err then
      vim.notify("[correo] could not delete original draft: " .. _err, vim.log.levels.WARN)
      log.error(_err)
    end
    on_done()
  end)
end

--- Flag the replied-to message as \Answered after a reply is sent (else no-op)
---@param ctx Correo.Compose.Context Compose context
---@param on_done fun() Continuation, called even if the flag update failed
local mark_original_answered = function(ctx, on_done)
  if ctx.kind ~= "reply" or ctx.envelope == nil then
    on_done()
    return
  end
  himalaya.change_flags("add", {
    account = ctx.account,
    folder = ctx.folder,
    ids = { ctx.envelope.id },
    flags = { "answered" },
  }, function(_, _err)
    if _err then
      vim.notify("[correo] could not flag original as answered: " .. _err, vim.log.levels.WARN)
      log.error(_err)
    end
    on_done()
  end)
end

--- Report a template operation and close the compose buffer on success
---
--- On a successful send, a reply flags its original message as \Answered (so
--- it shows the replied glyph). When editing a draft, the original draft is
--- deleted so the drafts folder never keeps a stale copy of what was sent.
---@param bufnr integer Compose buffer handle
---@param ctx Correo.Compose.Context Compose context
---@param success string Message shown when the operation succeeded
---@param sent boolean Whether the message was sent (vs saved as a draft)
---@return fun(result: string|nil, err: string|nil) callback Completion callback
local finish_compose = function(bufnr, ctx, success, sent)
  return function(_, _err)
    if _err then
      vim.notify("[correo] " .. _err, vim.log.levels.ERROR)
      log.error(_err)
      return
    end
    local _cleanup = function()
      vim.notify("[correo] " .. success, vim.log.levels.INFO)
      -- The compose buffer served its purpose (local /tmp copy stays as backup)
      if vim.api.nvim_buf_is_valid(bufnr) then vim.cmd(("bwipeout! %d"):format(bufnr)) end
      if ctx.mailbox_bufnr ~= nil and vim.api.nvim_buf_is_valid(ctx.mailbox_bufnr) then
        require("plugin.correo.mailbox").refresh(ctx.mailbox_bufnr)
      end
    end
    local _drop_draft = function() delete_original_draft(ctx, _cleanup) end
    -- Answering only applies to a sent reply, never to a saved draft
    if sent then
      mark_original_answered(ctx, _drop_draft)
    else
      _drop_draft()
    end
  end
end

--- Insert an MML attachment part at the cursor of a compose buffer
---@param bufnr integer Compose buffer handle (0 for the current buffer)
---@param path string|nil File to attach (nil → prompt with file completion)
M.attach = function(bufnr, path)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  if State[bufnr] == nil then return end
  local _insert = function(_path)
    if _path == nil or _path == "" then return end
    _path = vim.fn.fnamemodify(vim.fn.expand(_path), ":p")
    if vim.fn.filereadable(_path) == 0 then
      vim.notify("[correo] not a readable file: " .. _path, vim.log.levels.ERROR)
      return
    end
    -- MML part: Himalaya's template compiler turns this into a real attachment
    local _lnum = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_buf_set_lines(bufnr, _lnum, _lnum, false, {
      ("<#part filename=%s><#/part>"):format(_path),
    })
  end
  if path ~= nil then
    _insert(path)
  else
    vim.ui.input({ prompt = "Attach file: ", completion = "file" }, _insert)
  end
end

--- Confirm and send the compose buffer, or save it as a draft in the mailbox
---
--- The buffer is always persisted to its /tmp file first, so cancelling (or a
--- failed send/save) never loses the text.
---@param bufnr integer Compose buffer handle (0 for the current buffer)
M.send = function(bufnr)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  local _ctx = State[bufnr]
  if _ctx == nil then return end

  local _lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  vim.fn.writefile(_lines, vim.api.nvim_buf_get_name(bufnr))
  vim.bo[bufnr].modified = false
  local _template = table.concat(_lines, "\n") .. "\n"

  local _account = _ctx.account or "default"
  local _choice = vim.fn.confirm(
    ("Message ready on account %s:"):format(_account),
    "&Send\nSave &draft\n&Cancel",
    3
  )
  if _choice == 1 then
    himalaya.send_template(
      { account = _ctx.account, template = _template },
      finish_compose(bufnr, _ctx, "message sent", true)
    )
  elseif _choice == 2 then
    local _folder = vim.g.correo.opts.drafts_folder
    himalaya.save_template(
      { account = _ctx.account, folder = _folder, template = _template },
      finish_compose(bufnr, _ctx, "draft saved to " .. _folder, false)
    )
  else
    vim.notify("[correo] cancelled, kept editing", vim.log.levels.INFO)
  end
end

--- Materialize compose content on disk and edit it in the current window
---@param ctx Correo.Compose.Context Compose context to register for the buffer
---@param content string Raw template content (headers + body)
---@return integer bufnr Handle of the compose buffer
local open_compose_buffer = function(ctx, content)
  local _path = build_path(ctx)
  vim.fn.writefile(vim.split(content:gsub("\r\n", "\n"), "\n"), _path)
  vim.cmd.edit({ vim.fn.fnameescape(_path), bang = true })

  local _bufnr = vim.api.nvim_get_current_buf()
  State[_bufnr] = ctx
  configure_buffer(_bufnr)
  log.fmt_debug("composing %s at %s", ctx.kind, _path)
  return _bufnr
end

--- Get the context of a compose buffer
---@param bufnr integer Compose buffer handle (0 for the current buffer)
---@return Correo.Compose.Context|nil context Context, or nil if not a compose buffer
M.get_context = function(bufnr)
  if bufnr == 0 then bufnr = vim.api.nvim_get_current_buf() end
  return State[bufnr]
end

--- Generate a template and open it as an editable compose buffer
---@param ctx Correo.Compose.Context What to compose and from where
M.open = function(ctx)
  himalaya.build_template(ctx.kind, {
    account = ctx.account,
    folder = ctx.folder,
    id = ctx.envelope and ctx.envelope.id or nil,
    reply_all = ctx.reply_all,
  }, function(_template, _err)
    if _err or _template == nil then
      vim.notify("[correo] " .. (_err or "no template"), vim.log.levels.ERROR)
      log.error(_err)
      return
    end
    open_compose_buffer(ctx, _template.content)
    -- Land the cursor where the template says the body starts
    pcall(vim.api.nvim_win_set_cursor, 0, { _template.cursor.row, _template.cursor.col })
  end)
end

-- Headers preserved when a draft is reopened for editing (threading included)
local DRAFT_HEADERS = { "From", "To", "Cc", "Bcc", "Subject", "In-Reply-To", "References" }

--- Reopen an existing draft as an editable compose buffer
---
--- Sending (or re-saving) the buffer deletes the original draft message, so
--- the drafts folder always holds at most one copy.
---@param ctx Correo.Compose.Context Draft to edit (`envelope` and `folder` required)
M.open_draft = function(ctx)
  himalaya.read_message({
    account = ctx.account,
    folder = ctx.folder,
    id = ctx.envelope.id,
    preview = true,
    headers = DRAFT_HEADERS,
  }, function(_content, _err)
    if _err or _content == nil then
      vim.notify("[correo] " .. (_err or "no draft content"), vim.log.levels.ERROR)
      log.error(_err)
      return
    end
    ctx.kind = "draft"
    open_compose_buffer(ctx, _content)
    -- Resume editing at the end of the body
    vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(0), 0 })
  end)
end

return M
