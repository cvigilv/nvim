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
    mailbox = {
      format = "%u%F%a%d%f  %s", -- %u unread %F flagged %a attachment
                                 -- %d date %f sender %s subject
      threads = false,           -- group subject threads into closed folds
    },
    message = { open = "replace" }, -- "hsplit" (20/80 horizontal), "vsplit" (50/50 vertical),
                                    -- or "split" (vertical if wide, else horizontal)
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
| `:CorreoCopy [folder]` | Stage a copy (Gmail: add label); no args opens a folder picker |
| `:CorreoDelete` | Stage deleting the envelope under the cursor |
| `:CorreoAttachments` | Download all attachments of the current message |
| `:CorreoNextPage` / `:CorreoPrevPage` | Page through the listing |
| `:CorreoAccounts` / `:CorreoFolders` | Pick an account / folder via `vim.ui.select` |
| `:CorreoAttach [file]` | Insert an attachment into the compose buffer |

## Mailbox model

Each line is one envelope; identity is tracked with extmarks, never by line
position. Mutations are **staged**, then committed:

- `dd` stages a deletion (`u` unstages)
- `ga` stages an archive, `gm` stages a move — staged rows are background-highlighted
  with the bold target folder right-aligned
- `:w` shows a confirmation summary, then runs the operations and refreshes
- `R` resets to the default view (unfiltered, page 1), asking before
  discarding staged operations; the active query is shown in the buffer name

With `ui.mailbox.threads = true`, envelopes sharing a (normalized) subject are
grouped into a Vim fold shown as the newest message's line suffixed with the
message count `(N)`; `<Tab>` expands and
collapses the thread under the cursor (`zR`/`zM` work too). `dd` on a collapsed
thread stages deletion of every message in it. Grouping is by subject —
Himalaya's server-side threading (`UID THREAD`) is not supported by Gmail.

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
| `ga` / `gm` / `gc` | stage archive / move / copy | — (`ga` in compose: attach file) |
| `gr` / `gR` / `gf` | reply / reply all / forward | same |
| `gt` | download attachments | same |
| `<Tab>` | expand/collapse thread | — |
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

## Documentation

Full Vim help lives in `doc/correo.txt` (`:h correo`). The package directory
is not on `runtimepath` by itself; either add it, or generate tags manually:

```vim
:helptags /path/to/lua/plugin/correo/doc
```

## Tests

```sh
nvim -l tests/run.lua
```

No dependencies: a stub `himalaya` in `tests/bin` answers with fixtures and
logs its argv, so no real mailbox is touched.

## Architecture

`cli.lua` (async runner, knows nothing about email) → `himalaya.lua` (the only
module that knows Himalaya's flags/JSON) → `mailbox.lua` / `message.lua` /
`compose.lua` (buffer state) with `render.lua` (pure formatting),
`highlights.lua`, `help.lua` and `excmd.lua`. See `PLAN.md` for the roadmap.
