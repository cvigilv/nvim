# `nvim`

@test

new neovim config, aiming for:

- 15 external plugins max (not counting lsp and completion things, does require lots of plugins to work properly...)
- make use of nvim builtins as much as possible
- extend whatever is crucial

no more, no less. just a simple config that I would consider "feature complete"

> failing miserably on the above points, but at least I'm trying...

# structure

```
.
├── after
│   ├── ftplugin
│   └── plugin
├── colors
├── extras
│   ├── pkgs                   # lazy.nvim related files
│   ├── prompts                # prompts used by `cvigilv/claudio.nvim`
│   │   └── tools
│   ├── skeletons              # templates used by `cvigilv/esqueleto.nvim`
│   │   ├── personal
│   │   └── protera
│   ├── snippets               # snippets (don't use them very much)
│   └── undodir                # undo history files
├── lua
│   ├── plugin                 # personal plugins
│   │   └── zk                 # personal note-taking system plugin
│   └── user
│       ├── core               # core stuf of my config
│       ├── helpers            # all the helper function I need
│       │   ├── statuscolumn
│       │   ├── statusline
│       │   ├── tabline
│       │   ├── ui
│       │   └── winbar
│       └── pkgs               # lazy.nvim managed plugins
└── spell

```

# screenshots

## normal

<img width="1022" alt="Screenshot 2024-12-08 at 11 53 54 PM" src="https://github.com/user-attachments/assets/7e15a33f-bc41-43cb-b196-a8a3df7c1d3b">
<img width="1022" alt="Screenshot 2024-12-08 at 11 55 15 PM" src="https://github.com/user-attachments/assets/602bed2d-1523-4afe-ae4a-b31f2689c7e3">
<img width="1022" alt="Screenshot 2024-12-08 at 11 54 01 PM" src="https://github.com/user-attachments/assets/b4fe2716-dd4b-440c-81c8-ff158d6b325e">
<img width="1022" alt="Screenshot 2024-12-08 at 11 56 40 PM" src="https://github.com/user-attachments/assets/ff4c4147-470a-4c4d-9645-8af697db7d76">

## git integration

just commit messages ux improvements via my diferente.nvim plugin and gitsigns.nvim

<img width="1022" alt="Screenshot 2024-12-09 at 12 04 31 AM" src="https://github.com/user-attachments/assets/0d73c27d-bac9-460b-910f-0f5d9724040d">
<img width="1022" alt="Screenshot 2024-12-09 at 12 04 36 AM" src="https://github.com/user-attachments/assets/eb209258-ad6d-4bd1-b598-3d65a93a2e7f">
<img width="1022" alt="Screenshot 2024-12-09 at 12 06 49 AM" src="https://github.com/user-attachments/assets/de0ce494-40cc-4adc-9ab3-ef5ce5dfa05e">

## chat/llm integration

working on a personal plugin for this (wip, very early in development; but its called claudio.nvim)

<img width="1710" alt="Screenshot 2024-12-09 at 12 10 27 AM" src="https://github.com/user-attachments/assets/6b62cb2b-9518-4aac-94d2-dbc845410fbb">

## note-taking system

> NOTE: this is highly custom for my needs, so I won't be sharing this as a plugin (for now) but you can steal it from this config.

<img width="1022" alt="Screenshot 2024-12-09 at 12 06 49 AM" src="https://github.com/user-attachments/assets/0e8227be-f56a-4005-9821-59e10c066e8f">
<img width="1022" alt="Screenshot 2024-12-08 at 11 54 08 PM" src="https://github.com/user-attachments/assets/9d7a8f8c-af17-4837-b763-a680b19bf73a">
<img width="1022" alt="Screenshot 2024-12-08 at 11 57 47 PM" src="https://github.com/user-attachments/assets/178c4614-2383-40ce-b8e8-36233c92e01f">

## boring stuff

<img width="1022" alt="Screenshot 2024-12-08 at 11 58 32 PM" src="https://github.com/user-attachments/assets/f5632219-fa03-48a9-83da-019c88dcf392">
<img width="1022" alt="Screenshot 2024-12-08 at 11 59 05 PM" src="https://github.com/user-attachments/assets/7c5c246d-0f2b-49ac-a71e-a2f2ec342bcf">
