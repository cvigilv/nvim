" doric-lilac.vim -- Minimalist theme with light background and green+purple hues
" Ported from the doric-lilac Emacs theme by Protesilaos Stavrou
" https://github.com/protesilaos/doric-themes
" License: GPL-3.0-or-later (same as upstream)

" Palette:
"   cursor            #a07f50
"   bg-main           #f2f0e7    fg-main           #1a3530
"   border            #8f9373
"   bg-shadow-subtle  #e7e2d7    fg-shadow-subtle  #6e522a
"   bg-neutral        #d5cbc7    fg-neutral        #53402f
"   bg-shadow-intense #c7c0e4    fg-shadow-intense #5b4295
"   bg-accent         #cfe4c7    fg-accent         #435a00
"   fg red #982500  green #226700  yellow #595000
"      blue #103077 magenta #700054 cyan #005460
"   bg red #e3b8a0  green #b8caa0  yellow #dfc085
"      blue #c4c8dd magenta #d8bade cyan #bee0db

hi clear
if exists('syntax_on')
  syntax reset
endif
set background=light
let g:colors_name = 'doric-lilac'

" UI
hi Normal guifg=#1a3530 guibg=#f2f0e7 gui=NONE cterm=NONE
hi Cursor guifg=#f2f0e7 guibg=#a07f50 gui=NONE cterm=NONE
hi CursorLine guifg=NONE guibg=#cfe4c7 gui=NONE cterm=NONE
hi CursorColumn guifg=NONE guibg=#cfe4c7 gui=NONE cterm=NONE
hi ColorColumn guifg=NONE guibg=#e7e2d7 gui=NONE cterm=NONE
hi LineNr guifg=#6e522a guibg=NONE gui=NONE cterm=NONE
hi CursorLineNr guifg=#1a3530 guibg=NONE gui=bold cterm=bold
hi SignColumn guifg=#435a00 guibg=NONE gui=NONE cterm=NONE
hi FoldColumn guifg=#6e522a guibg=NONE gui=NONE cterm=NONE
hi Folded guifg=#6e522a guibg=#e7e2d7 gui=NONE cterm=NONE
hi VertSplit guifg=#8f9373 guibg=NONE gui=NONE cterm=NONE
hi WinSeparator guifg=#8f9373 guibg=NONE gui=NONE cterm=NONE
hi StatusLine guifg=#5b4295 guibg=#c7c0e4 gui=NONE cterm=NONE
hi StatusLineNC guifg=#6e522a guibg=#e7e2d7 gui=NONE cterm=NONE
hi TabLine guifg=#53402f guibg=#d5cbc7 gui=NONE cterm=NONE
hi TabLineSel guifg=#1a3530 guibg=#f2f0e7 gui=bold cterm=bold
hi TabLineFill guifg=NONE guibg=#e7e2d7 gui=NONE cterm=NONE
hi Pmenu guifg=#6e522a guibg=#e7e2d7 gui=NONE cterm=NONE
hi PmenuSel guifg=#1a3530 guibg=#cfe4c7 gui=NONE cterm=NONE
hi PmenuSbar guifg=NONE guibg=#e7e2d7 gui=NONE cterm=NONE
hi PmenuThumb guifg=NONE guibg=#8f9373 gui=NONE cterm=NONE
hi WildMenu guifg=#1a3530 guibg=#cfe4c7 gui=NONE cterm=NONE
hi NormalFloat guifg=#1a3530 guibg=#e7e2d7 gui=NONE cterm=NONE
hi FloatBorder guifg=#8f9373 guibg=#e7e2d7 gui=NONE cterm=NONE
hi Visual guifg=#5b4295 guibg=#c7c0e4 gui=NONE cterm=NONE
hi VisualNOS guifg=#5b4295 guibg=#c7c0e4 gui=NONE cterm=NONE
hi Search guifg=#6e522a guibg=NONE gui=italic,underline cterm=italic,underline
hi IncSearch guifg=#1a3530 guibg=#c7c0e4 gui=NONE cterm=NONE
hi CurSearch guifg=#1a3530 guibg=#c7c0e4 gui=NONE cterm=NONE
hi MatchParen guifg=#5b4295 guibg=#c7c0e4 gui=NONE cterm=NONE
hi QuickFixLine guifg=NONE guibg=#cfe4c7 gui=NONE cterm=NONE
hi NonText guifg=#c7c0e4 guibg=NONE gui=NONE cterm=NONE
hi SpecialKey guifg=#c7c0e4 guibg=NONE gui=NONE cterm=NONE
hi Whitespace guifg=#c7c0e4 guibg=NONE gui=NONE cterm=NONE
hi EndOfBuffer guifg=#c7c0e4 guibg=NONE gui=NONE cterm=NONE
hi Conceal guifg=#6e522a guibg=NONE gui=NONE cterm=NONE
hi Directory guifg=#435a00 guibg=NONE gui=NONE cterm=NONE
hi Title guifg=#1a3530 guibg=NONE gui=bold cterm=bold
hi ErrorMsg guifg=#982500 guibg=NONE gui=bold cterm=bold
hi WarningMsg guifg=#595000 guibg=NONE gui=bold cterm=bold
hi ModeMsg guifg=#1a3530 guibg=NONE gui=bold cterm=bold
hi MoreMsg guifg=#5b4295 guibg=NONE gui=bold cterm=bold
hi Question guifg=#5b4295 guibg=NONE gui=bold cterm=bold

