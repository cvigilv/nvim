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
- [x] **Step 3 — Mutations (oil-style commit on `:w`).** Mailbox is modifiable via
  `acwrite`/`BufWriteCmd`: deleting a line (`dd`) stages a delete (detected by invalidated
  identity extmarks, not text parsing; `u` unstages); `ga` stages/unstages archive (move to
  `archive_folder`), `gm` stages/unstages a move (folder picked via `vim.ui.select`), shown
  as virtual text. `:w` shows a confirmation summary, then runs `message delete|move`
  grouped per operation and refreshes. Draws are excluded from undo history so `u` can never
  invalidate the whole listing.
- [x] **Step 4 — Compose: reply, forward, write.** `template reply|forward|write` → editable
  buffer at `/tmp/<account>.<kind>.<id>` (`filetype=mail`, cursor at template's body start) →
  `:w` confirms then sends via `template send`; declining keeps the draft on disk. Entry
  points: `gr`/`gR`/`gf` in mailbox and message buffers, `:CorreoWrite [account]` for new
  messages. Himalaya never spawns its own editor.
- [x] **Step 5 — Search and filter.** `:CorreoSearch <query>` filters/sorts the current
  mailbox via `envelope list [QUERY]` (no args clears); active query and page are shown as a
  virtual info line. Paging with `]]`/`[[` (past-the-end reverts gracefully); `gF`/`gA` pick
  a folder/account via `vim.ui.select`. All listing changes are blocked while operations are
  staged.
- [x] **Step 6 — Public API polish.** `init.lua` API (`open`/`search`/`write`), buffer
  actions exposed as user commands (see backlog entry), `g?` help overlay listing the live
  keymap configuration per buffer kind, README.md documenting commands/keymaps/config.
- [x] **Backlog — expose buffer actions as user commands.** Done in step 6: `:CorreoOpen`,
  `:CorreoSeen`, `:CorreoUnseen`, `:CorreoArchive`, `:CorreoMove`, `:CorreoReply[!]`,
  `:CorreoForward` dispatch to the mailbox or message implementation based on the current
  buffer.
- [x] **Backlog — verbose staged-operation display.** Done: staged rows get a whole-line
  background (`CorreoStagedLine` → Visual) and the target folder is shown right-aligned in
  bold (`CorreoStaged`).
- [x] **Backlog — Gmail labels via staged copy.** Done: `gc` / `:CorreoCopy [folder]` stage
  a copy (shown as `+ folder`), committed with `message copy`. Per-message label listing
  remains impossible (Himalaya lacks X-GM-LABELS support).
- [x] **Backlog — customizable mailbox view.** Done: `ui.mailbox.format` statusline-style
  string (`%u` unread, `%F` flagged, `%a` attachment, `%d` date, `%f` sender, `%s` subject,
  literals kept verbatim) drives `render.lua`; default `"%u%F%a%d%f  %s"` reproduces the
  original layout.
- [x] **Step 7 — Unit tests.** `tests/run.lua`, run with `nvim -l tests/run.lua`: zero
  external deps, a stub `himalaya` binary (tests/bin) answers with fixtures and logs argv.
  Covers `render.lua` (formats, widths, spans), `cli.lua` (json/text/stdin/error paths),
  `himalaya.lua` (argv shape, stdin templates), and the mailbox state machine (draw,
  dd/undo staging, archive/move/copy toggles, mocked-confirm commit, query rename, reload,
  past-end paging).

## Study: email threads (single line, expand on Tab)

Findings (2026-07-19, himalaya v1.1.0 against Gmail IMAP):

- `envelope thread` and `message thread` both exist in the CLI but **panic against Gmail**:
  they require the IMAP `UID THREAD` extension (RFC 5256), which Gmail does not implement
  ("Unknown command: UID THREAD", email-lib 0.26.4 unwraps the error). Server-side threading
  is therefore unavailable for both accounts until upstream adds a client-side fallback.
- True header threading (Message-ID/References) client-side would need one `message read -H`
  per envelope — O(page_size) CLI round-trips per refresh. Not viable.
- Viable approach: **client-side grouping by normalized subject** (strip `Re:`/`Fwd:`/`RE:`
  prefixes, case-fold), the same heuristic Gmail's own UI largely uses. Zero extra CLI calls;
  false merges possible for unrelated mails sharing a subject (acceptable trade-off).

Proposed design (not yet implemented):

- [ ] **Threads as Vim folds.** Sort the listing so thread members are adjacent (groups by
  newest-member date desc, members chronological); create one manual fold per multi-message
  group. `foldtext` (chunk-style, nvim 0.10+) renders the single-line summary:
  `▸ subject (N) · date · senders`. `<Tab>` toggles the fold under the cursor; `zR`/`zM`
  work for free. Config: `ui.mailbox.threads = false` default.
- Why folds instead of redraw-based expand/collapse: every line and identity extmark exists
  whether folded or not, so the staging model is untouched — `dd` on a collapsed thread
  stages deletion of the whole thread, `:w` commits it; no new state machine, no
  pending-changes conflicts, no special-casing in `gather_operations`.

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
