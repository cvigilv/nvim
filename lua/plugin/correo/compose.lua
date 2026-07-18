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
---@field folder string|nil Folder of the replied/forwarded message (nil for a new message)
---@field kind "write"|"reply"|"forward" Compose flavour
---@field envelope Correo.Himalaya.Envelope|nil Envelope being replied to/forwarded
---@field reply_all boolean|nil Whether a reply targets all recipients

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

  -- Drop per-buffer context when the buffer goes away
  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = bufnr,
    callback = function() State[bufnr] = nil end,
  })
end

--- Report a template operation and close the compose buffer on success
---@param bufnr integer Compose buffer handle
---@param success string Message shown when the operation succeeded
---@return fun(result: string|nil, err: string|nil) callback Completion callback
local finish_compose = function(bufnr, success)
  return function(_, _err)
    if _err then
      vim.notify("[correo] " .. _err, vim.log.levels.ERROR)
      log.error(_err)
      return
    end
    vim.notify("[correo] " .. success, vim.log.levels.INFO)
    -- The compose buffer served its purpose (local /tmp copy stays as backup)
    if vim.api.nvim_buf_is_valid(bufnr) then vim.cmd(("bwipeout! %d"):format(bufnr)) end
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
      finish_compose(bufnr, "message sent")
    )
  elseif _choice == 2 then
    local _folder = vim.g.correo.opts.drafts_folder
    himalaya.save_template(
      { account = _ctx.account, folder = _folder, template = _template },
      finish_compose(bufnr, "draft saved to " .. _folder)
    )
  else
    vim.notify("[correo] cancelled, kept editing", vim.log.levels.INFO)
  end
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

    -- Materialize the template on disk and edit it in the current window
    local _path = build_path(ctx)
    vim.fn.writefile(vim.split(_template.content:gsub("\r\n", "\n"), "\n"), _path)
    vim.cmd.edit({ vim.fn.fnameescape(_path), bang = true })

    local _bufnr = vim.api.nvim_get_current_buf()
    State[_bufnr] = ctx
    configure_buffer(_bufnr)
    -- Land the cursor where the template says the body starts
    pcall(vim.api.nvim_win_set_cursor, 0, { _template.cursor.row, _template.cursor.col })
    log.fmt_debug("composing %s at %s", ctx.kind, _path)
  end)
end

return M
