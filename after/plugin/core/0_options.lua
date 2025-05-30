-- General configuration
vim.opt.autochdir = false -- Don't change current working directory to wherever is the file
vim.opt.autoread = true -- Update files that change by external processes
vim.opt.backup = false -- Don't create backup files
vim.opt.background = "light" -- Use light background by default
vim.opt.clipboard = "unnamedplus" -- Copy paste between vim and everything else
vim.opt.completeopt = "menu,menuone,noselect" -- Improve completion UX
vim.opt.conceallevel = 0 -- Don't hide formatting characters
vim.opt.colorcolumn = "" -- Managed by "afuera.nvim"
vim.opt.cursorline = true -- Highlight current line
vim.opt.diffopt = "internal,filler,closeoff,linematch:60"
vim.opt.fileencoding = "UTF-8" -- Character encoding for the file in the buffer
vim.opt.fillchars = { -- Characters used for UI things
  -- Window splitting
  -- vert = "┃",
  -- vertleft = "┫",
  -- vertright = "┣",
  -- verthoriz = "╋",
  -- horiz = "━",
  -- horizup = "┻",
  -- horizdown = "┳",

  vert = " ",
  vertleft = " ",
  vertright = " ",
  verthoriz = " ",
  horiz = " ",
  horizup = " ",
  horizdown = " ",

  -- Fold
  fold = " ",
  foldopen = "",
  foldsep = " ",
  foldclose = "",

  -- Other
  diff = "╱",
  eob = " ",
}
vim.opt.foldmethod = "marker" -- Automatically fold text in marker
vim.opt.laststatus = 2 -- Per-window statusline
vim.opt.list = true -- See whitespaces in current buffer
vim.opt.listchars = "trail:∘,nbsp:‼,tab:╎ ,multispace: ,extends:…"
vim.opt.mouse = "a" -- Activate mouse
vim.opt.number = true -- Add line numbering
vim.opt.relativenumber = true -- Add relative numbering, this is a must in my opinion
vim.opt.scrolloff = 8 -- Leave some lines in the top and end of the file to have context
vim.opt.shiftwidth = 4 -- If tab character is found, show as indent of size equal to 4 spaces
vim.opt.shortmess = vim.opt.shortmess + "c" -- Avoid showing message when using completion
vim.opt.showmode = false -- Don't show the standard vim mode indicator at the end of the file
vim.opt.showtabline = 2 -- Always show tabline
vim.opt.signcolumn = "no" -- Never add the sign column, handled by statuscolumn
vim.opt.smartcase = true -- Smart case sensitivity for easier searching
vim.opt.smartindent = true -- Autoindent for C-like style programs
vim.opt.softtabstop = 4 -- Tabs are actually 4 spaces
vim.opt.splitbelow = true -- Horizontal splitting will be automatically placed on the botom
vim.opt.splitright = true -- Vertical splitting will be automatically placed on the right
vim.opt.swapfile = false -- Don't create swap files
vim.opt.tabstop = 4 -- Tab of size equal to 4 spaces
vim.opt.termguicolors = true -- Use GUI colors
vim.opt.textwidth = 0 -- Infinite text width by default
vim.opt.timeoutlen = 250 -- Amount of time to wait for mapped sequence to complete
vim.opt.undodir = os.getenv("HOME") .. "/.config/nvim/extras/undodir" -- Store undo files here
vim.opt.undofile = true -- Create undo files for undo-tree
vim.opt.wildmode = "longest,list,full" -- Completion mode used to showcase options
vim.opt.wrap = false -- Don't wrap text

-- Disable some in built plugins completely
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- vim.g.loaded_2html_plugin = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_logipat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_zipPlugin = 1

-- Providers
vim.g.python3_host_prog = "python3"
