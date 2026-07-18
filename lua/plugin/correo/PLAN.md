# correo.nvim

A Himalaya CLI UI for Neovim

## Plan

Main objective: Create a UI for Himalaya CLI inspired in oil.nvim, i.e. mailbox is a buffer,
which can be modified for deletion or moving files to other folders. We can open emails to
read, reply, forward or any other email-related action.

## How to implement

We will do this step by step, adding functionality as we go

First, we will implement the MVP. For this do the following (in no particualr order, tackle how
most sense it makes):

- Thoroughly study how oil.nvim implements its filesystem-as-a-buffer functionality
- Extract from oil.nvim the minimum functions to implement the functionality we want to
  implement here
- Implement mailbox-as-a-buffer UI
- Implement "read", "reply", "forward", "delete" and "archive" functions from Himalaya CLI
- Implement "search" and "filter" functions to navigate and manage emails
- Implement the API and usercommands to access all of this functionality
- Add unit tests to cover all of this

## Implementation steps

Each step is a vertical slice that ends in a working, testable state. Stop after each one so it
can be tested manually and committed.

- [x] **Step 1 — Async CLI core + read-only mailbox.** `cli.lua` (generic async runner over
  `vim.system`, JSON decoding), `himalaya.lua` (backend adapter: list envelopes/folders/
  accounts), `render.lua` (envelope → line + highlight spans), `highlights.lua`,
  `mailbox.lua` (buffer at `correo://<account>/<folder>`, non-modifiable, per-line identity
  extmarks, `R` to refresh), `excmd.lua` (`:Correo [folder]` with cached folder completion).
- [x] **Step 2 — Message reading.** `<CR>` on an envelope opens the message in a buffer at
  `/tmp/<account>.<id>` with `filetype=mail` via `message read`; opening marks the message
  seen (like any mail client). Keymaps: toggle seen (`gs`), mark unseen (`gS`), back to
  mailbox (`q`). `ui.message.open` picks replace vs 20/80 split display.
- [ ] **Step 3 — Mutations (oil-style commit on `:w`).** Mailbox becomes modifiable via
  `acwrite`/`BufWriteCmd`: deleting a line stages a delete (detected by vanished identity
  extmarks, not text parsing); keymaps stage move/archive/flag ops. `:w` shows a confirmation
  summary, then runs `message delete|move` / `flag add|remove` and refreshes.
- [ ] **Step 4 — Compose: reply, forward, write.** `template reply|forward|write` → editable
  buffer (`filetype=mail`) → send on `:w` (confirm first) via `template send` reading the
  buffer as the raw template. Never let Himalaya spawn its own editor.
- [ ] **Step 5 — Search and filter.** `:Correo` grows a query argument mapped to
  `envelope list [QUERY]`; folder/account switching from within the mailbox; paging keymaps.
- [ ] **Step 6 — Public API polish.** Round out `init.lua` API (open/read/compose/search),
  document keymaps, help/`g?` overlay.
- [ ] **Backlog — customizable mailbox view.** `ui.mailbox.format` config entry: a
  statusline-style flag string (e.g. `"%u%F%a %d  %f  %s"` → unread, flagged, attachment,
  date, from, subject) that drives `render.lua`. The current fixed column layout becomes the
  default value of that string. Revisit after the MVP slices.
- [ ] **Step 7 — Unit tests.** Headless `nvim -l` test harness (no external deps, per rules):
  cover `render.lua` formatting, `cli.lua` result normalization, argv building in
  `himalaya.lua`, and mailbox state transitions with a stubbed CLI.

## Architecture

- `cli.lua` knows nothing about email: it runs an argv asynchronously and normalizes
  results/JSON. `himalaya.lua` is the only module that knows Himalaya's flags and JSON shapes,
  so the backend can be swapped at a single seam.
- `mailbox.lua` owns buffer state; `render.lua` is pure (envelope → text + spans); highlight
  groups live in `highlights.lua`; user commands in `excmd.lua` (mirrors sibling `contacto`).
- Buffer identity per line is an extmark carrying the envelope id — mutations are derived from
  extmarks and staged ops, never from parsing line text (fragile with arbitrary subjects).

## Design

- Email buffers have to live in the /tmp directory and named under the account and mail ID, e.g. "<account>.<id>"
- Vim has a "mail" filetype (headers, quote levels, signatures), use that for message and
  compose buffers

## Rules

- Maintain the structure we already have in this directory
- Dont rely on anything outside this directory, if you need to copy something, do it
- Add docstrings in EmmyLua style everywhere, no matter how complex or long the functions are
- Aim to have atomic functions, maximum 50 lines. Add comments as it makes sense, to give
  insight into a chunk of code or to give guidance on what is happening on a given step.
  Function naming should be verbs indicating what the function does. If a variable is temporal,
  prepend an underscore. Structures always are capitalized. 
- Dont repeat yourself but dont go overboard extracting everything into functions. Aim to make the code as idiomatic 
  and legible as possible.
- Keep it simple, do make things complex for the sake of it
- Create interfaces for the CLI under a single architecture, so we can easily extend this in the
  future.
- Text is the main interface of the package. That said, implement some coloring with Vim
  highlight capabilities for relevant things.