" Syntax
hi Comment guifg=#435a00 guibg=NONE gui=italic cterm=italic
hi Constant guifg=#1a3530 guibg=NONE gui=NONE cterm=NONE
hi String guifg=#6e522a guibg=NONE gui=NONE cterm=NONE
hi Character guifg=#6e522a guibg=NONE gui=NONE cterm=NONE
hi Number guifg=#1a3530 guibg=NONE gui=NONE cterm=NONE
hi Boolean guifg=#1a3530 guibg=NONE gui=NONE cterm=NONE
hi Float guifg=#1a3530 guibg=NONE gui=NONE cterm=NONE
hi Identifier guifg=#1a3530 guibg=NONE gui=italic cterm=italic
hi Function guifg=#5b4295 guibg=NONE gui=NONE cterm=NONE
hi Statement guifg=#5b4295 guibg=NONE gui=bold cterm=bold
hi Operator guifg=#5b4295 guibg=NONE gui=bold cterm=bold
hi PreProc guifg=#6e522a guibg=NONE gui=bold,italic cterm=bold,italic
hi Type guifg=#6e522a guibg=NONE gui=bold,italic cterm=bold,italic
hi Special guifg=#5b4295 guibg=NONE gui=NONE cterm=NONE
hi Delimiter guifg=#1a3530 guibg=NONE gui=NONE cterm=NONE
hi Underlined guifg=#435a00 guibg=NONE gui=underline cterm=underline
hi Ignore guifg=#c7c0e4 guibg=NONE gui=NONE cterm=NONE
hi Error guifg=#982500 guibg=#e3b8a0 gui=NONE cterm=NONE
hi Todo guifg=#595000 guibg=NONE gui=bold,italic cterm=bold,italic

" Diff
hi DiffAdd guifg=#53402f guibg=#a7bd89 gui=NONE cterm=NONE
hi DiffChange guifg=#53402f guibg=#d8b169 gui=NONE cterm=NONE
hi DiffDelete guifg=#53402f guibg=#daa282 gui=NONE cterm=NONE
hi DiffText guifg=NONE guibg=#e6cfa1 gui=bold cterm=bold
hi Added guifg=#226700 guibg=NONE gui=NONE cterm=NONE
hi Changed guifg=#595000 guibg=NONE gui=NONE cterm=NONE
hi Removed guifg=#982500 guibg=NONE gui=NONE cterm=NONE
hi! link diffAdded Added
hi! link diffChanged Changed
hi! link diffRemoved Removed

" Spell
hi SpellBad guifg=NONE guibg=NONE gui=undercurl cterm=undercurl guisp=#982500
hi SpellCap guifg=NONE guibg=NONE gui=undercurl cterm=undercurl guisp=#595000
hi SpellRare guifg=NONE guibg=NONE gui=undercurl cterm=undercurl guisp=#700054
hi SpellLocal guifg=NONE guibg=NONE gui=undercurl cterm=undercurl guisp=#005460

" Diagnostics (Neovim; harmless in Vim)
hi DiagnosticError guifg=#982500 guibg=NONE gui=NONE cterm=NONE
hi DiagnosticWarn guifg=#595000 guibg=NONE gui=NONE cterm=NONE
hi DiagnosticInfo guifg=#103077 guibg=NONE gui=NONE cterm=NONE
hi DiagnosticHint guifg=#005460 guibg=NONE gui=NONE cterm=NONE
hi DiagnosticOk guifg=#226700 guibg=NONE gui=NONE cterm=NONE
hi DiagnosticUnderlineError guifg=NONE gui=undercurl cterm=undercurl guisp=#982500
hi DiagnosticUnderlineWarn guifg=NONE gui=undercurl cterm=undercurl guisp=#595000
hi DiagnosticUnderlineInfo guifg=NONE gui=undercurl cterm=undercurl guisp=#103077
hi DiagnosticUnderlineHint guifg=NONE gui=undercurl cterm=undercurl guisp=#005460

" Terminal colors
if has('nvim')
  let g:terminal_color_0 = '#1a3530'
  let g:terminal_color_1 = '#982500'
  let g:terminal_color_2 = '#226700'
  let g:terminal_color_3 = '#595000'
  let g:terminal_color_4 = '#103077'
  let g:terminal_color_5 = '#700054'
  let g:terminal_color_6 = '#005460'
  let g:terminal_color_7 = '#b3b3b3'
  let g:terminal_color_8 = '#4d4d4d'
  let g:terminal_color_9 = '#982500'
  let g:terminal_color_10 = '#226700'
  let g:terminal_color_11 = '#595000'
  let g:terminal_color_12 = '#103077'
  let g:terminal_color_13 = '#700054'
  let g:terminal_color_14 = '#005460'
  let g:terminal_color_15 = '#ffffff'
else
  let g:terminal_ansi_colors = [
        \ '#1a3530', '#982500', '#226700', '#595000',
        \ '#103077', '#700054', '#005460', '#b3b3b3',
        \ '#4d4d4d', '#982500', '#226700', '#595000',
        \ '#103077', '#700054', '#005460', '#ffffff',
        \ ]
endif
