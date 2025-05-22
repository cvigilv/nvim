# `nvim`

My personal Neovim config, that aims at:

- Minimizing the amount of external plugins
- Make use of builtins as much as possible
- Extend whatever is crucial for my workflow

No more, no less. just a simple config that I would consider "feature complete".

# Overview
## PKM

> This is the most important aspect of my configuration, since I'm a scientist and I write *a lot*. I need a way to easily traverse my notes, handle new information and keep up with all the things that happend both in my profesional and personal life. This is _always changing_ since whenever I find a small pain-point on my PKM, I tackle it as fast as possible for it to not be a distraction. Currently writing an extensive blog post on how it works, since I find it useful to see other peoples workflows to improve mine.

Using a combination of [nvim-orgmode](https://github.com/nvim-orgmode/orgmode) and [denote.nvim](https://github.com/cvigilv/denote.nvim) to manage my notes, journal and tasks. Additionally, I use org-modern for a fancy orgmode menu and RLDX.nvim for managing my contacts within my notes.

<img width="912" alt="Screenshot 2025-05-22 at 11 51 29 PM" src="https://github.com/user-attachments/assets/503cdddc-31d0-475e-ba60-94fcec7b67c5" />
Custom `cursorcolumn` to align content in org files.

<img width="912" alt="Screenshot 2025-05-22 at 11 45 22 PM" src="https://github.com/user-attachments/assets/3f9fc15d-70ac-4d16-9966-bd36dce36f40" />
`denote.nvim` highlighted `oil.nvim` buffer

<img width="912" alt="Screenshot 2025-05-22 at 11 44 39 PM" src="https://github.com/user-attachments/assets/0ce5b6b5-82f6-486e-9aba-a682b63a2937" />
`denote.nvim` picker based on `telescope.nvim`, with respective highlight and field matching

<img width="912" alt="Screenshot 2025-05-22 at 11 57 03 PM" src="https://github.com/user-attachments/assets/a089b301-16fc-41dc-8f85-4c4978c95492" />
Custom highlighting for orgmode capture buffers

<img width="912" alt="Screenshot 2025-05-23 at 12 10 31 AM" src="https://github.com/user-attachments/assets/33833b49-f3c0-4ad9-a70f-9a99ce7e424c" />
GTD-inspired orgmode agenda buffer.

## LLM

> I'm personally not a big fan of LLMs for coding, since I have felt I lost some of my capabilities on learning a code base and coming up with solution to things. Still trying to come up with a workflow that works with me, and if whether I should use a mainstream plugin or implement my own little chat interface (since I want some special behaviours that are non-trivial to implement with current chat plugins).

Using [CodeCompanion.nvim](https://github.com/olimorris/codecompanion.nvim) plus a some custom code to have a "sliding window" with a chat, that way I can have my code + REPL + chat all in one window/tab. This has been my favorite way to work up until now, since I can context-switch to the LLM chat window whenever I have a question.

| Open | Closed |
|:-:|:-:|
| <img width="913" alt="Screenshot 2025-05-23 at 12 22 01 AM" src="https://github.com/user-attachments/assets/6ecae578-b784-4e01-8ff8-65a526561ba6" /> | <img width="913" alt="Screenshot 2025-05-23 at 12 22 03 AM" src="https://github.com/user-attachments/assets/27ed2504-471c-4db3-aeed-d6ff32911ba1" /> |

<img width="1806" alt="Screenshot 2025-05-23 at 12 20 06 AM" src="https://github.com/user-attachments/assets/37460aa8-107f-471c-b7cf-a14ae1c8c86e" />
Current workflow for coding with REPL and chat.

## Navigation

I use a combination of Navigation.nvim + swm.nvim (to move between neovim floating and non-floating windows & tmux panes seamlessly), telescope.nvim and oil.nvim. 

Very minimal setup, with no previews in telescope and previews in oil.nvim. As before, special background for oil.nvim to differentiate from the rest of the window.

<img width="912" alt="Screenshot 2025-05-23 at 12 34 38 AM" src="https://github.com/user-attachments/assets/0961bfc4-9980-4d46-9880-e8a9d00aac75" />
Oil buffer + preview

<img width="913" alt="Screenshot 2025-05-23 at 12 27 04 AM" src="https://github.com/user-attachments/assets/dcd49d8a-4964-4a32-92e6-2563528687e8" />
File picker

<img width="913" alt="Screenshot 2025-05-23 at 12 29 37 AM" src="https://github.com/user-attachments/assets/c6b85c79-cb98-4d9c-8daa-acf7e6a92d8b" />
Live Grep

and the rest is the same, so I won't go overboard boring ypou with more screenshots.

## Misc
I'm using the classic stack of dependencies + LSP + completion + tooling packages:

- lazy.nvim
- mason.nvim
- lsp-config
- mason-lspconfig
- conform.nvim
- nvim-lint
- cmp.nvim + luasnip.nvim
- mini.nvim

some more niche plugins:

- esqueleto.nvim
- quicker.nvim
- scrollEOF.nvim
- neogen.nvim

and some things for neovim plugin development:
- luadev.nvim
- luapad.nvim

  
### [lazy.nvim](github.com/folke/lazy.nvim)

<img width="913" alt="Screenshot 2025-05-23 at 12 23 53 AM" src="https://github.com/user-attachments/assets/94aa5309-ee1c-4a40-b0df-20c130351317" />

<img width="913" alt="Screenshot 2025-05-23 at 12 23 56 AM" src="https://github.com/user-attachments/assets/21bae111-9e38-43ba-a324-52f81761801e" />

### Mason

<img width="913" alt="Screenshot 2025-05-23 at 12 24 59 AM" src="https://github.com/user-attachments/assets/8eeef57e-2178-4e4a-94dd-ac3b05f3968a" />

