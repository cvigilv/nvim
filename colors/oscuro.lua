---@module "colors.oscuro"
---@author Carlos Vigil-Vásquez
---@license MIT 2026

vim.cmd("highlight clear")
vim.g.color_name="oscuro"

local lush = require("lush")
local hsl = lush.hsl
local hsluv = lush.hsluv
local theme = lush(function(injected_functions)
  local sym = injected_functions.sym
  return {
    Normal                                  { fg="#c6d5cf", bg="#091217" },
    -- Normal                                  { fg="nvimlightgrey1", bg="#091217" },
    OutOfBounds                             { bg="#0f191f" },
    SpecialKey                              { fg="nvimdarkgrey4", }, -- SpecialKey     xxx guifg=NvimDarkGrey4
    TermCursor                              { gui="reverse", }, -- TermCursor     xxx cterm=reverse gui=reverse
    NonText                                 { fg="nvimdarkgrey4", }, -- NonText        xxx guifg=NvimDarkGrey4
    EndOfBuffer                             { NonText }, -- EndOfBuffer    xxx links to NonText
    Whitespace                              { NonText }, -- Whitespace     xxx links to NonText
    LspCodeLens                             { NonText }, -- LspCodeLens    xxx links to NonText
    LspInlayHint                            { NonText }, -- LspInlayHint   xxx links to NonText
    TelescopeResultsDiffUntracked           { NonText }, -- TelescopeResultsDiffUntracked xxx links to NonText
    TelescopePromptCounter                  { NonText }, -- TelescopePromptCounter xxx links to NonText
    TelescopePreviewHyphen                  { NonText }, -- TelescopePreviewHyphen xxx links to NonText
    Directory                               { fg="nvimlightcyan", }, -- Directory      xxx ctermfg=14 guifg=NvimLightCyan
    TelescopePreviewDate                    { Directory }, -- TelescopePreviewDate xxx links to Directory
    TelescopePreviewDirectory               { Directory }, -- TelescopePreviewDirectory xxx links to Directory
    OilDir                                  { Directory }, -- OilDir         xxx links to Directory
    QuickFixFilename                        { Directory }, -- QuickFixFilename xxx links to Directory
    ErrorMsg                                { fg="nvimlightred", }, -- ErrorMsg       xxx ctermfg=9 guifg=NvimLightRed
    NvimInvalidSpacing                      { ErrorMsg }, -- NvimInvalidSpacing xxx links to ErrorMsg
    Search                                  { fg="nvimlightgrey1", bg="nvimdarkyellow", }, -- Search         xxx ctermfg=0 ctermbg=11 guifg=NvimLightGrey1 guibg=NvimDarkYellow
    Substitute                              { Search }, -- Substitute     xxx links to Search
    TelescopePreviewMatch                   { Search }, -- TelescopePreviewMatch xxx links to Search
    CurSearch                               { fg="nvimdarkgrey1", bg="nvimlightyellow", }, -- CurSearch      xxx ctermfg=0 ctermbg=11 guifg=NvimDarkGrey1 guibg=NvimLightYellow
    IncSearch                               { CurSearch }, -- IncSearch      xxx links to CurSearch
    MoreMsg                                 { fg="nvimlightcyan", }, -- MoreMsg        xxx ctermfg=14 guifg=NvimLightCyan
    ModeMsg                                 { fg="nvimlightgreen", }, -- ModeMsg        xxx ctermfg=10 guifg=NvimLightGreen
    ModeArea                                { bg="black" },
    MsgArea                                 { bg="black" },
    LineNr                                  { fg="nvimdarkgrey4", }, -- LineNr         xxx guifg=NvimDarkGrey4
    LineNrAbove                             { LineNr }, -- LineNrAbove    xxx links to LineNr
    LineNrBelow                             { LineNr }, -- LineNrBelow    xxx links to LineNr
    TelescopeResultsLineNr                  { LineNr }, -- TelescopeResultsLineNr xxx links to LineNr
    QuickFixLineNr                          { LineNr }, -- QuickFixLineNr xxx links to LineNr
    CursorLineNr                            { gui="bold", }, -- CursorLineNr   xxx cterm=bold gui=bold
    Question                                { fg="nvimlightcyan", }, -- Question       xxx ctermfg=14 guifg=NvimLightCyan
    StatusLine                              { fg="#c6d5cf", bg="#1a2a33", bold=true }, -- StatusLine     xxx cterm=reverse guifg=NvimDarkGrey3 guibg=NvimLightGrey3
    MsgSeparator                            { StatusLine }, -- MsgSeparator   xxx links to StatusLine
    StatusLineTerm                          { StatusLine }, -- StatusLineTerm xxx links to StatusLine
    StatusLineNC                            { fg="#d1e0da", bg="#121f27", }, -- StatusLineNC   xxx cterm=bold,underline guifg=NvimLightGrey2 guibg=NvimDarkGrey4
    TabLine                                 { StatusLineNC }, -- TabLine        xxx links to StatusLineNC
    StatusLineTermNC                        { StatusLineNC }, -- StatusLineTermNC xxx links to StatusLineNC
    Title                                   { gui="bold", fg="nvimlightgreen" }, -- Title          xxx cterm=bold gui=bold guifg=NvimLightGrey2
    FloatTitle                              { Title }, -- FloatTitle     xxx links to Title
    DenoteTitle                             { Title }, -- DenoteTitle    xxx links to Title
    sym"@org.headline.level1"               { Title }, -- @org.headline.level1 xxx links to Title
    Visual                                  { bg="nvimdarkgrey4", }, -- Visual         xxx ctermfg=0 ctermbg=15 guibg=NvimDarkGrey4
    VisualNOS                               { Visual }, -- VisualNOS      xxx links to Visual
    LspReferenceText                        { Visual }, -- LspReferenceText xxx links to Visual
    LspSignatureActiveParameter             { Visual }, -- LspSignatureActiveParameter xxx links to Visual
    SnippetTabstop                          { Visual }, -- SnippetTabstop xxx links to Visual
    TelescopeSelection                      { Visual }, -- TelescopeSelection xxx links to Visual
    TelescopePreviewLine                    { Visual }, -- TelescopePreviewLine xxx links to Visual
    sym"@org.edit_src"                      { Visual }, -- @org.edit_src  xxx links to Visual
    WarningMsg                              { fg="nvimlightyellow", }, -- WarningMsg     xxx ctermfg=11 guifg=NvimLightYellow
    DenoteKeywords                          { WarningMsg }, -- DenoteKeywords xxx links to WarningMsg
    vimWarn                                 { WarningMsg }, -- vimWarn        xxx links to WarningMsg
    Folded                                  { }, -- Folded         xxx guifg=NvimLightGrey4 guibg=NvimDarkGrey1
    DiffAdd                                 { fg="nvimlightgrey1", bg="nvimdarkgreen", }, -- DiffAdd        xxx ctermfg=0 ctermbg=10 guifg=NvimLightGrey1 guibg=NvimDarkGreen
    TelescopeResultsDiffAdd                 { DiffAdd }, -- TelescopeResultsDiffAdd xxx links to DiffAdd
    DiffChange                              { fg="nvimlightgrey1", bg="nvimdarkgrey4", }, -- DiffChange     xxx guifg=NvimLightGrey1 guibg=NvimDarkGrey4
    TelescopeResultsDiffChange              { DiffChange }, -- TelescopeResultsDiffChange xxx links to DiffChange
    DiffDelete                              { gui="bold", fg="nvimlightred", }, -- DiffDelete     xxx cterm=bold ctermfg=9 gui=bold guifg=NvimLightRed
    TelescopeResultsDiffDelete              { DiffDelete }, -- TelescopeResultsDiffDelete xxx links to DiffDelete
    DiffText                                { fg="nvimlightgrey1", bg="nvimdarkcyan", }, -- DiffText       xxx ctermfg=0 ctermbg=14 guifg=NvimLightGrey1 guibg=NvimDarkCyan
    SignColumn                              { fg="nvimdarkgrey4", }, -- SignColumn     xxx guifg=NvimDarkGrey4
    CursorLineSign                          { SignColumn }, -- CursorLineSign xxx links to SignColumn
    FoldColumn                              { SignColumn }, -- FoldColumn     xxx links to SignColumn
    Conceal                                 { fg="nvimdarkgrey4", }, -- Conceal        xxx guifg=NvimDarkGrey4
    SpellBad                                { gui="undercurl", sp="nvimlightred", }, -- SpellBad       xxx cterm=undercurl gui=undercurl guisp=NvimLightRed
    SpellCap                                { gui="undercurl", sp="nvimlightyellow", }, -- SpellCap       xxx cterm=undercurl gui=undercurl guisp=NvimLightYellow
    SpellRare                               { gui="undercurl", sp="nvimlightcyan", }, -- SpellRare      xxx cterm=undercurl gui=undercurl guisp=NvimLightCyan
    SpellLocal                              { gui="undercurl", sp="nvimlightgreen", }, -- SpellLocal     xxx cterm=undercurl gui=undercurl guisp=NvimLightGreen
    Pmenu                                   { bg="nvimdarkgrey3", }, -- Pmenu          xxx cterm=reverse guibg=NvimDarkGrey3
    PmenuKind                               { Pmenu }, -- PmenuKind      xxx links to Pmenu
    PmenuExtra                              { Pmenu }, -- PmenuExtra     xxx links to Pmenu
    PmenuSbar                               { Pmenu }, -- PmenuSbar      xxx links to Pmenu
    PmenuSel                                { gui="reverse", blend=0, }, -- PmenuSel       xxx cterm=underline,reverse gui=reverse blend=0
    WildMenu                                { PmenuSel }, -- WildMenu       xxx links to PmenuSel
    PmenuKindSel                            { PmenuSel }, -- PmenuKindSel   xxx links to PmenuSel
    PmenuExtraSel                           { PmenuSel }, -- PmenuExtraSel  xxx links to PmenuSel
    PmenuMatch                              { gui="bold", }, -- PmenuMatch     xxx cterm=bold gui=bold
    PmenuMatchSel                           { gui="bold", }, -- PmenuMatchSel  xxx cterm=bold gui=bold
    PmenuThumb                              { bg="nvimdarkgrey4", }, -- PmenuThumb     xxx guibg=NvimDarkGrey4
    TabLineSel                              { Normal, gui="bold", }, -- TabLineSel     xxx gui=bold
    TabLineFill                             { bg="black", }, -- TabLineSel     xxx gui=bold
    CursorColumn                            { bg="nvimdarkgrey3", }, -- CursorColumn   xxx guibg=NvimDarkGrey3
    CursorLine                              { bg="nvimdarkgrey3", }, -- CursorLine     xxx guibg=NvimDarkGrey3
    ColorColumn                             { bg="nvimdarkgrey4", }, -- ColorColumn    xxx cterm=reverse guibg=NvimDarkGrey4
    QuickFixLine                            { fg="nvimlightcyan", }, -- QuickFixLine   xxx ctermfg=14 guifg=NvimLightCyan
    NormalFloat                             { OutOfBounds }, -- NormalFloat    xxx guibg=NvimDarkGrey1
    FloatBorder                             { NormalFloat }, -- FloatBorder    xxx links to NormalFloat
    WhichKeyNormal                          { NormalFloat }, -- WhichKeyNormal xxx links to NormalFloat
    WinBar                                  { gui="bold", fg="nvimlightgrey4", bg="nvimdarkgrey1", }, -- WinBar         xxx cterm=bold gui=bold guifg=NvimLightGrey4 guibg=NvimDarkGrey1
    WinBarNC                                { fg="nvimlightgrey4", bg="nvimdarkgrey1", }, -- WinBarNC       xxx cterm=bold guifg=NvimLightGrey4 guibg=NvimDarkGrey1
    Cursor                                  { fg="bg", bg="fg", }, -- Cursor         xxx guifg=bg guibg=fg
    CursorIM                                { Cursor }, -- CursorIM       xxx links to Cursor
    RedrawDebugNormal                       { gui="reverse", }, -- RedrawDebugNormal xxx cterm=reverse gui=reverse
    Underlined                              { gui="underline", }, -- Underlined     xxx cterm=underline gui=underline
    lCursor                                 { fg="bg", bg="fg", }, -- lCursor        xxx guifg=bg guibg=fg
    WinSeparator                            { Normal }, -- WinSeparator   xxx links to Normal
    Ignore                                  { Normal }, -- Ignore         xxx links to Normal
    NvimSpacing                             { Normal }, -- NvimSpacing    xxx links to Normal
    TelescopeNormal                         { Normal }, -- TelescopeNormal xxx links to Normal
    vimVar                                  { Normal }, -- vimVar         xxx links to Normal
    vimUserFunc                             { Normal }, -- vimUserFunc    xxx links to Normal
    vimEmbedError                           { Normal }, -- vimEmbedError  xxx links to Normal
    WhichKeyIconGrey                        { Normal }, -- WhichKeyIconGrey xxx links to Normal
    Constant                                { fg="nvimlightgrey1" }, -- Constant       xxx guifg=NvimLightGrey1
    Character                               { Constant }, -- Character      xxx links to Constant
    Number                                  { Constant }, -- Number         xxx links to Constant
    Boolean                                 { Constant }, -- Boolean        xxx links to Constant
    sym"@constant"                          { Constant }, -- @constant      xxx links to Constant
    TelescopePreviewGroup                   { Constant }, -- TelescopePreviewGroup xxx links to Constant
    TelescopePreviewCharDev                 { Constant }, -- TelescopePreviewCharDev xxx links to Constant
    TelescopePreviewRead                    { Constant }, -- TelescopePreviewRead xxx links to Constant
    TelescopePreviewPipe                    { Constant }, -- TelescopePreviewPipe xxx links to Constant
    TelescopePreviewBlock                   { Constant }, -- TelescopePreviewBlock xxx links to Constant
    TelescopePreviewUser                    { Constant }, -- TelescopePreviewUser xxx links to Constant
    TelescopeResultsConstant                { Constant }, -- TelescopeResultsConstant xxx links to Constant
    vim9Null                                { Constant }, -- vim9Null       xxx links to Constant
    vimSleepArg                             { Constant }, -- vimSleepArg    xxx links to Constant
    vimHiCtermColor                         { Constant }, -- vimHiCtermColor xxx links to Constant
    luaConstant                             { Constant }, -- luaConstant    xxx links to Constant
    sym"@org.plan"                          { Constant }, -- @org.plan      xxx links to Constant
    sym"@org.headline.level2"               { Constant, bold=true }, -- @org.headline.level2 xxx links to Constant
    WhichKeyIconPurple                      { Constant }, -- WhichKeyIconPurple xxx links to Constant
    Statement                               { gui="bold", fg="nvimlightgrey2", }, -- Statement      xxx cterm=bold gui=bold guifg=NvimLightGrey2
    Conditional                             { Statement }, -- Conditional    xxx links to Statement
    Repeat                                  { Statement }, -- Repeat         xxx links to Statement
    Label                                   { Statement }, -- Label          xxx links to Statement
    Keyword                                 { Statement }, -- Keyword        xxx links to Statement
    Exception                               { Statement }, -- Exception      xxx links to Statement
    TelescopePreviewSocket                  { Statement }, -- TelescopePreviewSocket xxx links to Statement
    TelescopePreviewWrite                   { Statement }, -- TelescopePreviewWrite xxx links to Statement
    vimCommand                              { Statement }, -- vimCommand     xxx links to Statement
    luaStatement                            { Statement }, -- luaStatement   xxx links to Statement
    sym"@org.headline.level4"               { Statement }, -- @org.headline.level4 xxx links to Statement
    PreProc                                 { fg="nvimlightgrey2", }, -- PreProc        xxx guifg=NvimLightGrey2
    Include                                 { PreProc }, -- Include        xxx links to PreProc
    Define                                  { PreProc }, -- Define         xxx links to PreProc
    Macro                                   { PreProc }, -- Macro          xxx links to PreProc
    PreCondit                               { PreProc }, -- PreCondit      xxx links to PreProc
    vimOption                               { PreProc }, -- vimOption      xxx links to PreProc
    vimEnvvar                               { PreProc }, -- vimEnvvar      xxx links to PreProc
    vim9CommentTitle                        { PreProc }, -- vim9CommentTitle xxx links to PreProc
    vimCommentTitle                         { PreProc }, -- vimCommentTitle xxx links to PreProc
    vimMenuName                             { PreProc }, -- vimMenuName    xxx links to PreProc
    vimHiAttrib                             { PreProc }, -- vimHiAttrib    xxx links to PreProc
    vimShebang                              { PreProc }, -- vimShebang     xxx links to PreProc
    sym"@org.headline.level5"               { PreProc }, -- @org.headline.level5 xxx links to PreProc
    Type                                    { fg="nvimlightgrey2", italic=true}, -- Type           xxx guifg=NvimLightGrey2
    StorageClass                            { Type }, -- StorageClass   xxx links to Type
    Structure                               { Type }, -- Structure      xxx links to Type
    Typedef                                 { Type }, -- Typedef        xxx links to Type
    sym"@type"                              { Type }, -- @type          xxx links to Type
    NvimNumberPrefix                        { Type }, -- NvimNumberPrefix xxx links to Type
    NvimOptionSigil                         { Type }, -- NvimOptionSigil xxx links to Type
    TelescopeMultiSelection                 { Type }, -- TelescopeMultiSelection xxx links to Type
    DenoteSignature                         { Type }, -- DenoteSignature xxx links to Type
    vimGroup                                { Type }, -- vimGroup       xxx links to Type
    vimType                                 { Type }, -- vimType        xxx links to Type
    vimAutoEvent                            { Type }, -- vimAutoEvent   xxx links to Type
    vimSynCase                              { Type }, -- vimSynCase     xxx links to Type
    vimSynFoldMethod                        { Type }, -- vimSynFoldMethod xxx links to Type
    vimSynReg                               { Type }, -- vimSynReg      xxx links to Type
    vimSyncC                                { Type }, -- vimSyncC       xxx links to Type
    vimSyncKey                              { Type }, -- vimSyncKey     xxx links to Type
    vimSyncNone                             { Type }, -- vimSyncNone    xxx links to Type
    vimHiClear                              { Type }, -- vimHiClear     xxx links to Type
    vimHiTerm                               { Type }, -- vimHiTerm      xxx links to Type
    vimPattern                              { Type }, -- vimPattern     xxx links to Type
    vimSpecial                              { Type }, -- vimSpecial     xxx links to Type
    sym"@org.headline.level6"               { Type }, -- @org.headline.level6 xxx links to Type
    Special                                 { fg="nvimlightcyan", }, -- Special        xxx ctermfg=14 guifg=NvimLightCyan
    Tag                                     { Special }, -- Tag            xxx links to Special
    SpecialChar                             { Special }, -- SpecialChar    xxx links to Special
    SpecialComment                          { Special }, -- SpecialComment xxx links to Special
    Debug                                   { Special }, -- Debug          xxx links to Special
    sym"@variable.parameter.builtin"        { Special }, -- @variable.parameter.builtin xxx links to Special
    sym"@attribute.builtin"                 { Special }, -- @attribute.builtin xxx links to Special
    sym"@constructor"                       { Special }, -- @constructor   xxx links to Special
    sym"@markup"                            { Special }, -- @markup        xxx links to Special
    sym"@tag.builtin"                       { Special }, -- @tag.builtin   xxx links to Special
    TelescopeMatching                       { Special }, -- TelescopeMatching xxx links to Special
    TelescopePreviewLink                    { Special }, -- TelescopePreviewLink xxx links to Special
    OilChange                               { Special }, -- OilChange      xxx links to Special
    vimLetRegister                          { Special }, -- vimLetRegister xxx links to Special
    vimNotation                             { Special }, -- vimNotation    xxx links to Special
    vimContinue                             { Special }, -- vimContinue    xxx links to Special
    vimFuncMod                              { Special }, -- vimFuncMod     xxx links to Special
    vimUserCmdAttr                          { Special }, -- vimUserCmdAttr xxx links to Special
    vimEscape                               { Special }, -- vimEscape      xxx links to Special
    vimSubstFlags                           { Special }, -- vimSubstFlags  xxx links to Special
    vimLetHereDocStart                      { Special }, -- vimLetHereDocStart xxx links to Special
    vimLetHereDocStop                       { Special }, -- vimLetHereDocStop xxx links to Special
    vimAutoCmdMod                           { Special }, -- vimAutoCmdMod  xxx links to Special
    vimMenuStatus                           { Special }, -- vimMenuStatus  xxx links to Special
    vimMenuClear                            { Special }, -- vimMenuClear   xxx links to Special
    vimGroupSpecial                         { Special }, -- vimGroupSpecial xxx links to Special
    vim9Vim9ScriptArg                       { Special }, -- vim9Vim9ScriptArg xxx links to Special
    vimSynOption                            { Special }, -- vimSynOption   xxx links to Special
    sym"@org.headline.level7"               { Special }, -- @org.headline.level7 xxx links to Special
    DiagnosticError                         { fg="nvimlightred", }, -- DiagnosticError xxx ctermfg=8 guifg=NvimLightRed
    DiagnosticFloatingError                 { DiagnosticError }, -- DiagnosticFloatingError xxx links to DiagnosticError
    DiagnosticVirtualTextError              { DiagnosticError }, -- DiagnosticVirtualTextError xxx links to DiagnosticError
    DiagnosticVirtualLinesError             { DiagnosticError }, -- DiagnosticVirtualLinesError xxx links to DiagnosticError
    DiagnosticSignError                     { DiagnosticError }, -- DiagnosticSignError xxx links to DiagnosticError
    OilOrphanLinkTarget                     { DiagnosticError }, -- OilOrphanLinkTarget xxx links to DiagnosticError
    OilDelete                               { DiagnosticError }, -- OilDelete      xxx links to DiagnosticError
    WhichKeyIconRed                         { DiagnosticError }, -- WhichKeyIconRed xxx links to DiagnosticError
    DiagnosticWarn                          { fg="nvimlightyellow", }, -- DiagnosticWarn xxx ctermfg=11 guifg=NvimLightYellow
    DiagnosticFloatingWarn                  { DiagnosticWarn }, -- DiagnosticFloatingWarn xxx links to DiagnosticWarn
    DiagnosticVirtualTextWarn               { DiagnosticWarn }, -- DiagnosticVirtualTextWarn xxx links to DiagnosticWarn
    DiagnosticVirtualLinesWarn              { DiagnosticWarn }, -- DiagnosticVirtualLinesWarn xxx links to DiagnosticWarn
    DiagnosticSignWarn                      { DiagnosticWarn }, -- DiagnosticSignWarn xxx links to DiagnosticWarn
    OilMove                                 { DiagnosticWarn }, -- OilMove        xxx links to DiagnosticWarn
    WhichKeyIconYellow                      { DiagnosticWarn }, -- WhichKeyIconYellow xxx links to DiagnosticWarn
    WhichKeyIconOrange                      { DiagnosticWarn }, -- WhichKeyIconOrange xxx links to DiagnosticWarn
    DiagnosticInfo                          { fg="nvimlightcyan", }, -- DiagnosticInfo xxx ctermfg=14 guifg=NvimLightCyan
    DiagnosticFloatingInfo                  { DiagnosticInfo }, -- DiagnosticFloatingInfo xxx links to DiagnosticInfo
    DiagnosticVirtualTextInfo               { DiagnosticInfo }, -- DiagnosticVirtualTextInfo xxx links to DiagnosticInfo
    DiagnosticVirtualLinesInfo              { DiagnosticInfo }, -- DiagnosticVirtualLinesInfo xxx links to DiagnosticInfo
    DiagnosticSignInfo                      { DiagnosticInfo }, -- DiagnosticSignInfo xxx links to DiagnosticInfo
    OilCreate                               { DiagnosticInfo }, -- OilCreate      xxx links to DiagnosticInfo
    WhichKeyIconBlue                        { DiagnosticInfo }, -- WhichKeyIconBlue xxx links to DiagnosticInfo
    DiagnosticHint                          { fg="nvimlightblue", }, -- DiagnosticHint xxx ctermfg=12 guifg=NvimLightBlue
    DiagnosticFloatingHint                  { DiagnosticHint }, -- DiagnosticFloatingHint xxx links to DiagnosticHint
    DiagnosticVirtualTextHint               { DiagnosticHint }, -- DiagnosticVirtualTextHint xxx links to DiagnosticHint
    DiagnosticVirtualLinesHint              { DiagnosticHint }, -- DiagnosticVirtualLinesHint xxx links to DiagnosticHint
    DiagnosticSignHint                      { DiagnosticHint }, -- DiagnosticSignHint xxx links to DiagnosticHint
    OilCopy                                 { DiagnosticHint }, -- OilCopy        xxx links to DiagnosticHint
    WhichKeyIconCyan                        { DiagnosticHint }, -- WhichKeyIconCyan xxx links to DiagnosticHint
    DiagnosticOk                            { fg="nvimlightgreen", }, -- DiagnosticOk   xxx ctermfg=10 guifg=NvimLightGreen
    DiagnosticFloatingOk                    { DiagnosticOk }, -- DiagnosticFloatingOk xxx links to DiagnosticOk
    DiagnosticVirtualTextOk                 { DiagnosticOk }, -- DiagnosticVirtualTextOk xxx links to DiagnosticOk
    DiagnosticVirtualLinesOk                { DiagnosticOk }, -- DiagnosticVirtualLinesOk xxx links to DiagnosticOk
    DiagnosticSignOk                        { DiagnosticOk }, -- DiagnosticSignOk xxx links to DiagnosticOk
    WhichKeyIconGreen                       { DiagnosticOk }, -- WhichKeyIconGreen xxx links to DiagnosticOk
    Comment                                 { fg="#4d6472", italic=true }, -- Comment        xxx guifg=NvimLightGrey4
    DiagnosticUnnecessary                   { Comment }, -- DiagnosticUnnecessary xxx links to Comment
    sym"@comment"                           { Comment }, -- @comment       xxx links to Comment
    TelescopeResultsComment                 { Comment }, -- TelescopeResultsComment xxx links to Comment
    OilHidden                               { Comment }, -- OilHidden      xxx links to Comment
    OilLinkTarget                           { Comment }, -- OilLinkTarget  xxx links to Comment
    OilTrashSourcePath                      { Comment }, -- OilTrashSourcePath xxx links to Comment
    vim9Comment                             { Comment }, -- vim9Comment    xxx links to Comment
    vimComment                              { Comment }, -- vimComment     xxx links to Comment
    luaComment                              { Comment }, -- luaComment     xxx links to Comment
    vimScriptDelim                          { Comment }, -- vimScriptDelim xxx links to Comment
    QuickFixHeaderSoft                      { Comment }, -- QuickFixHeaderSoft xxx links to Comment
    QuickFixFilenameInvalid                 { Comment }, -- QuickFixFilenameInvalid xxx links to Comment
    sym"@variable"                          { fg="nvimlightgrey2", }, -- @variable      xxx guifg=NvimLightGrey2
    sym"@lsp.type.variable"                 { sym"@variable" }, -- @lsp.type.variable xxx links to @variable
    String                                  { fg="nvimlightgreen"}, -- String         xxx ctermfg=9 guifg=NvimLightGreen
    sym"@string"                            { String }, -- @string        xxx links to String
    NvimString                              { String }, -- NvimString     xxx links to String
    TelescopePreviewSize                    { String }, -- TelescopePreviewSize xxx links to String
    TelescopePreviewExecute                 { String }, -- TelescopePreviewExecute xxx links to String
    vimString                               { String }, -- vimString      xxx links to String
    luaString2                              { String }, -- luaString2     xxx links to String
    luaString                               { String }, -- luaString      xxx links to String
    sym"@org.headline.level8"               { String }, -- @org.headline.level8 xxx links to String
    Identifier                              { fg="nvimlightblue" }, -- Identifier     xxx ctermfg=12 guifg=NvimLightBlue
    sym"@property"                          { Identifier }, -- @property      xxx links to Identifier
    NvimIdentifier                          { Identifier }, -- NvimIdentifier xxx links to Identifier
    TelescopeMultiIcon                      { Identifier }, -- TelescopeMultiIcon xxx links to Identifier
    TelescopePromptPrefix                   { Identifier }, -- TelescopePromptPrefix xxx links to Identifier
    TelescopeResultsIdentifier              { Identifier }, -- TelescopeResultsIdentifier xxx links to Identifier
    vim9Super                               { Identifier }, -- vim9Super      xxx links to Identifier
    vim9This                                { Identifier }, -- vim9This       xxx links to Identifier
    vimVimVar                               { Identifier }, -- vimVimVar      xxx links to Identifier
    vimOptionVar                            { Identifier }, -- vimOptionVar   xxx links to Identifier
    vimSpecFile                             { Identifier }, -- vimSpecFile    xxx links to Identifier
    luaFunc                                 { Identifier }, -- luaFunc        xxx links to Identifier
    sym"@org.headline.level3"               { Identifier }, -- @org.headline.level3 xxx links to Identifier
    WhichKeyDesc                            { Identifier }, -- WhichKeyDesc   xxx links to Identifier
    Function                                { fg="nvimlightcyan", }, -- Function       xxx ctermfg=14 guifg=NvimLightCyan
    sym"@function"                          { Function }, -- @function      xxx links to Function
    TelescopeResultsFunction                { Function }, -- TelescopeResultsFunction xxx links to Function
    TelescopeResultsField                   { Function }, -- TelescopeResultsField xxx links to Function
    TelescopeResultsClass                   { Function }, -- TelescopeResultsClass xxx links to Function
    vimFuncName                             { Function }, -- vimFuncName    xxx links to Function
    luaMetaMethod                           { Function }, -- luaMetaMethod  xxx links to Function
    luaFunction                             { Function }, -- luaFunction    xxx links to Function
    WhichKeyIconAzure                       { Function }, -- WhichKeyIconAzure xxx links to Function
    Operator                                { fg="nvimlightgrey2", }, -- Operator       xxx guifg=NvimLightGrey2
    sym"@operator"                          { Operator }, -- @operator      xxx links to Operator
    NvimAssignment                          { Operator }, -- NvimAssignment xxx links to Operator
    NvimOperator                            { Operator }, -- NvimOperator   xxx links to Operator
    TelescopeResultsOperator                { Operator }, -- TelescopeResultsOperator xxx links to Operator
    vimOper                                 { Operator }, -- vimOper        xxx links to Operator
    luaOperator                             { Operator }, -- luaOperator    xxx links to Operator
    Delimiter                               { fg="nvimlightgrey2", }, -- Delimiter      xxx guifg=NvimLightGrey2
    sym"@punctuation"                       { Delimiter }, -- @punctuation   xxx links to Delimiter
    NvimParenthesis                         { Delimiter }, -- NvimParenthesis xxx links to Delimiter
    NvimColon                               { Delimiter }, -- NvimColon      xxx links to Delimiter
    NvimComma                               { Delimiter }, -- NvimComma      xxx links to Delimiter
    NvimArrow                               { Delimiter }, -- NvimArrow      xxx links to Delimiter
    MiniIndentscopeSymbol                   { Delimiter }, -- MiniIndentscopeSymbol xxx links to Delimiter
    vimParenSep                             { Delimiter }, -- vimParenSep    xxx links to Delimiter
    vimSep                                  { Delimiter }, -- vimSep         xxx links to Delimiter
    vimSubstDelim                           { Delimiter }, -- vimSubstDelim  xxx links to Delimiter
    vimBracket                              { Delimiter }, -- vimBracket     xxx links to Delimiter
    vimIskSep                               { Delimiter }, -- vimIskSep      xxx links to Delimiter
    vimSearchDelim                          { Delimiter }, -- vimSearchDelim xxx links to Delimiter
    vim9SearchDelim                         { Delimiter }, -- vim9SearchDelim xxx links to Delimiter
    QuickFixHeaderHard                      { Delimiter }, -- QuickFixHeaderHard xxx links to Delimiter
    Todo                                    { gui="bold", fg="nvimlightgrey2", }, -- Todo           xxx cterm=bold gui=bold guifg=NvimLightGrey2
    vimTodo                                 { Todo }, -- vimTodo        xxx links to Todo
    luaTodo                                 { Todo }, -- luaTodo        xxx links to Todo
    sym"@markup.strong"                     { gui="bold", }, -- @markup.strong xxx cterm=bold gui=bold
    sym"@org.bold"                          { sym"@markup.strong" }, -- @org.bold      xxx links to @markup.strong
    sym"@org.bold.delimiter"                { sym"@markup.strong" }, -- @org.bold.delimiter xxx links to @markup.strong
    sym"@markup.italic"                     { gui="italic", }, -- @markup.italic xxx cterm=italic gui=italic
    sym"@org.italic"                        { sym"@markup.italic" }, -- @org.italic    xxx links to @markup.italic
    sym"@org.italic.delimiter"              { sym"@markup.italic" }, -- @org.italic.delimiter xxx links to @markup.italic
    sym"@markup.strikethrough"              { gui="strikethrough", }, -- @markup.strikethrough xxx cterm=strikethrough gui=strikethrough
    sym"@org.strikethrough"                 { sym"@markup.strikethrough" }, -- @org.strikethrough xxx links to @markup.strikethrough
    sym"@org.strikethrough.delimiter"       { sym"@markup.strikethrough" }, -- @org.strikethrough.delimiter xxx links to @markup.strikethrough
    sym"@markup.underline"                  { gui="underline", }, -- @markup.underline xxx cterm=underline gui=underline
    sym"@org.underline"                     { sym"@markup.underline" }, -- @org.underline xxx links to @markup.underline
    sym"@org.underline.delimiter"           { sym"@markup.underline" }, -- @org.underline.delimiter xxx links to @markup.underline
    Added                                   { fg="nvimlightgreen", }, -- Added          xxx ctermfg=10 guifg=NvimLightGreen
    Removed                                 { fg="nvimlightred", }, -- Removed        xxx ctermfg=9 guifg=NvimLightRed
    Changed                                 { fg="nvimlightcyan", }, -- Changed        xxx ctermfg=14 guifg=NvimLightCyan
    sym"@markup.heading.1.delimiter.vimdoc" { gui="underdouble,nocombine", fg="bg", sp="fg", bg="bg", }, -- @markup.heading.1.delimiter.vimdoc xxx cterm=underdouble,nocombine gui=underdouble,nocombine guifg=bg guibg=bg guisp=fg
    sym"@markup.heading.2.delimiter.vimdoc" { gui="underline,nocombine", fg="bg", sp="fg", bg="bg", }, -- @markup.heading.2.delimiter.vimdoc xxx cterm=underline,nocombine gui=underline,nocombine guifg=bg guibg=bg guisp=fg
    DiagnosticDeprecated                    { gui="strikethrough", sp="nvimlightred", }, -- DiagnosticDeprecated xxx cterm=strikethrough gui=strikethrough guisp=NvimLightRed
    sym"@lsp.mod.deprecated"                { DiagnosticDeprecated }, -- @lsp.mod.deprecated xxx links to DiagnosticDeprecated
    MiniCompletionDeprecated                { DiagnosticDeprecated }, -- MiniCompletionDeprecated xxx links to DiagnosticDeprecated
    FloatShadow                             { blend=80, bg="nvimdarkgrey4", }, -- FloatShadow    xxx ctermbg=0 guibg=NvimDarkGrey4 blend=80
    FloatShadowThrough                      { blend=100, bg="nvimdarkgrey4", }, -- FloatShadowThrough xxx ctermbg=0 guibg=NvimDarkGrey4 blend=100
    MatchParen                              { gui="bold", bg="nvimdarkgrey4", }, -- MatchParen     xxx cterm=bold,underline gui=bold guibg=NvimDarkGrey4
    RedrawDebugClear                        { bg="nvimdarkyellow", }, -- RedrawDebugClear xxx ctermfg=0 ctermbg=11 guibg=NvimDarkYellow
    RedrawDebugComposed                     { bg="nvimdarkgreen", }, -- RedrawDebugComposed xxx ctermfg=0 ctermbg=10 guibg=NvimDarkGreen
    RedrawDebugRecompose                    { bg="nvimdarkred", }, -- RedrawDebugRecompose xxx ctermfg=0 ctermbg=9 guibg=NvimDarkRed
    Error                                   { fg="nvimlightgrey1", bg="nvimdarkred", }, -- Error          xxx ctermfg=0 ctermbg=9 guifg=NvimLightGrey1 guibg=NvimDarkRed
    NvimInvalid                             { Error }, -- NvimInvalid    xxx links to Error
    vimOperError                            { Error }, -- vimOperError   xxx links to Error
    vimUserCmdAttrError                     { Error }, -- vimUserCmdAttrError xxx links to Error
    vimUserCmdError                         { Error }, -- vimUserCmdError xxx links to Error
    vimElseIfErr                            { Error }, -- vimElseIfErr   xxx links to Error
    vimSynError                             { Error }, -- vimSynError    xxx links to Error
    vimSyncError                            { Error }, -- vimSyncError   xxx links to Error
    luaParenError                           { Error }, -- luaParenError  xxx links to Error
    luaError                                { Error }, -- luaError       xxx links to Error
    vimError                                { Error }, -- vimError       xxx links to Error
    DiagnosticUnderlineError                { gui="bold,undercurl", fg="nvimlightred", sp="nvimlightred", }, -- DiagnosticUnderlineError xxx cterm=underline gui=underline guisp=NvimLightRed
    DiagnosticUnderlineWarn                 { gui="bold,undercurl", fg="nvimlightyellow", sp="nvimlightyellow", }, -- DiagnosticUnderlineWarn xxx cterm=underline gui=underline guisp=NvimLightYellow
    DiagnosticUnderlineInfo                 { gui="bold,undercurl", fg="nvimlightcyan", sp="nvimlightcyan", }, -- DiagnosticUnderlineInfo xxx cterm=underline gui=underline guisp=NvimLightCyan
    DiagnosticUnderlineHint                 { gui="bold,undercurl", fg="nvimlightblue", sp="nvimlightblue", }, -- DiagnosticUnderlineHint xxx cterm=underline gui=underline guisp=NvimLightBlue
    DiagnosticUnderlineOk                   { gui="bold,undercurl", fg="nvimlightgreen", sp="nvimlightgreen", }, -- DiagnosticUnderlineOk xxx cterm=underline gui=underline guisp=NvimLightGreen
    NvimInternalError                       { fg="red", bg="red", }, -- NvimInternalError xxx ctermfg=9 ctermbg=9 guifg=Red guibg=Red
    NvimFigureBrace                         { NvimInternalError }, -- NvimFigureBrace xxx links to NvimInternalError
    NvimSingleQuotedUnknownEscape           { NvimInternalError }, -- NvimSingleQuotedUnknownEscape xxx links to NvimInternalError
    NvimInvalidSingleQuotedUnknownEscape    { NvimInternalError }, -- NvimInvalidSingleQuotedUnknownEscape xxx links to NvimInternalError
    MiniHipatternsFixme                     { gui="bold,reverse", fg="#ffc0b9", }, -- MiniHipatternsFixme xxx cterm=bold,reverse ctermfg=9 gui=bold,reverse guifg=#ffc0b9
    MiniHipatternsHack                      { gui="bold,reverse", fg="#fce094", }, -- MiniHipatternsHack xxx cterm=bold,reverse ctermfg=11 gui=bold,reverse guifg=#fce094
    MiniHipatternsTodo                      { gui="bold,reverse", fg="#8cf8f7", }, -- MiniHipatternsTodo xxx cterm=bold,reverse ctermfg=14 gui=bold,reverse guifg=#8cf8f7
    MiniHipatternsNote                      { gui="bold,reverse", fg="#a6dbff", }, -- MiniHipatternsNote xxx cterm=bold,reverse ctermfg=12 gui=bold,reverse guifg=#a6dbff
    sym"@org.agenda.deadline"               { fg="#ff1a1a", }, -- @org.agenda.deadline xxx ctermfg=9 guifg=#ff1a1a
    sym"@org.agenda.scheduled"              { fg="#1aff1a", }, -- @org.agenda.scheduled xxx ctermfg=10 guifg=#1aff1a
    sym"@org.agenda.scheduled_past"         { fg="#ff981a", }, -- @org.agenda.scheduled_past xxx ctermfg=11 guifg=#ff981a
    sym"@org.agenda.time_grid"              { Comment }, -- @org.agenda.time_grid xxx ctermfg=11 guifg=#ff981a
    sym"@org.keyword.todo"                  { gui="bold", fg="#ff1a1a", }, -- @org.keyword.todo xxx cterm=bold ctermfg=1 gui=bold guifg=#ff0000
    sym"@org.keyword.done"                  { gui="bold", fg="#1aff1a", }, -- @org.keyword.done xxx cterm=bold ctermfg=2 gui=bold guifg=#00ff00
    sym"@org.leading_stars"                 { fg="white", }, -- @org.leading_stars xxx ctermfg=0 guifg=bg
    DevIconDefault                          { fg="#6d8086", }, -- DevIconDefault xxx ctermfg=66 guifg=#6d8086
    DevIconWebmanifest                      { fg="#f1e05a", }, -- DevIconWebmanifest xxx ctermfg=185 guifg=#f1e05a
    DevIconsbt                              { fg="#cc3e44", }, -- DevIconsbt     xxx ctermfg=167 guifg=#cc3e44
    DevIconKotlin                           { fg="#7f52ff", }, -- DevIconKotlin  xxx ctermfg=99 guifg=#7f52ff
    DevIconMojo                             { fg="#ff4c1f", }, -- DevIconMojo    xxx ctermfg=196 guifg=#ff4c1f
    DevIconi3                               { fg="#e8ebee", }, -- DevIconi3      xxx ctermfg=255 guifg=#e8ebee
    DevIconSharedObject                     { fg="#dcddd6", }, -- DevIconSharedObject xxx ctermfg=253 guifg=#dcddd6
    DevIconKotlinScript                     { fg="#7f52ff", }, -- DevIconKotlinScript xxx ctermfg=99 guifg=#7f52ff
    DevIconDot                              { fg="#30638e", }, -- DevIconDot     xxx ctermfg=24 guifg=#30638e
    DevIconUI                               { fg="#015bf0", }, -- DevIconUI      xxx ctermfg=27 guifg=#015bf0
    DevIconJl                               { fg="#a270ba", }, -- DevIconJl      xxx ctermfg=133 guifg=#a270ba
    DevIconDesktopEntry                     { fg="#563d7c", }, -- DevIconDesktopEntry xxx ctermfg=54 guifg=#563d7c
    DevIconNotebook                         { fg="#f57d01", }, -- DevIconNotebook xxx ctermfg=208 guifg=#f57d01
    DevIconDart                             { fg="#03589c", }, -- DevIconDart    xxx ctermfg=25 guifg=#03589c
    DevIconAi                               { fg="#cbcb41", }, -- DevIconAi      xxx ctermfg=185 guifg=#cbcb41
    DevIconCue                              { fg="#ed95ae", }, -- DevIconCue     xxx ctermfg=211 guifg=#ed95ae
    DevIconcuda                             { fg="#89e051", }, -- DevIconcuda    xxx ctermfg=113 guifg=#89e051
    DevIconcudah                            { fg="#a074c4", }, -- DevIconcudah   xxx ctermfg=140 guifg=#a074c4
    DevIconLocalization                     { fg="#2596be", }, -- DevIconLocalization xxx ctermfg=31 guifg=#2596be
    DevIconFeature                          { fg="#00a818", }, -- DevIconFeature xxx ctermfg=34 guifg=#00a818
    DevIconElm                              { fg="#519aba", }, -- DevIconElm     xxx ctermfg=74 guifg=#519aba
    DevIconPls                              { fg="#ed95ae", }, -- DevIconPls     xxx ctermfg=211 guifg=#ed95ae
    DevIconElf                              { fg="#9f0500", }, -- DevIconElf     xxx ctermfg=124 guifg=#9f0500
    DevIconMjs                              { fg="#f1e05a", }, -- DevIconMjs     xxx ctermfg=185 guifg=#f1e05a
    DevIconGvimrc                           { fg="#019833", }, -- DevIconGvimrc  xxx ctermfg=28 guifg=#019833
    DevIconCss                              { fg="#663399", }, -- DevIconCss     xxx ctermfg=91 guifg=#663399
    DevIconConf                             { fg="#6d8086", }, -- DevIconConf    xxx ctermfg=66 guifg=#6d8086
    DevIconRazorPage                        { fg="#512bd4", }, -- DevIconRazorPage xxx ctermfg=56 guifg=#512bd4
    DevIconJava                             { fg="#cc3e44", }, -- DevIconJava    xxx ctermfg=167 guifg=#cc3e44
    DevIconCs                               { fg="#596706", }, -- DevIconCs      xxx ctermfg=58 guifg=#596706
    DevIconCrystal                          { fg="#c8c8c8", }, -- DevIconCrystal xxx ctermfg=251 guifg=#c8c8c8
    DevIconPhp                              { fg="#a074c4", }, -- DevIconPhp     xxx ctermfg=140 guifg=#a074c4
    DevIconCxxm                             { fg="#519aba", }, -- DevIconCxxm    xxx ctermfg=74 guifg=#519aba
    DevIconCppm                             { fg="#519aba", }, -- DevIconCppm    xxx ctermfg=74 guifg=#519aba
    DevIconCPlusPlusModule                  { fg="#f34b7d", }, -- DevIconCPlusPlusModule xxx ctermfg=204 guifg=#f34b7d
    DevIconGitLogo                          { fg="#f14c28", }, -- DevIconGitLogo xxx ctermfg=196 guifg=#f14c28
    DevIconHxx                              { fg="#a074c4", }, -- DevIconHxx     xxx ctermfg=140 guifg=#a074c4
    DevIconCxx                              { fg="#519aba", }, -- DevIconCxx     xxx ctermfg=74 guifg=#519aba
    DevIconCPlusPlus                        { fg="#f34b7d", }, -- DevIconCPlusPlus xxx ctermfg=204 guifg=#f34b7d
    DevIconPrisma                           { fg="#5a67d8", }, -- DevIconPrisma  xxx ctermfg=62 guifg=#5a67d8
    DevIconHh                               { fg="#a074c4", }, -- DevIconHh      xxx ctermfg=140 guifg=#a074c4
    DevIconLib                              { fg="#4d2c0b", }, -- DevIconLib     xxx ctermfg=52 guifg=#4d2c0b
    DevIconTrueTypeFont                     { fg="#ececec", }, -- DevIconTrueTypeFont xxx ctermfg=255 guifg=#ececec
    DevIconIso                              { fg="#d0bec8", }, -- DevIconIso     xxx ctermfg=181 guifg=#d0bec8
    DevIconCobol                            { fg="#005ca5", }, -- DevIconCobol   xxx ctermfg=25 guifg=#005ca5
    DevIconXsession                         { fg="#e54d18", }, -- DevIconXsession xxx ctermfg=196 guifg=#e54d18
    DevIconTypoScriptConfig                 { fg="#ff8700", }, -- DevIconTypoScriptConfig xxx ctermfg=208 guifg=#ff8700
    DevIconClojureJS                        { fg="#519aba", }, -- DevIconClojureJS xxx ctermfg=74 guifg=#519aba
    DevIconVimrc                            { fg="#019833", }, -- DevIconVimrc   xxx ctermfg=28 guifg=#019833
    DevIconSettingsJson                     { fg="#854cc7", }, -- DevIconSettingsJson xxx ctermfg=98 guifg=#854cc7
    DevIcon3DObjectFile                     { fg="#888888", }, -- DevIcon3DObjectFile xxx ctermfg=102 guifg=#888888
    DevIconTorrent                          { fg="#44cda8", }, -- DevIconTorrent xxx ctermfg=43 guifg=#44cda8
    DevIconPrettierConfig                   { fg="#4285f4", }, -- DevIconPrettierConfig xxx ctermfg=33 guifg=#4285f4
    DevIconSignature                        { fg="#e37933", }, -- DevIconSignature xxx ctermfg=166 guifg=#e37933
    DevIconPreCommitConfig                  { fg="#f8b424", }, -- DevIconPreCommitConfig xxx ctermfg=214 guifg=#f8b424
    DevIconPrettierIgnore                   { fg="#4285f4", }, -- DevIconPrettierIgnore xxx ctermfg=33 guifg=#4285f4
    DevIconPNPMFile                         { fg="#f9ad02", }, -- DevIconPNPMFile xxx ctermfg=214 guifg=#f9ad02
    DevIconIni                              { fg="#6d8086", }, -- DevIconIni     xxx ctermfg=66 guifg=#6d8086
    DevIconNuxtConfig                       { fg="#00c58e", }, -- DevIconNuxtConfig xxx ctermfg=42 guifg=#00c58e
    DevIconAsc                              { fg="#576d7f", }, -- DevIconAsc     xxx ctermfg=242 guifg=#576d7f
    DevIconTypeScriptReactTest              { fg="#1354bf", }, -- DevIconTypeScriptReactTest xxx ctermfg=26 guifg=#1354bf
    DevIconNano                             { fg="#440077", }, -- DevIconNano    xxx ctermfg=54 guifg=#440077
    DevIconRedhat                           { fg="#ee0000", }, -- DevIconRedhat  xxx ctermfg=196 guifg=#ee0000
    DevIconTestTs                           { fg="#519aba", }, -- DevIconTestTs  xxx ctermfg=74 guifg=#519aba
    DevIconRaspberryPiOS                    { fg="#be1848", }, -- DevIconRaspberryPiOS xxx ctermfg=161 guifg=#be1848
    DevIconCsv                              { fg="#89e051", }, -- DevIconCsv     xxx ctermfg=113 guifg=#89e051
    DevIconNixOS                            { fg="#7ab1db", }, -- DevIconNixOS   xxx ctermfg=110 guifg=#7ab1db
    DevIconTestJs                           { fg="#cbcb41", }, -- DevIconTestJs  xxx ctermfg=185 guifg=#cbcb41
    DevIconMint                             { fg="#87c095", }, -- DevIconMint    xxx ctermfg=108 guifg=#87c095
    DevIconLabView                          { fg="#fec60a", }, -- DevIconLabView xxx ctermfg=220 guifg=#fec60a
    DevIconTcl                              { fg="#1e5cb3", }, -- DevIconTcl     xxx ctermfg=25 guifg=#1e5cb3
    DevIconXInitrc                          { fg="#e54d18", }, -- DevIconXInitrc xxx ctermfg=196 guifg=#e54d18
    DevIconnode                             { fg="#5fa04e", }, -- DevIconnode    xxx ctermfg=71 guifg=#5fa04e
    DevIconMailmap                          { fg="#f54d27", }, -- DevIconMailmap xxx ctermfg=196 guifg=#f54d27
    DevIconEslintIgnore                     { fg="#4b32c3", }, -- DevIconEslintIgnore xxx ctermfg=56 guifg=#4b32c3
    DevIconGitlabCI                         { fg="#e24329", }, -- DevIconGitlabCI xxx ctermfg=196 guifg=#e24329
    DevIconEnv                              { fg="#faf743", }, -- DevIconEnv     xxx ctermfg=227 guifg=#faf743
    DevIconDb                               { fg="#dad8d8", }, -- DevIconDb      xxx ctermfg=188 guifg=#dad8d8
    DevIconAndroid                          { fg="#34a853", }, -- DevIconAndroid xxx ctermfg=35 guifg=#34a853
    DevIconXlsx                             { fg="#207245", }, -- DevIconXlsx    xxx ctermfg=29 guifg=#207245
    DevIconBackup                           { fg="#6d8086", }, -- DevIconBackup  xxx ctermfg=66 guifg=#6d8086
    DevIconXls                              { fg="#207245", }, -- DevIconXls     xxx ctermfg=29 guifg=#207245
    DevIconPptx                             { fg="#cb4a32", }, -- DevIconPptx    xxx ctermfg=160 guifg=#cb4a32
    DevIconMpv                              { fg="#3b1342", }, -- DevIconMpv     xxx ctermfg=53 guifg=#3b1342
    DevIconPpt                              { fg="#cb4a32", }, -- DevIconPpt     xxx ctermfg=160 guifg=#cb4a32
    DevIconReadme                           { fg="#ededed", }, -- DevIconReadme  xxx ctermfg=255 guifg=#ededed
    DevIconPm                               { fg="#519aba", }, -- DevIconPm      xxx ctermfg=74 guifg=#519aba
    DevIconStorybookTsx                     { fg="#ff4785", }, -- DevIconStorybookTsx xxx ctermfg=204 guifg=#ff4785
    DevIconStorybookTypeScript              { fg="#ff4785", }, -- DevIconStorybookTypeScript xxx ctermfg=204 guifg=#ff4785
    DevIconXz                               { fg="#eca517", }, -- DevIconXz      xxx ctermfg=214 guifg=#eca517
    DevIconStorybookSvelte                  { fg="#ff4785", }, -- DevIconStorybookSvelte xxx ctermfg=204 guifg=#ff4785
    DevIconTgz                              { fg="#eca517", }, -- DevIconTgz     xxx ctermfg=214 guifg=#eca517
    DevIconStorybookMjs                     { fg="#ff4785", }, -- DevIconStorybookMjs xxx ctermfg=204 guifg=#ff4785
    DevIconTxt                              { fg="#89e051", }, -- DevIconTxt     xxx ctermfg=113 guifg=#89e051
    DevIconRar                              { fg="#eca517", }, -- DevIconRar     xxx ctermfg=214 guifg=#eca517
    DevIconGz                               { fg="#eca517", }, -- DevIconGz      xxx ctermfg=214 guifg=#eca517
    DevIconBz3                              { fg="#eca517", }, -- DevIconBz3     xxx ctermfg=214 guifg=#eca517
    DevIconViteConfig                       { fg="#ffa800", }, -- DevIconViteConfig xxx ctermfg=214 guifg=#ffa800
    DevIconGo                               { fg="#00add8", }, -- DevIconGo      xxx ctermfg=38 guifg=#00add8
    DevIcon7z                               { fg="#eca517", }, -- DevIcon7z      xxx ctermfg=214 guifg=#eca517
    DevIconPp                               { fg="#ffa61a", }, -- DevIconPp      xxx ctermfg=214 guifg=#ffa61a
    DevIconBmp                              { fg="#a074c4", }, -- DevIconBmp     xxx ctermfg=140 guifg=#a074c4
    DevIconWindowsMediaAudio                { fg="#00afff", }, -- DevIconWindowsMediaAudio xxx ctermfg=39 guifg=#00afff
    DevIconOggSpeexAudio                    { fg="#0075aa", }, -- DevIconOggSpeexAudio xxx ctermfg=24 guifg=#0075aa
    DevIconMPEG4                            { fg="#00afff", }, -- DevIconMPEG4   xxx ctermfg=39 guifg=#00afff
    DevIconAudioInterchangeFileFormat       { fg="#00afff", }, -- DevIconAudioInterchangeFileFormat xxx ctermfg=39 guifg=#00afff
    DevIconAdvancedAudioCoding              { fg="#00afff", }, -- DevIconAdvancedAudioCoding xxx ctermfg=39 guifg=#00afff
    DevIconWindowsMediaVideo                { fg="#fd971f", }, -- DevIconWindowsMediaVideo xxx ctermfg=208 guifg=#fd971f
    DevIconSpecTs                           { fg="#519aba", }, -- DevIconSpecTs  xxx ctermfg=74 guifg=#519aba
    DevIconJavaScriptReactSpec              { fg="#20c2e3", }, -- DevIconJavaScriptReactSpec xxx ctermfg=45 guifg=#20c2e3
    DevIconM4V                              { fg="#fd971f", }, -- DevIconM4V     xxx ctermfg=208 guifg=#fd971f
    DevIconSpecJs                           { fg="#cbcb41", }, -- DevIconSpecJs  xxx ctermfg=185 guifg=#cbcb41
    DevIconSig                              { fg="#e37933", }, -- DevIconSig     xxx ctermfg=166 guifg=#e37933
    DevIconKsh                              { fg="#4d5a5e", }, -- DevIconKsh     xxx ctermfg=240 guifg=#4d5a5e
    DevIconGentooBuild                      { fg="#4c416e", }, -- DevIconGentooBuild xxx ctermfg=60 guifg=#4c416e
    DevIconSolveSpace                       { fg="#839463", }, -- DevIconSolveSpace xxx ctermfg=101 guifg=#839463
    DevIconZorin                            { fg="#14a1e8", }, -- DevIconZorin   xxx ctermfg=39 guifg=#14a1e8
    DevIconCpp                              { fg="#519aba", }, -- DevIconCpp     xxx ctermfg=74 guifg=#519aba
    DevIconSolidWorksPrt                    { fg="#839463", }, -- DevIconSolidWorksPrt xxx ctermfg=101 guifg=#839463
    DevIconPl                               { fg="#519aba", }, -- DevIconPl      xxx ctermfg=74 guifg=#519aba
    DevIconXpi                              { fg="#ff1b01", }, -- DevIconXpi     xxx ctermfg=196 guifg=#ff1b01
    DevIconNodeModules                      { fg="#e8274b", }, -- DevIconNodeModules xxx ctermfg=197 guifg=#e8274b
    DevIconAwk                              { fg="#4d5a5e", }, -- DevIconAwk     xxx ctermfg=240 guifg=#4d5a5e
    DevIconVanillaOS                        { fg="#fabd4d", }, -- DevIconVanillaOS xxx ctermfg=214 guifg=#fabd4d
    DevIconLogos                            { fg="#519aba", }, -- DevIconLogos   xxx ctermfg=74 guifg=#519aba
    DevIconVHDL                             { fg="#019833", }, -- DevIconVHDL    xxx ctermfg=28 guifg=#019833
    DevIconTumbleweed                       { fg="#35b9ab", }, -- DevIconTumbleweed xxx ctermfg=37 guifg=#35b9ab
    DevIconXcLocalization                   { fg="#2596be", }, -- DevIconXcLocalization xxx ctermfg=31 guifg=#2596be
    DevIconC                                { fg="#599eff", }, -- DevIconC       xxx ctermfg=111 guifg=#599eff
    DevIconObjectiveCPlusPlus               { fg="#519aba", }, -- DevIconObjectiveCPlusPlus xxx ctermfg=74 guifg=#519aba
    DevIconGIMP                             { fg="#635b46", }, -- DevIconGIMP    xxx ctermfg=240 guifg=#635b46
    DevIconGTK                              { fg="#ffffff", }, -- DevIconGTK     xxx ctermfg=231 guifg=#ffffff
    DevIconWindows                          { fg="#00a4ef", }, -- DevIconWindows xxx ctermfg=39 guifg=#00a4ef
    DevIconAppleScript                      { fg="#6d8085", }, -- DevIconAppleScript xxx ctermfg=66 guifg=#6d8085
    DevIconMakefile                         { fg="#6d8086", }, -- DevIconMakefile xxx ctermfg=66 guifg=#6d8086
    DevIconObjectiveC                       { fg="#599eff", }, -- DevIconObjectiveC xxx ctermfg=111 guifg=#599eff
    DevIconVala                             { fg="#7b3db9", }, -- DevIconVala    xxx ctermfg=91 guifg=#7b3db9
    DevIconWavPackCorrection                { fg="#00afff", }, -- DevIconWavPackCorrection xxx ctermfg=39 guifg=#00afff
    DevIconAsciinema                        { fg="#fd971f", }, -- DevIconAsciinema xxx ctermfg=208 guifg=#fd971f
    DevIconSabayon                          { fg="#c6c6c6", }, -- DevIconSabayon xxx ctermfg=251 guifg=#c6c6c6
    DevIconWavPack                          { fg="#00afff", }, -- DevIconWavPack xxx ctermfg=39 guifg=#00afff
    DevIconRockyLinux                       { fg="#0fb37d", }, -- DevIconRockyLinux xxx ctermfg=36 guifg=#0fb37d
    DevIconVRML                             { fg="#888888", }, -- DevIconVRML    xxx ctermfg=102 guifg=#888888
    DevIconZig                              { fg="#f69a1b", }, -- DevIconZig     xxx ctermfg=172 guifg=#f69a1b
    DevIconWebOpenFontFormat                { fg="#ececec", }, -- DevIconWebOpenFontFormat xxx ctermfg=255 guifg=#ececec
    DevIconHtm                              { fg="#e34c26", }, -- DevIconHtm     xxx ctermfg=196 guifg=#e34c26
    DevIconQubesOS                          { fg="#3774d8", }, -- DevIconQubesOS xxx ctermfg=33 guifg=#3774d8
    DevIconHtml                             { fg="#e44d26", }, -- DevIconHtml    xxx ctermfg=196 guifg=#e44d26
    DevIconMarkdown                         { fg="#dddddd", }, -- DevIconMarkdown xxx ctermfg=253 guifg=#dddddd
    DevIconPuppyLinux                       { fg="#a2aeb9", }, -- DevIconPuppyLinux xxx ctermfg=145 guifg=#a2aeb9
    DevIconBazelBuild                       { fg="#89e051", }, -- DevIconBazelBuild xxx ctermfg=113 guifg=#89e051
    DevIconpostmarketOS                     { fg="#009900", }, -- DevIconpostmarketOS xxx ctermfg=28 guifg=#009900
    DevIconPop_OS                           { fg="#48b9c7", }, -- DevIconPop_OS  xxx ctermfg=73 guifg=#48b9c7
    DevIconFreeBSD                          { fg="#c90f02", }, -- DevIconFreeBSD xxx ctermfg=160 guifg=#c90f02
    DevIconEdn                              { fg="#519aba", }, -- DevIconEdn     xxx ctermfg=74 guifg=#519aba
    DevIconParrot                           { fg="#54deff", }, -- DevIconParrot  xxx ctermfg=45 guifg=#54deff
    DevIconVsix                             { fg="#854cc7", }, -- DevIconVsix    xxx ctermfg=98 guifg=#854cc7
    DevIconParabolaGNULinuxLibre            { fg="#797dac", }, -- DevIconParabolaGNULinuxLibre xxx ctermfg=103 guifg=#797dac
    DevIconopenSUSE                         { fg="#6fb424", }, -- DevIconopenSUSE xxx ctermfg=70 guifg=#6fb424
    DevIconCSharpProject                    { fg="#512bd4", }, -- DevIconCSharpProject xxx ctermfg=56 guifg=#512bd4
    DevIconVerilog                          { fg="#019833", }, -- DevIconVerilog xxx ctermfg=28 guifg=#019833
    DevIconJsonc                            { fg="#cbcb41", }, -- DevIconJsonc   xxx ctermfg=185 guifg=#cbcb41
    DevIconM3u                              { fg="#ed95ae", }, -- DevIconM3u     xxx ctermfg=211 guifg=#ed95ae
    DevIconRss                              { fg="#fb9d3b", }, -- DevIconRss     xxx ctermfg=215 guifg=#fb9d3b
    DevIconNobaraLinux                      { fg="#ffffff", }, -- DevIconNobaraLinux xxx ctermfg=231 guifg=#ffffff
    DevIconHexadecimal                      { fg="#2e63ff", }, -- DevIconHexadecimal xxx ctermfg=27 guifg=#2e63ff
    DevIconTerminal                         { fg="#31b53e", }, -- DevIconTerminal xxx ctermfg=34 guifg=#31b53e
    DevIconMXLinux                          { fg="#ffffff", }, -- DevIconMXLinux xxx ctermfg=231 guifg=#ffffff
    DevIconThunderbird                      { fg="#137be1", }, -- DevIconThunderbird xxx ctermfg=33 guifg=#137be1
    DevIconHeex                             { fg="#a074c4", }, -- DevIconHeex    xxx ctermfg=140 guifg=#a074c4
    DevIconMageia                           { fg="#2397d4", }, -- DevIconMageia  xxx ctermfg=67 guifg=#2397d4
    DevIconLXLE                             { fg="#474747", }, -- DevIconLXLE    xxx ctermfg=238 guifg=#474747
    DevIconAdaSpecification                 { fg="#a074c4", }, -- DevIconAdaSpecification xxx ctermfg=140 guifg=#a074c4
    DevIconAdaFile                          { fg="#599eff", }, -- DevIconAdaFile xxx ctermfg=111 guifg=#599eff
    DevIconGPRBuildProject                  { fg="#6d8086", }, -- DevIconGPRBuildProject xxx ctermfg=66 guifg=#6d8086
    DevIconAdaBody                          { fg="#599eff", }, -- DevIconAdaBody xxx ctermfg=111 guifg=#599eff
    DevIconLocOS                            { fg="#fab402", }, -- DevIconLocOS   xxx ctermfg=214 guifg=#fab402
    DevIconDll                              { fg="#4d2c0b", }, -- DevIconDll     xxx ctermfg=52 guifg=#4d2c0b
    DevIconTwig                             { fg="#8dc149", }, -- DevIconTwig    xxx ctermfg=113 guifg=#8dc149
    DevIconVue                              { fg="#8dc149", }, -- DevIconVue     xxx ctermfg=113 guifg=#8dc149
    DevIconInfo                             { fg="#ffffcd", }, -- DevIconInfo    xxx ctermfg=230 guifg=#ffffcd
    DevIconLeap                             { fg="#fbc75d", }, -- DevIconLeap    xxx ctermfg=221 guifg=#fbc75d
    DevIconConfiguration                    { fg="#6d8086", }, -- DevIconConfiguration xxx ctermfg=66 guifg=#6d8086
    DevIconFish                             { fg="#4d5a5e", }, -- DevIconFish    xxx ctermfg=240 guifg=#4d5a5e
    DevIconKubuntu                          { fg="#007ac2", }, -- DevIconKubuntu xxx ctermfg=32 guifg=#007ac2
    DevIconCts                              { fg="#519aba", }, -- DevIconCts     xxx ctermfg=74 guifg=#519aba
    DevIconHbs                              { fg="#f0772b", }, -- DevIconHbs     xxx ctermfg=202 guifg=#f0772b
    DevIconXml                              { fg="#e37933", }, -- DevIconXml     xxx ctermfg=166 guifg=#e37933
    DevIconTsx                              { fg="#1354bf", }, -- DevIconTsx     xxx ctermfg=26 guifg=#1354bf
    DevIconZsh                              { fg="#89e051", }, -- DevIconZsh     xxx ctermfg=113 guifg=#89e051
    DevIconIllumos                          { fg="#ff430f", }, -- DevIconIllumos xxx ctermfg=196 guifg=#ff430f
    DevIconHyperbolaGNULinuxLibre           { fg="#c0c0c0", }, -- DevIconHyperbolaGNULinuxLibre xxx ctermfg=250 guifg=#c0c0c0
    DevIconGuix                             { fg="#ffcc00", }, -- DevIconGuix    xxx ctermfg=220 guifg=#ffcc00
    DevIconGradle                           { fg="#005f87", }, -- DevIconGradle  xxx ctermfg=24 guifg=#005f87
    DevIconGraphQL                          { fg="#e535ab", }, -- DevIconGraphQL xxx ctermfg=199 guifg=#e535ab
    DevIconLinux                            { fg="#fdfdfb", }, -- DevIconLinux   xxx ctermfg=231 guifg=#fdfdfb
    sym"DevIconPy.typed"                    { fg="#ffbc03", }, -- DevIconPy.typed xxx ctermfg=214 guifg=#ffbc03
    DevIconUbuntu                           { fg="#dd4814", }, -- DevIconUbuntu  xxx ctermfg=196 guifg=#dd4814
    DevIconSh                               { fg="#4d5a5e", }, -- DevIconSh      xxx ctermfg=240 guifg=#4d5a5e
    DevIconCentos                           { fg="#a2518d", }, -- DevIconCentos  xxx ctermfg=132 guifg=#a2518d
    DevIconMaven                            { fg="#7a0d21", }, -- DevIconMaven   xxx ctermfg=52 guifg=#7a0d21
    DevIconDiff                             { fg="#41535b", }, -- DevIconDiff    xxx ctermfg=239 guifg=#41535b
    DevIconPNPMWorkspace                    { fg="#f9ad02", }, -- DevIconPNPMWorkspace xxx ctermfg=214 guifg=#f9ad02
    DevIconOpenBSD                          { fg="#f2ca30", }, -- DevIconOpenBSD xxx ctermfg=220 guifg=#f2ca30
    DevIconPNPMLock                         { fg="#f9ad02", }, -- DevIconPNPMLock xxx ctermfg=214 guifg=#f9ad02
    DevIconVim                              { fg="#019833", }, -- DevIconVim     xxx ctermfg=28 guifg=#019833
    DevIconPlaywrightConfig                 { fg="#2fad33", }, -- DevIconPlaywrightConfig xxx ctermfg=34 guifg=#2fad33
    DevIconPlatformio                       { fg="#f6822b", }, -- DevIconPlatformio xxx ctermfg=208 guifg=#f6822b
    DevIconPackageJson                      { fg="#e8274b", }, -- DevIconPackageJson xxx ctermfg=197 guifg=#e8274b
    DevIconClangConfig                      { fg="#6d8086", }, -- DevIconClangConfig xxx ctermfg=66 guifg=#6d8086
    DevIconBazelWorkspace                   { fg="#89e051", }, -- DevIconBazelWorkspace xxx ctermfg=113 guifg=#89e051
    DevIconGarudaLinux                      { fg="#2974e1", }, -- DevIconGarudaLinux xxx ctermfg=33 guifg=#2974e1
    DevIconGDScript                         { fg="#6d8086", }, -- DevIconGDScript xxx ctermfg=66 guifg=#6d8086
    DevIconNextConfigTs                     { fg="#ffffff", }, -- DevIconNextConfigTs xxx ctermfg=231 guifg=#ffffff
    DevIconR                                { fg="#2266ba", }, -- DevIconR       xxx ctermfg=25 guifg=#2266ba
    DevIconNextConfigJs                     { fg="#ffffff", }, -- DevIconNextConfigJs xxx ctermfg=231 guifg=#ffffff
    DevIconNextConfigCjs                    { fg="#ffffff", }, -- DevIconNextConfigCjs xxx ctermfg=231 guifg=#ffffff
    DevIconConda                            { fg="#43b02a", }, -- DevIconConda   xxx ctermfg=34 guifg=#43b02a
    DevIconEndeavour                        { fg="#7b3db9", }, -- DevIconEndeavour xxx ctermfg=91 guifg=#7b3db9
    DevIconElementary                       { fg="#5890c2", }, -- DevIconElementary xxx ctermfg=67 guifg=#5890c2
    DevIconLXQtConfigFile                   { fg="#0192d3", }, -- DevIconLXQtConfigFile xxx ctermfg=32 guifg=#0192d3
    DevIconDevuan                           { fg="#404a52", }, -- DevIconDevuan  xxx ctermfg=238 guifg=#404a52
    DevIconDeepin                           { fg="#2ca7f8", }, -- DevIconDeepin  xxx ctermfg=39 guifg=#2ca7f8
    DevIconGodotProject                     { fg="#6d8086", }, -- DevIconGodotProject xxx ctermfg=66 guifg=#6d8086
    DevIconBinaryGLTF                       { fg="#ffb13b", }, -- DevIconBinaryGLTF xxx ctermfg=214 guifg=#ffb13b
    DevIconGemfile                          { fg="#701516", }, -- DevIconGemfile xxx ctermfg=52 guifg=#701516
    DevIconLicense                          { fg="#d0bf41", }, -- DevIconLicense xxx ctermfg=185 guifg=#d0bf41
    DevIconKritarc                          { fg="#f245fb", }, -- DevIconKritarc xxx ctermfg=201 guifg=#f245fb
    DevIconCrystalLinux                     { fg="#a900ff", }, -- DevIconCrystalLinux xxx ctermfg=129 guifg=#a900ff
    DevIconCoffee                           { fg="#cbcb41", }, -- DevIconCoffee  xxx ctermfg=185 guifg=#cbcb41
    DevIconAPL                              { fg="#24a148", }, -- DevIconAPL     xxx ctermfg=35 guifg=#24a148
    DevIconAvif                             { fg="#a074c4", }, -- DevIconAvif    xxx ctermfg=140 guifg=#a074c4
    DevIconKritadisplayrc                   { fg="#f245fb", }, -- DevIconKritadisplayrc xxx ctermfg=201 guifg=#f245fb
    DevIconGitCommit                        { fg="#f54d27", }, -- DevIconGitCommit xxx ctermfg=196 guifg=#f54d27
    DevIconKdenliverc                       { fg="#83b8f2", }, -- DevIconKdenliverc xxx ctermfg=110 guifg=#83b8f2
    DevIconBrewfile                         { fg="#701516", }, -- DevIconBrewfile xxx ctermfg=52 guifg=#701516
    DevIconEjs                              { fg="#cbcb41", }, -- DevIconEjs     xxx ctermfg=185 guifg=#cbcb41
    DevIconBigLinux                         { fg="#189fc8", }, -- DevIconBigLinux xxx ctermfg=38 guifg=#189fc8
    DevIconHyprland                         { fg="#00aaae", }, -- DevIconHyprland xxx ctermfg=37 guifg=#00aaae
    DevIconKdenliveLayoutsrc                { fg="#83b8f2", }, -- DevIconKdenliveLayoutsrc xxx ctermfg=110 guifg=#83b8f2
    DevIconPackedResource                   { fg="#6d8086", }, -- DevIconPackedResource xxx ctermfg=66 guifg=#6d8086
    DevIconArtix                            { fg="#41b4d7", }, -- DevIconArtix   xxx ctermfg=38 guifg=#41b4d7
    DevIconPyd                              { fg="#ffe291", }, -- DevIconPyd     xxx ctermfg=222 guifg=#ffe291
    DevIconDrools                           { fg="#ffafaf", }, -- DevIconDrools  xxx ctermfg=217 guifg=#ffafaf
    DevIconArcoLinux                        { fg="#6690eb", }, -- DevIconArcoLinux xxx ctermfg=68 guifg=#6690eb
    DevIconZshprofile                       { fg="#89e051", }, -- DevIconZshprofile xxx ctermfg=113 guifg=#89e051
    DevIconLock                             { fg="#bbbbbb", }, -- DevIconLock    xxx ctermfg=250 guifg=#bbbbbb
    DevIconVagrantfile                      { fg="#1563ff", }, -- DevIconVagrantfile xxx ctermfg=27 guifg=#1563ff
    DevIconArchlabs                         { fg="#503f42", }, -- DevIconArchlabs xxx ctermfg=238 guifg=#503f42
    DevIconWebpack                          { fg="#519aba", }, -- DevIconWebpack xxx ctermfg=74 guifg=#519aba
    DevIconXcPlayground                     { fg="#e37933", }, -- DevIconXcPlayground xxx ctermfg=166 guifg=#e37933
    DevIconIndexTheme                       { fg="#2db96f", }, -- DevIconIndexTheme xxx ctermfg=35 guifg=#2db96f
    DevIconArchcraft                        { fg="#86bba3", }, -- DevIconArchcraft xxx ctermfg=108 guifg=#86bba3
    DevIconWasm                             { fg="#5c4cdb", }, -- DevIconWasm    xxx ctermfg=62 guifg=#5c4cdb
    DevIconSuo                              { fg="#854cc7", }, -- DevIconSuo     xxx ctermfg=98 guifg=#854cc7
    DevIconApple                            { fg="#a2aaad", }, -- DevIconApple   xxx ctermfg=248 guifg=#a2aaad
    DevIconPyo                              { fg="#ffe291", }, -- DevIconPyo     xxx ctermfg=222 guifg=#ffe291
    DevIconPsd                              { fg="#519aba", }, -- DevIconPsd     xxx ctermfg=74 guifg=#519aba
    DevIconPsb                              { fg="#519aba", }, -- DevIconPsb     xxx ctermfg=74 guifg=#519aba
    DevIconAOSC                             { fg="#c00000", }, -- DevIconAOSC    xxx ctermfg=124 guifg=#c00000
    DevIconOpenTypeFont                     { fg="#ececec", }, -- DevIconOpenTypeFont xxx ctermfg=255 guifg=#ececec
    DevIconMdx                              { fg="#519aba", }, -- DevIconMdx     xxx ctermfg=74 guifg=#519aba
    DevIconMaterial                         { fg="#b83998", }, -- DevIconMaterial xxx ctermfg=163 guifg=#b83998
    DevIconHyprlandd                        { fg="#00aaae", }, -- DevIconHyprlandd xxx ctermfg=37 guifg=#00aaae
    DevIconAlmalinux                        { fg="#ff4649", }, -- DevIconAlmalinux xxx ctermfg=203 guifg=#ff4649
    DevIconGulpfile                         { fg="#cc3e44", }, -- DevIconGulpfile xxx ctermfg=167 guifg=#cc3e44
    DevIconHTTP                             { fg="#008ec7", }, -- DevIconHTTP    xxx ctermfg=31 guifg=#008ec7
    DevIconD                                { fg="#b03931", }, -- DevIconD       xxx ctermfg=124 guifg=#b03931
    DevIconPng                              { fg="#a074c4", }, -- DevIconPng     xxx ctermfg=140 guifg=#a074c4
    DevIconJpg                              { fg="#a074c4", }, -- DevIconJpg     xxx ctermfg=140 guifg=#a074c4
    DevIconLog                              { fg="#dddddd", }, -- DevIconLog     xxx ctermfg=253 guifg=#dddddd
    DevIconGif                              { fg="#a074c4", }, -- DevIconGif     xxx ctermfg=140 guifg=#a074c4
    DevIconSha512                           { fg="#8c86af", }, -- DevIconSha512  xxx ctermfg=103 guifg=#8c86af
    DevIconSvg                              { fg="#ffb13b", }, -- DevIconSvg     xxx ctermfg=214 guifg=#ffb13b
    DevIconGruntfile                        { fg="#e37933", }, -- DevIconGruntfile xxx ctermfg=166 guifg=#e37933
    DevIconMOV                              { fg="#fd971f", }, -- DevIconMOV     xxx ctermfg=208 guifg=#fd971f
    DevIconWebm                             { fg="#fd971f", }, -- DevIconWebm    xxx ctermfg=208 guifg=#fd971f
    DevIconGradleWrapperScript              { fg="#005f87", }, -- DevIconGradleWrapperScript xxx ctermfg=24 guifg=#005f87
    DevIconSha224                           { fg="#8c86af", }, -- DevIconSha224  xxx ctermfg=103 guifg=#8c86af
    DevIconGradleProperties                 { fg="#005f87", }, -- DevIconGradleProperties xxx ctermfg=24 guifg=#005f87
    DevIconSha1                             { fg="#8c86af", }, -- DevIconSha1    xxx ctermfg=103 guifg=#8c86af
    DevIconGradleWrapperProperties          { fg="#005f87", }, -- DevIconGradleWrapperProperties xxx ctermfg=24 guifg=#005f87
    DevIconLibreOfficeWriter                { fg="#2dcbfd", }, -- DevIconLibreOfficeWriter xxx ctermfg=81 guifg=#2dcbfd
    DevIconLibreOfficeCalc                  { fg="#78fc4e", }, -- DevIconLibreOfficeCalc xxx ctermfg=119 guifg=#78fc4e
    DevIconLibreOfficeImpress               { fg="#fe9c45", }, -- DevIconLibreOfficeImpress xxx ctermfg=215 guifg=#fe9c45
    DevIconLibreOfficeGraphics              { fg="#fffb57", }, -- DevIconLibreOfficeGraphics xxx ctermfg=227 guifg=#fffb57
    DevIconLXQt                             { fg="#0191d2", }, -- DevIconLXQt    xxx ctermfg=32 guifg=#0191d2
    DevIconGoMod                            { fg="#00add8", }, -- DevIconGoMod   xxx ctermfg=38 guifg=#00add8
    DevIconLXDE                             { fg="#a4a4a4", }, -- DevIconLXDE    xxx ctermfg=248 guifg=#a4a4a4
    DevIconKiCadFootprintTable              { fg="#ffffff", }, -- DevIconKiCadFootprintTable xxx ctermfg=231 guifg=#ffffff
    DevIconSql                              { fg="#dad8d8", }, -- DevIconSql     xxx ctermfg=188 guifg=#dad8d8
    DevIconKiCadCache                       { fg="#ffffff", }, -- DevIconKiCadCache xxx ctermfg=231 guifg=#ffffff
    DevIconXSettingsdConf                   { fg="#e54d18", }, -- DevIconXSettingsdConf xxx ctermfg=196 guifg=#e54d18
    DevIconFavicon                          { fg="#cbcb41", }, -- DevIconFavicon xxx ctermfg=185 guifg=#cbcb41
    DevIconFdmdownload                      { fg="#44cda8", }, -- DevIconFdmdownload xxx ctermfg=43 guifg=#44cda8
    DevIconBudgie                           { fg="#4e5361", }, -- DevIconBudgie  xxx ctermfg=240 guifg=#4e5361
    DevIconTypoScriptSetup                  { fg="#ff8700", }, -- DevIconTypoScriptSetup xxx ctermfg=208 guifg=#ff8700
    DevIconxmonad                           { fg="#fd4d5d", }, -- DevIconxmonad  xxx ctermfg=203 guifg=#fd4d5d
    DevIconFreeCAD                          { fg="#cb333b", }, -- DevIconFreeCAD xxx ctermfg=160 guifg=#cb333b
    DevIconEslintrc                         { fg="#4b32c3", }, -- DevIconEslintrc xxx ctermfg=56 guifg=#4b32c3
    DevIconWranglerConfig                   { fg="#f48120", }, -- DevIconWranglerConfig xxx ctermfg=208 guifg=#f48120
    DevIconSecurity                         { fg="#bec4c9", }, -- DevIconSecurity xxx ctermfg=251 guifg=#bec4c9
    DevIconDockerfile                       { fg="#458ee6", }, -- DevIconDockerfile xxx ctermfg=68 guifg=#458ee6
    DevIconOpenGLShadingLanguage            { fg="#5586a6", }, -- DevIconOpenGLShadingLanguage xxx ctermfg=67 guifg=#5586a6
    DevIconriver                            { fg="#000000", }, -- DevIconriver   xxx ctermfg=16 guifg=#000000
    DevIconEmbeddedOpenTypeFont             { fg="#ececec", }, -- DevIconEmbeddedOpenTypeFont xxx ctermfg=255 guifg=#ececec
    DevIconQtile                            { fg="#ffffff", }, -- DevIconQtile   xxx ctermfg=231 guifg=#ffffff
    DevIconQt                               { fg="#40cd52", }, -- DevIconQt      xxx ctermfg=77 guifg=#40cd52
    DevIconFragmentShader                   { fg="#5586a6", }, -- DevIconFragmentShader xxx ctermfg=67 guifg=#5586a6
    DevIconFluxbox                          { fg="#555555", }, -- DevIconFluxbox xxx ctermfg=240 guifg=#555555
    DevIconVLC                              { fg="#ee7a00", }, -- DevIconVLC     xxx ctermfg=208 guifg=#ee7a00
    DevIconElisp                            { fg="#8172be", }, -- DevIconElisp   xxx ctermfg=97 guifg=#8172be
    DevIconEnlightenment                    { fg="#ffffff", }, -- DevIconEnlightenment xxx ctermfg=231 guifg=#ffffff
    DevIconCodeOfConduct                    { fg="#e41662", }, -- DevIconCodeOfConduct xxx ctermfg=161 guifg=#e41662
    DevIconCMakeLists                       { fg="#dce3eb", }, -- DevIconCMakeLists xxx ctermfg=254 guifg=#dce3eb
    DevIcondwm                              { fg="#1177aa", }, -- DevIcondwm     xxx ctermfg=31 guifg=#1177aa
    DevIconVitestConfig                     { fg="#739b1b", }, -- DevIconVitestConfig xxx ctermfg=106 guifg=#739b1b
    DevIconawesome                          { fg="#535d6c", }, -- DevIconawesome xxx ctermfg=59 guifg=#535d6c
    DevIconVercel                           { fg="#ffffff", }, -- DevIconVercel  xxx ctermfg=231 guifg=#ffffff
    DevIconBunLockfile                      { fg="#eadcd1", }, -- DevIconBunLockfile xxx ctermfg=253 guifg=#eadcd1
    DevIconPrusaSlicer                      { fg="#ec6b23", }, -- DevIconPrusaSlicer xxx ctermfg=202 guifg=#ec6b23
    DevIconAUTHORS                          { fg="#a172ff", }, -- DevIconAUTHORS xxx ctermfg=135 guifg=#a172ff
    DevIconBuildProps                       { fg="#00a2ff", }, -- DevIconBuildProps xxx ctermfg=75 guifg=#00a2ff
    DevIconPKGBUILD                         { fg="#0f94d2", }, -- DevIconPKGBUILD xxx ctermfg=67 guifg=#0f94d2
    DevIconBuildTargets                     { fg="#00a2ff", }, -- DevIconBuildTargets xxx ctermfg=75 guifg=#00a2ff
    DevIconGradleBuildScript                { fg="#005f87", }, -- DevIconGradleBuildScript xxx ctermfg=24 guifg=#005f87
    DevIconSRCINFO                          { fg="#0f94d2", }, -- DevIconSRCINFO xxx ctermfg=67 guifg=#0f94d2
    DevIconJenkins                          { fg="#d33833", }, -- DevIconJenkins xxx ctermfg=160 guifg=#d33833
    DevIconBSPWM                            { fg="#2f2f2f", }, -- DevIconBSPWM   xxx ctermfg=236 guifg=#2f2f2f
    DevIconXresources                       { fg="#e54d18", }, -- DevIconXresources xxx ctermfg=196 guifg=#e54d18
    DevIconFsi                              { fg="#519aba", }, -- DevIconFsi     xxx ctermfg=74 guifg=#519aba
    DevIconTmux                             { fg="#14ba19", }, -- DevIconTmux    xxx ctermfg=34 guifg=#14ba19
    DevIconTailwindConfig                   { fg="#20c2e3", }, -- DevIconTailwindConfig xxx ctermfg=45 guifg=#20c2e3
    DevIconDconf                            { fg="#ffffff", }, -- DevIconDconf   xxx ctermfg=231 guifg=#ffffff
    DevIconKiCadSymbolTable                 { fg="#ffffff", }, -- DevIconKiCadSymbolTable xxx ctermfg=231 guifg=#ffffff
    DevIconTypeScriptDeclaration            { fg="#d59855", }, -- DevIconTypeScriptDeclaration xxx ctermfg=172 guifg=#d59855
    DevIconPulseCodeModulation              { fg="#0075aa", }, -- DevIconPulseCodeModulation xxx ctermfg=24 guifg=#0075aa
    DevIconSvelteConfig                     { fg="#ff3e00", }, -- DevIconSvelteConfig xxx ctermfg=196 guifg=#ff3e00
    DevIconGradleSettings                   { fg="#005f87", }, -- DevIconGradleSettings xxx ctermfg=24 guifg=#005f87
    DevIconPart                             { fg="#44cda8", }, -- DevIconPart    xxx ctermfg=43 guifg=#44cda8
    DevIconCrdownload                       { fg="#44cda8", }, -- DevIconCrdownload xxx ctermfg=43 guifg=#44cda8
    DevIconOggMultiplex                     { fg="#fd971f", }, -- DevIconOggMultiplex xxx ctermfg=208 guifg=#fd971f
    DevIconOggVideo                         { fg="#fd971f", }, -- DevIconOggVideo xxx ctermfg=208 guifg=#fd971f
    DevIconOggVorbis                        { fg="#0075aa", }, -- DevIconOggVorbis xxx ctermfg=24 guifg=#0075aa
    DevIconTempl                            { fg="#dbbd30", }, -- DevIconTempl   xxx ctermfg=178 guifg=#dbbd30
    DevIconCowsayFile                       { fg="#965824", }, -- DevIconCowsayFile xxx ctermfg=130 guifg=#965824
    DevIconImg                              { fg="#d0bec8", }, -- DevIconImg     xxx ctermfg=181 guifg=#d0bec8
    DevIconSln                              { fg="#854cc7", }, -- DevIconSln     xxx ctermfg=98 guifg=#854cc7
    DevIconImage                            { fg="#d0bec8", }, -- DevIconImage   xxx ctermfg=181 guifg=#d0bec8
    DevIconConfigRu                         { fg="#701516", }, -- DevIconConfigRu xxx ctermfg=52 guifg=#701516
    DevIconIges                             { fg="#839463", }, -- DevIconIges    xxx ctermfg=101 guifg=#839463
    DevIconIge                              { fg="#839463", }, -- DevIconIge     xxx ctermfg=101 guifg=#839463
    DevIconXorgConf                         { fg="#e54d18", }, -- DevIconXorgConf xxx ctermfg=196 guifg=#e54d18
    DevIconClojureDart                      { fg="#519aba", }, -- DevIconClojureDart xxx ctermfg=74 guifg=#519aba
    DevIconSystemVerilog                    { fg="#019833", }, -- DevIconSystemVerilog xxx ctermfg=28 guifg=#019833
    DevIconLibreOfficeFormula               { fg="#ff5a96", }, -- DevIconLibreOfficeFormula xxx ctermfg=204 guifg=#ff5a96
    DevIconIcalendar                        { fg="#2b2e83", }, -- DevIconIcalendar xxx ctermfg=18 guifg=#2b2e83
    DevIconIcal                             { fg="#2b2e83", }, -- DevIconIcal    xxx ctermfg=18 guifg=#2b2e83
    DevIconBashrc                           { fg="#89e051", }, -- DevIconBashrc  xxx ctermfg=113 guifg=#89e051
    DevIconNswag                            { fg="#85ea2d", }, -- DevIconNswag   xxx ctermfg=112 guifg=#85ea2d
    DevIconBoundaryRepresentation           { fg="#839463", }, -- DevIconBoundaryRepresentation xxx ctermfg=101 guifg=#839463
    DevIconHuff                             { fg="#4242c7", }, -- DevIconHuff    xxx ctermfg=56 guifg=#4242c7
    DevIconSvgz                             { fg="#ffb13b", }, -- DevIconSvgz    xxx ctermfg=214 guifg=#ffb13b
    DevIconNfo                              { fg="#ffffcd", }, -- DevIconNfo     xxx ctermfg=230 guifg=#ffffcd
    DevIconJavaScriptReactTest              { fg="#20c2e3", }, -- DevIconJavaScriptReactTest xxx ctermfg=45 guifg=#20c2e3
    DevIconWaveformAudioFile                { fg="#00afff", }, -- DevIconWaveformAudioFile xxx ctermfg=39 guifg=#00afff
    DevIconAzureCli                         { fg="#0078d4", }, -- DevIconAzureCli xxx ctermfg=32 guifg=#0078d4
    DevIconManjaro                          { fg="#33b959", }, -- DevIconManjaro xxx ctermfg=35 guifg=#33b959
    DevIconOut                              { fg="#9f0500", }, -- DevIconOut     xxx ctermfg=124 guifg=#9f0500
    DevIconBlade                            { fg="#f05340", }, -- DevIconBlade   xxx ctermfg=203 guifg=#f05340
    DevIconBashProfile                      { fg="#89e051", }, -- DevIconBashProfile xxx ctermfg=113 guifg=#89e051
    DevIconAstro                            { fg="#e23f67", }, -- DevIconAstro   xxx ctermfg=197 guifg=#e23f67
    DevIconRmd                              { fg="#519aba", }, -- DevIconRmd     xxx ctermfg=74 guifg=#519aba
    DevIconMpp                              { fg="#519aba", }, -- DevIconMpp     xxx ctermfg=74 guifg=#519aba
    DevIconDebian                           { fg="#a80030", }, -- DevIconDebian  xxx ctermfg=88 guifg=#a80030
    DevIconGNOME                            { fg="#ffffff", }, -- DevIconGNOME   xxx ctermfg=231 guifg=#ffffff
    DevIconBash                             { fg="#89e051", }, -- DevIconBash    xxx ctermfg=113 guifg=#89e051
    DevIconFedora                           { fg="#072a5e", }, -- DevIconFedora  xxx ctermfg=17 guifg=#072a5e
    DevIconMobi                             { fg="#eab16d", }, -- DevIconMobi    xxx ctermfg=215 guifg=#eab16d
    DevIconNPMrc                            { fg="#e8274b", }, -- DevIconNPMrc   xxx ctermfg=197 guifg=#e8274b
    DevIconEx                               { fg="#a074c4", }, -- DevIconEx      xxx ctermfg=140 guifg=#a074c4
    DevIconTails                            { fg="#56347c", }, -- DevIconTails   xxx ctermfg=54 guifg=#56347c
    DevIconHypridle                         { fg="#00aaae", }, -- DevIconHypridle xxx ctermfg=37 guifg=#00aaae
    DevIconHyprlock                         { fg="#00aaae", }, -- DevIconHyprlock xxx ctermfg=37 guifg=#00aaae
    DevIconXeroLinux                        { fg="#888fe2", }, -- DevIconXeroLinux xxx ctermfg=104 guifg=#888fe2
    DevIconTrisquelGNULinux                 { fg="#0f58b6", }, -- DevIconTrisquelGNULinux xxx ctermfg=25 guifg=#0f58b6
    DevIconArch                             { fg="#0f94d2", }, -- DevIconArch    xxx ctermfg=67 guifg=#0f94d2
    DevIconCache                            { fg="#ffffff", }, -- DevIconCache   xxx ctermfg=231 guifg=#ffffff
    DevIconVoid                             { fg="#295340", }, -- DevIconVoid    xxx ctermfg=23 guifg=#295340
    DevIconSolus                            { fg="#4b5163", }, -- DevIconSolus   xxx ctermfg=239 guifg=#4b5163
    DevIconLuacheckrc                       { fg="#00a2ff", }, -- DevIconLuacheckrc xxx ctermfg=75 guifg=#00a2ff
    DevIconCsh                              { fg="#4d5a5e", }, -- DevIconCsh     xxx ctermfg=240 guifg=#4d5a5e
    DevIconMATE                             { fg="#9bda5c", }, -- DevIconMATE    xxx ctermfg=113 guifg=#9bda5c
    DevIconXfce                             { fg="#00aadf", }, -- DevIconXfce    xxx ctermfg=74 guifg=#00aadf
    DevIconMd5                              { fg="#8c86af", }, -- DevIconMd5     xxx ctermfg=103 guifg=#8c86af
    DevIconKali                             { fg="#2777ff", }, -- DevIconKali    xxx ctermfg=69 guifg=#2777ff
    DevIconCinnamon                         { fg="#dc682e", }, -- DevIconCinnamon xxx ctermfg=166 guifg=#dc682e
    DevIconJs                               { fg="#cbcb41", }, -- DevIconJs      xxx ctermfg=185 guifg=#cbcb41
    DevIconJWM                              { fg="#0078cd", }, -- DevIconJWM     xxx ctermfg=32 guifg=#0078cd
    DevIconRasi                             { fg="#cbcb41", }, -- DevIconRasi    xxx ctermfg=185 guifg=#cbcb41
    DevIconCantorrc                         { fg="#1c99f3", }, -- DevIconCantorrc xxx ctermfg=32 guifg=#1c99f3
    DevIconHaml                             { fg="#eaeae1", }, -- DevIconHaml    xxx ctermfg=255 guifg=#eaeae1
    DevIconIgs                              { fg="#839463", }, -- DevIconIgs     xxx ctermfg=101 guifg=#839463
    DevIconGv                               { fg="#30638e", }, -- DevIconGv      xxx ctermfg=24 guifg=#30638e
    DevIconPyLintConfig                     { fg="#6d8086", }, -- DevIconPyLintConfig xxx ctermfg=66 guifg=#6d8086
    DevIconSha256                           { fg="#8c86af", }, -- DevIconSha256  xxx ctermfg=103 guifg=#8c86af
    DevIconGleam                            { fg="#ffaff3", }, -- DevIconGleam   xxx ctermfg=219 guifg=#ffaff3
    DevIconFs                               { fg="#519aba", }, -- DevIconFs      xxx ctermfg=74 guifg=#519aba
    DevIconCommitlintConfig                 { fg="#2b9689", }, -- DevIconCommitlintConfig xxx ctermfg=30 guifg=#2b9689
    DevIconKalgebrarc                       { fg="#1c99f3", }, -- DevIconKalgebrarc xxx ctermfg=32 guifg=#1c99f3
    DevIconXDPH                             { fg="#00aaae", }, -- DevIconXDPH    xxx ctermfg=37 guifg=#00aaae
    DevIconRlib                             { fg="#dea584", }, -- DevIconRlib    xxx ctermfg=216 guifg=#dea584
    DevIconNushell                          { fg="#3aa675", }, -- DevIconNushell xxx ctermfg=36 guifg=#3aa675
    DevIconZshenv                           { fg="#89e051", }, -- DevIconZshenv  xxx ctermfg=113 guifg=#89e051
    DevIconAlpine                           { fg="#0d597f", }, -- DevIconAlpine  xxx ctermfg=24 guifg=#0d597f
    DevIconFortran                          { fg="#734f96", }, -- DevIconFortran xxx ctermfg=97 guifg=#734f96
    DevIconReScript                         { fg="#cc3e44", }, -- DevIconReScript xxx ctermfg=167 guifg=#cc3e44
    DevIconHaxe                             { fg="#ea8220", }, -- DevIconHaxe    xxx ctermfg=208 guifg=#ea8220
    DevIconI18nConfig                       { fg="#7986cb", }, -- DevIconI18nConfig xxx ctermfg=104 guifg=#7986cb
    DevIconJustfile                         { fg="#6d8086", }, -- DevIconJustfile xxx ctermfg=66 guifg=#6d8086
    DevIconHyprsunset                       { fg="#00aaae", }, -- DevIconHyprsunset xxx ctermfg=37 guifg=#00aaae
    DevIconLiquid                           { fg="#95bf47", }, -- DevIconLiquid  xxx ctermfg=106 guifg=#95bf47
    DevIconIco                              { fg="#cbcb41", }, -- DevIconIco     xxx ctermfg=185 guifg=#cbcb41
    DevIconLuaurc                           { fg="#00a2ff", }, -- DevIconLuaurc  xxx ctermfg=75 guifg=#00a2ff
    DevIconSwift                            { fg="#e37933", }, -- DevIconSwift   xxx ctermfg=166 guifg=#e37933
    DevIconMl                               { fg="#e37933", }, -- DevIconMl      xxx ctermfg=166 guifg=#e37933
    DevIconSublime                          { fg="#e37933", }, -- DevIconSublime xxx ctermfg=166 guifg=#e37933
    DevIconBabelrc                          { fg="#cbcb41", }, -- DevIconBabelrc xxx ctermfg=185 guifg=#cbcb41
    DevIconFsharp                           { fg="#519aba", }, -- DevIconFsharp  xxx ctermfg=74 guifg=#519aba
    DevIconOdin                             { fg="#3882d2", }, -- DevIconOdin    xxx ctermfg=32 guifg=#3882d2
    DevIconTypeScriptReactSpec              { fg="#1354bf", }, -- DevIconTypeScriptReactSpec xxx ctermfg=26 guifg=#1354bf
    DevIconHyprpaper                        { fg="#00aaae", }, -- DevIconHyprpaper xxx ctermfg=37 guifg=#00aaae
    DevIconPyw                              { fg="#5aa7e4", }, -- DevIconPyw     xxx ctermfg=39 guifg=#5aa7e4
    DevIconSway                             { fg="#68751c", }, -- DevIconSway    xxx ctermfg=64 guifg=#68751c
    DevIconSvelte                           { fg="#ff3e00", }, -- DevIconSvelte  xxx ctermfg=196 guifg=#ff3e00
    DevIconVlang                            { fg="#5d87bf", }, -- DevIconVlang   xxx ctermfg=67 guifg=#5d87bf
    DevIconLrc                              { fg="#ffb713", }, -- DevIconLrc     xxx ctermfg=214 guifg=#ffb713
    DevIconLuau                             { fg="#00a2ff", }, -- DevIconLuau    xxx ctermfg=75 guifg=#00a2ff
    DevIconRproj                            { fg="#358a5b", }, -- DevIconRproj   xxx ctermfg=29 guifg=#358a5b
    DevIconStyl                             { fg="#8dc149", }, -- DevIconStyl    xxx ctermfg=113 guifg=#8dc149
    DevIconRb                               { fg="#701516", }, -- DevIconRb      xxx ctermfg=52 guifg=#701516
    DevIconSlim                             { fg="#e34c26", }, -- DevIconSlim    xxx ctermfg=196 guifg=#e34c26
    DevIconTor                              { fg="#519aba", }, -- DevIconTor     xxx ctermfg=74 guifg=#519aba
    DevIconBz2                              { fg="#eca517", }, -- DevIconBz2     xxx ctermfg=214 guifg=#eca517
    DevIconScala                            { fg="#cc3e44", }, -- DevIconScala   xxx ctermfg=167 guifg=#cc3e44
    DevIconKDEglobals                       { fg="#1c99f3", }, -- DevIconKDEglobals xxx ctermfg=32 guifg=#1c99f3
    DevIconErb                              { fg="#701516", }, -- DevIconErb     xxx ctermfg=52 guifg=#701516
    DevIconSsa                              { fg="#ffb713", }, -- DevIconSsa     xxx ctermfg=214 guifg=#ffb713
    DevIconSrt                              { fg="#ffb713", }, -- DevIconSrt     xxx ctermfg=214 guifg=#ffb713
    DevIconHrl                              { fg="#b83998", }, -- DevIconHrl     xxx ctermfg=163 guifg=#b83998
    DevIconErl                              { fg="#b83998", }, -- DevIconErl     xxx ctermfg=163 guifg=#b83998
    DevIconDropbox                          { fg="#0061fe", }, -- DevIconDropbox xxx ctermfg=27 guifg=#0061fe
    DevIconEpp                              { fg="#ffa61a", }, -- DevIconEpp     xxx ctermfg=214 guifg=#ffa61a
    DevIconEpub                             { fg="#eab16d", }, -- DevIconEpub    xxx ctermfg=215 guifg=#eab16d
    DevIconGroovy                           { fg="#4a687c", }, -- DevIconGroovy  xxx ctermfg=24 guifg=#4a687c
    DevIconRobotsTxt                        { fg="#5d7096", }, -- DevIconRobotsTxt xxx ctermfg=60 guifg=#5d7096
    DevIconDump                             { fg="#dad8d8", }, -- DevIconDump    xxx ctermfg=188 guifg=#dad8d8
    DevIconSketchUp                         { fg="#839463", }, -- DevIconSketchUp xxx ctermfg=101 guifg=#839463
    DevIconTemplate                         { fg="#dbbd30", }, -- DevIconTemplate xxx ctermfg=178 guifg=#dbbd30
    DevIconBin                              { fg="#9f0500", }, -- DevIconBin     xxx ctermfg=124 guifg=#9f0500
    DevIconXul                              { fg="#e37933", }, -- DevIconXul     xxx ctermfg=166 guifg=#e37933
    DevIconGoWork                           { fg="#00add8", }, -- DevIconGoWork  xxx ctermfg=38 guifg=#00add8
    DevIconExs                              { fg="#a074c4", }, -- DevIconExs     xxx ctermfg=140 guifg=#a074c4
    DevIconLeex                             { fg="#a074c4", }, -- DevIconLeex    xxx ctermfg=140 guifg=#a074c4
    DevIconLess                             { fg="#563d7c", }, -- DevIconLess    xxx ctermfg=54 guifg=#563d7c
    DevIconGoSum                            { fg="#00add8", }, -- DevIconGoSum   xxx ctermfg=38 guifg=#00add8
    DevIconBat                              { fg="#c1f12e", }, -- DevIconBat     xxx ctermfg=191 guifg=#c1f12e
    DevIconMagnet                           { fg="#a51b16", }, -- DevIconMagnet  xxx ctermfg=124 guifg=#a51b16
    DevIconClojureC                         { fg="#8dc149", }, -- DevIconClojureC xxx ctermfg=113 guifg=#8dc149
    DevIconStaticLibraryArchive             { fg="#dcddd6", }, -- DevIconStaticLibraryArchive xxx ctermfg=253 guifg=#dcddd6
    DevIconPyc                              { fg="#ffe291", }, -- DevIconPyc     xxx ctermfg=222 guifg=#ffe291
    DevIconMkv                              { fg="#fd971f", }, -- DevIconMkv     xxx ctermfg=208 guifg=#fd971f
    DevIconFreeLosslessAudioCodec           { fg="#0075aa", }, -- DevIconFreeLosslessAudioCodec xxx ctermfg=24 guifg=#0075aa
    DevIconColdFusionTag                    { fg="#01a4ba", }, -- DevIconColdFusionTag xxx ctermfg=38 guifg=#01a4ba
    DevIconColdFusionScript                 { fg="#01a4ba", }, -- DevIconColdFusionScript xxx ctermfg=38 guifg=#01a4ba
    DevIconMPEGAudioLayerIII                { fg="#00afff", }, -- DevIconMPEGAudioLayerIII xxx ctermfg=39 guifg=#00afff
    DevIconQuery                            { fg="#90a850", }, -- DevIconQuery   xxx ctermfg=107 guifg=#90a850
    DevIconSte                              { fg="#839463", }, -- DevIconSte     xxx ctermfg=101 guifg=#839463
    DevIconGodotTextScene                   { fg="#6d8086", }, -- DevIconGodotTextScene xxx ctermfg=66 guifg=#6d8086
    DevIconLua                              { fg="#51a0cf", }, -- DevIconLua     xxx ctermfg=74 guifg=#51a0cf
    DevIconProlog                           { fg="#e4b854", }, -- DevIconProlog  xxx ctermfg=179 guifg=#e4b854
    DevIconH                                { fg="#a074c4", }, -- DevIconH       xxx ctermfg=140 guifg=#a074c4
    DevIconPackageLockJson                  { fg="#7a0d21", }, -- DevIconPackageLockJson xxx ctermfg=52 guifg=#7a0d21
    DevIconHpp                              { fg="#a074c4", }, -- DevIconHpp     xxx ctermfg=140 guifg=#a074c4
    DevIconNPMIgnore                        { fg="#e8274b", }, -- DevIconNPMIgnore xxx ctermfg=197 guifg=#e8274b
    DevIconBazel                            { fg="#89e051", }, -- DevIconBazel   xxx ctermfg=113 guifg=#89e051
    DevIconBlueprint                        { fg="#5796e2", }, -- DevIconBlueprint xxx ctermfg=68 guifg=#5796e2
    DevIconGitAttributes                    { fg="#f54d27", }, -- DevIconGitAttributes xxx ctermfg=196 guifg=#f54d27
    DevIconGitModules                       { fg="#f54d27", }, -- DevIconGitModules xxx ctermfg=196 guifg=#f54d27
    DevIconPsScriptModulefile               { fg="#6975c4", }, -- DevIconPsScriptModulefile xxx ctermfg=68 guifg=#6975c4
    DevIconGitConfig                        { fg="#f54d27", }, -- DevIconGitConfig xxx ctermfg=196 guifg=#f54d27
    DevIconJsx                              { fg="#20c2e3", }, -- DevIconJsx     xxx ctermfg=45 guifg=#20c2e3
    DevIcon3gp                              { fg="#fd971f", }, -- DevIcon3gp     xxx ctermfg=208 guifg=#fd971f
    DevIconBicepParameters                  { fg="#9f74b3", }, -- DevIconBicepParameters xxx ctermfg=133 guifg=#9f74b3
    DevIconBicep                            { fg="#519aba", }, -- DevIconBicep   xxx ctermfg=74 guifg=#519aba
    DevIconMp4                              { fg="#fd971f", }, -- DevIconMp4     xxx ctermfg=208 guifg=#fd971f
    DevIconDocx                             { fg="#185abd", }, -- DevIconDocx    xxx ctermfg=26 guifg=#185abd
    DevIconEex                              { fg="#a074c4", }, -- DevIconEex     xxx ctermfg=140 guifg=#a074c4
    DevIconGitIgnore                        { fg="#f54d27", }, -- DevIconGitIgnore xxx ctermfg=196 guifg=#f54d27
    DevIconMts                              { fg="#519aba", }, -- DevIconMts     xxx ctermfg=74 guifg=#519aba
    DevIconKrita                            { fg="#f245fb", }, -- DevIconKrita   xxx ctermfg=201 guifg=#f245fb
    DevIconASM                              { fg="#0071c5", }, -- DevIconASM     xxx ctermfg=25 guifg=#0071c5
    DevIconLinuxKernelObject                { fg="#dcddd6", }, -- DevIconLinuxKernelObject xxx ctermfg=253 guifg=#dcddd6
    DevIconJson                             { fg="#cbcb41", }, -- DevIconJson    xxx ctermfg=185 guifg=#cbcb41
    DevIconBibTeX                           { fg="#cbcb41", }, -- DevIconBibTeX  xxx ctermfg=185 guifg=#cbcb41
    DevIconKiCad                            { fg="#ffffff", }, -- DevIconKiCad   xxx ctermfg=231 guifg=#ffffff
    DevIconYaml                             { fg="#6d8086", }, -- DevIconYaml    xxx ctermfg=66 guifg=#6d8086
    DevIconDownload                         { fg="#44cda8", }, -- DevIconDownload xxx ctermfg=43 guifg=#44cda8
    DevIconKdenlive                         { fg="#83b8f2", }, -- DevIconKdenlive xxx ctermfg=110 guifg=#83b8f2
    DevIconKdbx                             { fg="#529b34", }, -- DevIconKdbx    xxx ctermfg=71 guifg=#529b34
    DevIconRs                               { fg="#dea584", }, -- DevIconRs      xxx ctermfg=216 guifg=#dea584
    DevIconMixLock                          { fg="#a074c4", }, -- DevIconMixLock xxx ctermfg=140 guifg=#a074c4
    DevIconOpusAudioFile                    { fg="#0075aa", }, -- DevIconOpusAudioFile xxx ctermfg=24 guifg=#0075aa
    DevIconKdb                              { fg="#529b34", }, -- DevIconKdb     xxx ctermfg=71 guifg=#529b34
    DevIconXaml                             { fg="#512bd4", }, -- DevIconXaml    xxx ctermfg=56 guifg=#512bd4
    DevIconKbx                              { fg="#737672", }, -- DevIconKbx     xxx ctermfg=243 guifg=#737672
    DevIconFusion360                        { fg="#839463", }, -- DevIconFusion360 xxx ctermfg=101 guifg=#839463
    DevIconEditorConfig                     { fg="#fff2f2", }, -- DevIconEditorConfig xxx ctermfg=255 guifg=#fff2f2
    DevIconToml                             { fg="#9c4221", }, -- DevIconToml    xxx ctermfg=124 guifg=#9c4221
    DevIconJpegXl                           { fg="#a074c4", }, -- DevIconJpegXl  xxx ctermfg=140 guifg=#a074c4
    DevIconGeometryShader                   { fg="#5586a6", }, -- DevIconGeometryShader xxx ctermfg=67 guifg=#5586a6
    DevIconStorybookJavaScript              { fg="#ff4785", }, -- DevIconStorybookJavaScript xxx ctermfg=204 guifg=#ff4785
    DevIconStorybookJsx                     { fg="#ff4785", }, -- DevIconStorybookJsx xxx ctermfg=204 guifg=#ff4785
    DevIconCson                             { fg="#cbcb41", }, -- DevIconCson    xxx ctermfg=185 guifg=#cbcb41
    DevIconLXDEConfigFile                   { fg="#909090", }, -- DevIconLXDEConfigFile xxx ctermfg=246 guifg=#909090
    DevIconPub                              { fg="#e3c58e", }, -- DevIconPub     xxx ctermfg=222 guifg=#e3c58e
    DevIconImportConfiguration              { fg="#ececec", }, -- DevIconImportConfiguration xxx ctermfg=255 guifg=#ececec
    DevIconScalaScript                      { fg="#cc3e44", }, -- DevIconScalaScript xxx ctermfg=167 guifg=#cc3e44
    DevIconTxz                              { fg="#eca517", }, -- DevIconTxz     xxx ctermfg=214 guifg=#eca517
    DevIconJar                              { fg="#ffaf67", }, -- DevIconJar     xxx ctermfg=215 guifg=#ffaf67
    DevIconVertexShader                     { fg="#5586a6", }, -- DevIconVertexShader xxx ctermfg=67 guifg=#5586a6
    DevIconIxx                              { fg="#519aba", }, -- DevIconIxx     xxx ctermfg=74 guifg=#519aba
    DevIconHs                               { fg="#a074c4", }, -- DevIconHs      xxx ctermfg=140 guifg=#a074c4
    DevIconCMake                            { fg="#dce3eb", }, -- DevIconCMake   xxx ctermfg=254 guifg=#dce3eb
    DevIconReScriptInterface                { fg="#f55385", }, -- DevIconReScriptInterface xxx ctermfg=204 guifg=#f55385
    DevIconSlackware                        { fg="#475fa9", }, -- DevIconSlackware xxx ctermfg=61 guifg=#475fa9
    DevIconBlender                          { fg="#ea7600", }, -- DevIconBlender xxx ctermfg=208 guifg=#ea7600
    DevIconProcfile                         { fg="#a074c4", }, -- DevIconProcfile xxx ctermfg=140 guifg=#a074c4
    DevIconPdf                              { fg="#b30b00", }, -- DevIconPdf     xxx ctermfg=124 guifg=#b30b00
    DevIconSolidWorksAsm                    { fg="#839463", }, -- DevIconSolidWorksAsm xxx ctermfg=101 guifg=#839463
    DevIconCheckhealth                      { fg="#75b4fb", }, -- DevIconCheckhealth xxx ctermfg=75 guifg=#75b4fb
    DevIconFennel                           { fg="#fff3d7", }, -- DevIconFennel  xxx ctermfg=230 guifg=#fff3d7
    DevIconZip                              { fg="#eca517", }, -- DevIconZip     xxx ctermfg=214 guifg=#eca517
    DevIconIonic                            { fg="#4f8ff7", }, -- DevIconIonic   xxx ctermfg=33 guifg=#4f8ff7
    DevIconZshrc                            { fg="#89e051", }, -- DevIconZshrc   xxx ctermfg=113 guifg=#89e051
    DevIconLibrecadFontFile                 { fg="#ececec", }, -- DevIconLibrecadFontFile xxx ctermfg=255 guifg=#ececec
    DevIconWeston                           { fg="#ffbb01", }, -- DevIconWeston  xxx ctermfg=214 guifg=#ffbb01
    DevIconXauthority                       { fg="#e54d18", }, -- DevIconXauthority xxx ctermfg=196 guifg=#e54d18
    DevIconPatch                            { fg="#41535b", }, -- DevIconPatch   xxx ctermfg=239 guifg=#41535b
    DevIconStorybookVue                     { fg="#ff4785", }, -- DevIconStorybookVue xxx ctermfg=204 guifg=#ff4785
    DevIconPackagesProps                    { fg="#00a2ff", }, -- DevIconPackagesProps xxx ctermfg=75 guifg=#00a2ff
    DevIconSolidity                         { fg="#519aba", }, -- DevIconSolidity xxx ctermfg=74 guifg=#519aba
    DevIconGitBlameIgnore                   { fg="#f54d27", }, -- DevIconGitBlameIgnore xxx ctermfg=196 guifg=#f54d27
    DevIconRakefile                         { fg="#701516", }, -- DevIconRakefile xxx ctermfg=52 guifg=#701516
    DevIconSml                              { fg="#e37933", }, -- DevIconSml     xxx ctermfg=166 guifg=#e37933
    DevIconExe                              { fg="#9f0500", }, -- DevIconExe     xxx ctermfg=124 guifg=#9f0500
    DevIconDockerIgnore                     { fg="#458ee6", }, -- DevIconDockerIgnore xxx ctermfg=68 guifg=#458ee6
    DevIconArduino                          { fg="#56b6c2", }, -- DevIconArduino xxx ctermfg=73 guifg=#56b6c2
    DevIconTSConfig                         { fg="#519aba", }, -- DevIconTSConfig xxx ctermfg=74 guifg=#519aba
    DevIconLhs                              { fg="#a074c4", }, -- DevIconLhs     xxx ctermfg=140 guifg=#a074c4
    DevIconFIGletFontControl                { fg="#ececec", }, -- DevIconFIGletFontControl xxx ctermfg=255 guifg=#ececec
    DevIconClojure                          { fg="#8dc149", }, -- DevIconClojure xxx ctermfg=113 guifg=#8dc149
    DevIconFreeCADConfig                    { fg="#cb333b", }, -- DevIconFreeCADConfig xxx ctermfg=160 guifg=#cb333b
    DevIconTex                              { fg="#3d6117", }, -- DevIconTex     xxx ctermfg=22 guifg=#3d6117
    DevIconZigObjectNotation                { fg="#f69a1b", }, -- DevIconZigObjectNotation xxx ctermfg=172 guifg=#f69a1b
    DevIconDoc                              { fg="#185abd", }, -- DevIconDoc     xxx ctermfg=26 guifg=#185abd
    DevIconBzl                              { fg="#89e051", }, -- DevIconBzl     xxx ctermfg=113 guifg=#89e051
    DevIconEbook                            { fg="#eab16d", }, -- DevIconEbook   xxx ctermfg=215 guifg=#eab16d
    DevIconStep                             { fg="#839463", }, -- DevIconStep    xxx ctermfg=101 guifg=#839463
    DevIconAss                              { fg="#ffb713", }, -- DevIconAss     xxx ctermfg=214 guifg=#ffb713
    DevIconAutoCADDxf                       { fg="#839463", }, -- DevIconAutoCADDxf xxx ctermfg=101 guifg=#839463
    DevIconAutoCADDwg                       { fg="#839463", }, -- DevIconAutoCADDwg xxx ctermfg=101 guifg=#839463
    DevIconGodotTextResource                { fg="#6d8086", }, -- DevIconGodotTextResource xxx ctermfg=66 guifg=#6d8086
    DevIconOpenSCAD                         { fg="#f9d72c", }, -- DevIconOpenSCAD xxx ctermfg=220 guifg=#f9d72c
    DevIconMotoko                           { fg="#9772fb", }, -- DevIconMotoko  xxx ctermfg=135 guifg=#9772fb
    DevIconFsx                              { fg="#519aba", }, -- DevIconFsx     xxx ctermfg=74 guifg=#519aba
    DevIconPyi                              { fg="#ffbc03", }, -- DevIconPyi     xxx ctermfg=214 guifg=#ffbc03
    DevIconPy                               { fg="#ffbc03", }, -- DevIconPy      xxx ctermfg=214 guifg=#ffbc03
    DevIconJson5                            { fg="#cbcb41", }, -- DevIconJson5   xxx ctermfg=185 guifg=#cbcb41
    DevIconStp                              { fg="#839463", }, -- DevIconStp     xxx ctermfg=101 guifg=#839463
    DevIconPyx                              { fg="#5aa7e4", }, -- DevIconPyx     xxx ctermfg=39 guifg=#5aa7e4
    DevIconPxi                              { fg="#5aa7e4", }, -- DevIconPxi     xxx ctermfg=39 guifg=#5aa7e4
    DevIconOrgMode                          { fg="#77aa99", }, -- DevIconOrgMode xxx ctermfg=73 guifg=#77aa99
    DevIconPxd                              { fg="#5aa7e4", }, -- DevIconPxd     xxx ctermfg=39 guifg=#5aa7e4
    DevIconMli                              { fg="#e37933", }, -- DevIconMli     xxx ctermfg=166 guifg=#e37933
    DevIconGCode                            { fg="#1471ad", }, -- DevIconGCode   xxx ctermfg=32 guifg=#1471ad
    DevIconSub                              { fg="#ffb713", }, -- DevIconSub     xxx ctermfg=214 guifg=#ffb713
    DevIconSass                             { fg="#f55385", }, -- DevIconSass    xxx ctermfg=204 guifg=#f55385
    DevIconApp                              { fg="#9f0500", }, -- DevIconApp     xxx ctermfg=124 guifg=#9f0500
    DevIconGentoo                           { fg="#b1abce", }, -- DevIconGentoo  xxx ctermfg=146 guifg=#b1abce
    DevIconapk                              { fg="#34a853", }, -- DevIconapk     xxx ctermfg=35 guifg=#34a853
    DevIconWebp                             { fg="#a074c4", }, -- DevIconWebp    xxx ctermfg=140 guifg=#a074c4
    DevIconPsScriptfile                     { fg="#4273ca", }, -- DevIconPsScriptfile xxx ctermfg=68 guifg=#4273ca
    DevIconMonkeysAudio                     { fg="#00afff", }, -- DevIconMonkeysAudio xxx ctermfg=39 guifg=#00afff
    DevIconPsManifestfile                   { fg="#6975c4", }, -- DevIconPsManifestfile xxx ctermfg=68 guifg=#6975c4
    DevIconRake                             { fg="#701516", }, -- DevIconRake    xxx ctermfg=52 guifg=#701516
    DevIconGemspec                          { fg="#701516", }, -- DevIconGemspec xxx ctermfg=52 guifg=#701516
    DevIconBz                               { fg="#eca517", }, -- DevIconBz      xxx ctermfg=214 guifg=#eca517
    DevIconFsscript                         { fg="#519aba", }, -- DevIconFsscript xxx ctermfg=74 guifg=#519aba
    DevIconCp                               { fg="#519aba", }, -- DevIconCp      xxx ctermfg=74 guifg=#519aba
    DevIconKDEneon                          { fg="#20a6a4", }, -- DevIconKDEneon xxx ctermfg=37 guifg=#20a6a4
    DevIconTFVars                           { fg="#5f43e9", }, -- DevIconTFVars  xxx ctermfg=93 guifg=#5f43e9
    DevIconMd                               { fg="#dddddd", }, -- DevIconMd      xxx ctermfg=253 guifg=#dddddd
    DevIconSha384                           { fg="#8c86af", }, -- DevIconSha384  xxx ctermfg=103 guifg=#8c86af
    DevIconIcs                              { fg="#2b2e83", }, -- DevIconIcs     xxx ctermfg=18 guifg=#2b2e83
    DevIconNorg                             { fg="#4878be", }, -- DevIconNorg    xxx ctermfg=32 guifg=#4878be
    DevIconNix                              { fg="#7ebae4", }, -- DevIconNix     xxx ctermfg=110 guifg=#7ebae4
    DevIconNim                              { fg="#f3d400", }, -- DevIconNim     xxx ctermfg=220 guifg=#f3d400
    DevIconCjs                              { fg="#cbcb41", }, -- DevIconCjs     xxx ctermfg=185 guifg=#cbcb41
    DevIconObjectFile                       { fg="#9f0500", }, -- DevIconObjectFile xxx ctermfg=124 guifg=#9f0500
    DevIconTypeScript                       { fg="#519aba", }, -- DevIconTypeScript xxx ctermfg=74 guifg=#519aba
    DevIconTypst                            { fg="#0dbcc0", }, -- DevIconTypst   xxx ctermfg=37 guifg=#0dbcc0
    DevIconZst                              { fg="#eca517", }, -- DevIconZst     xxx ctermfg=214 guifg=#eca517
    DevIconTypoScript                       { fg="#ff8700", }, -- DevIconTypoScript xxx ctermfg=208 guifg=#ff8700
    DevIconM3u8                             { fg="#ed95ae", }, -- DevIconM3u8    xxx ctermfg=211 guifg=#ed95ae
    DevIconConfig                           { fg="#6d8086", }, -- DevIconConfig  xxx ctermfg=66 guifg=#6d8086
    DevIconIfb                              { fg="#2b2e83", }, -- DevIconIfb     xxx ctermfg=18 guifg=#2b2e83
    DevIconSlnx                             { fg="#854cc7", }, -- DevIconSlnx    xxx ctermfg=98 guifg=#854cc7
    DevIconTerraform                        { fg="#5f43e9", }, -- DevIconTerraform xxx ctermfg=93 guifg=#5f43e9
    DevIconYml                              { fg="#6d8086", }, -- DevIconYml     xxx ctermfg=66 guifg=#6d8086
    DevIconJpeg                             { fg="#a074c4", }, -- DevIconJpeg    xxx ctermfg=140 guifg=#a074c4
    DevIconMustache                         { fg="#e37933", }, -- DevIconMustache xxx ctermfg=166 guifg=#e37933
    DevIconIfc                              { fg="#839463", }, -- DevIconIfc     xxx ctermfg=101 guifg=#839463
    DevIconScss                             { fg="#f55385", }, -- DevIconScss    xxx ctermfg=204 guifg=#f55385
    DevIconKDEPlasma                        { fg="#1b89f4", }, -- DevIconKDEPlasma xxx ctermfg=33 guifg=#1b89f4
    DevIconHurl                             { fg="#ff0288", }, -- DevIconHurl    xxx ctermfg=198 guifg=#ff0288
    DevIconFIGletFontFormat                 { fg="#ececec", }, -- DevIconFIGletFontFormat xxx ctermfg=255 guifg=#ececec
    DevIconCodespell                        { fg="#35da60", }, -- DevIconCodespell xxx ctermfg=41 guifg=#35da60
    DevIconDsStore                          { fg="#41535b", }, -- DevIconDsStore xxx ctermfg=239 guifg=#41535b
    DevIconScheme                           { fg="#eeeeee", }, -- DevIconScheme  xxx ctermfg=255 guifg=#eeeeee

    sym"@org.keyword.face.TODO"             { DiagnosticVirtualTextError, bold=true },
    sym"@org.keyword.face.NEXT"             { DiagnosticVirtualTextHint, bold=true},
    sym"@org.keyword.face.PROG"             { DiagnosticVirtualTextWarn, bold=true },
    sym"@org.keyword.face.DONE"             { DiagnosticVirtualTextOk, bold=true } ,
    sym"@org.keyword.face.CNCL"             { DiagnosticVirtualTextOk, bold=true} ,
    sym"@org.keyword.face.INTR"             { bg="white", fg="black", bold=true } ,
    sym"@org.hyperlink"                     { fg="nvimlightblue", underline=true}
  }
end)
lush(theme)
