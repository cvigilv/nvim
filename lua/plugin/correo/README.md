# correo.nvim

A [Himalaya CLI](https://himalaya.email) UI for Neovim, inspired by
[oil.nvim](https://github.com/stevearc/oil.nvim): the mailbox is a buffer you
edit, and `:w` commits your changes to the mail server.

Requires Neovim 0.10+ and a configured `himalaya` (v1.x) binary.

## Setup

```lua
require("plugin.correo").setup({
  -- Everything below is optional; these are the defaults
  binary = "himalaya",
  account = nil,             -- nil → Himalaya's default account
  folder = "INBOX",
  archive_folder = "Archive",
  drafts_folder = "drafts",  -- "drafts" resolves Himalaya's per-account alias
  page_size = 100,
  ui = {
    from_width = 24,
    message = { open = "replace" }, -- "split" (20/80 horizontal) or "vsplit" (50/50 vertical)
    icons = { unread = "●", flagged = "⚑", attachment = "" },
  },
})
```

## Commands

| Command | Action |
|---|---|
| `:Correo [account]` | Open an account's mailbox (completion from `account list`) |
| `:CorreoFolder <name>` | Open a folder of the current account (completion from `folder list`) |
| `:CorreoSearch [query]` | Filter/sort the mailbox with a Himalaya query; no args clears |
| `:CorreoWrite [account]` | Compose a new message |
| `:CorreoOpen` | Open the message under the cursor |
| `:CorreoSeen` / `:CorreoUnseen` | Toggle seen / mark unseen |
| `:CorreoArchive` | Stage archiving the envelope under the cursor |
| `:CorreoMove [folder]` | Stage a move; no args opens a folder picker (completion from `folder list`) |
| `:CorreoReply[!]` / `:CorreoForward` | Reply (`!` = reply all) / forward |

## Mailbox model

Each line is one envelope; identity is tracked with extmarks, never by line
position. Mutations are **staged**, then committed:

- `dd` stages a deletion (`u` unstages)
- `ga` stages an archive, `gm` stages a move — staged rows are background-highlighted
  with the bold target folder right-aligned
- `:w` shows a confirmation summary, then runs the operations and refreshes
- `R` resets to the default view (unfiltered, page 1), asking before
  discarding staged operations; the active query is shown in the buffer name

Reading a message marks it seen (revert with `gS`). In the drafts folder,
`<CR>` reopens the draft for editing; sending or re-saving it replaces the
original draft.

Compose buffers (`filetype=mail`, backed by `/tmp/<account>.<kind>.<id>`) send
on `:w` after a Send / Save draft / Cancel prompt.

## Keymaps

Press `g?` in any correo buffer for the live list. Defaults (all configurable
via `keymaps`):

| Key | Mailbox | Message |
|---|---|---|
| `<CR>` | open message / edit draft | — |
| `q` | — | back to mailbox |
| `R` | reload default view | — |
| `gs` / `gS` | toggle seen / mark unseen | same |
| `ga` / `gm` | stage archive / move | — |
| `gr` / `gR` / `gf` | reply / reply all / forward | same |
| `]]` / `[[` | next / previous page | — |
| `gF` / `gA` | pick folder / account | — |
| `g?` | help | help |

## Lua API

```lua
local correo = require("plugin.correo")
correo.open({ account = "work", folder = "INBOX" })
correo.search("from jules and not flag seen")
correo.write({ account = "personal" })
```

## Architecture

`cli.lua` (async runner, knows nothing about email) → `himalaya.lua` (the only
module that knows Himalaya's flags/JSON) → `mailbox.lua` / `message.lua` /
`compose.lua` (buffer state) with `render.lua` (pure formatting),
`highlights.lua`, `help.lua` and `excmd.lua`. See `PLAN.md` for the roadmap.
