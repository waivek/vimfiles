" Reference {{{

"   #262626   Background    8   DarkGray    (38,38,38)
"   #D6B089   Normal       6    Brown       (214,176,137)
"   #5faf8d   Visual       10   green       (95,175,141)
"   #5fafaf   Seach        3    DarkCyan    (95,175,175)
"   iaf5f5f   IncSearch    4    DarkRed     (175,95,95)
"   #d47777   Function     12   LightRed    (212,119,119)
"   #6c6c6c   Comment      7    LightGray   (108,108,108)

" MADE-UP NAME    HEX        RGB                   XTERM  ANSI
" ========================================================================
" almost black    #1c1c1c    rgb(28, 28, 28)       234    0
" darker grey     #262626    rgb(38, 38, 38)       235    background color
" dark grey       #303030    rgb(48, 48, 48)       236    8
" grey            #444444    rgb(68, 68, 68)       238    8
" medium grey     #585858    rgb(88, 88, 88)       240    8
" light grey      #6c6c6c    rgb(108, 108, 108)    242    7
" lighter grey    #bcbcbc    rgb(188, 188, 188)    250    foreground color
" white           #ffffff    rgb(255, 255, 255)    231    15
" purple          #5f5f87    rgb(95, 95, 135)      60     5
" light purple    #8787af    rgb(135, 135, 175)    103    13
" green           #5f875f    rgb(95, 135, 95)      65     2
" light green     #87af87    rgb(135, 175, 135)    108    10
" aqua            #5f8787    rgb(95, 135, 135)     66     6
" light aqua      #5fafaf    rgb(95, 175, 175)     73     14
" blue            #5f87af    rgb(95, 135, 175)     67     4
" light blue      #8fafd7    rgb(143, 175, 215)    110    12
" red             #af5f5f    rgb(175, 95, 95)      131    1
" orange          #ff8700    rgb(255, 135, 0)      208    9
" ocre            #87875f    rgb(135, 135, 95)     101    3
" yellow          #ffffaf    rgb(255, 255, 175)    229    11
" Default guifg=#F8F8F2
" Default guibg=#1B1D1E
" }}}
" QuickFix syntax : X:\Dropbox\.vim\syntax\qf.vim
" Gvim.exe {{{
if colors_name == "apprentice"
  " hi Visual gui=NONE
  " hi   Visual      guifg=black     guibg=#5faf8d

   hi     Normal       guifg=#D6B089       guibg=#262626
   hi     MatchParen   guifg=black         guibg=#5fafaf
   hi     Tag          guifg=#ff8700       guibg=NONE
   hi     Cursor       guifg=black         guibg=white
   hi     String       guifg=#87af87       guibg=NONE
   hi     IncSearch    guifg=white         guibg=#af5f5f
   hi     Search       guifg=black         guibg=#5fafaf
   hi     Function     guifg=#d47777       guibg=NONE
   hi     StatusLine   gui=reverse         guifg=NONE      guibg=NONE
   hi     StatusLineNC guifg=black         guibg=#6c6c6c

hi Search guibg=#555555 guifg=NONE
hi IncSearch guibg=#682900
endif
" }}}
  hi   Visual         ctermfg=NONE ctermbg=NONE cterm=NONE term=NONE
  hi   StatusLine     ctermfg=NONE ctermbg=NONE cterm=NONE term=NONE
  hi   Search         ctermfg=NONE ctermbg=NONE cterm=NONE term=NONE
  hi   MatchParen     ctermfg=NONE ctermbg=NONE cterm=NONE term=NONE
  hi   Visual         ctermfg=NONE ctermbg=NONE cterm=NONE term=NONE
  hi   Question       ctermfg=NONE ctermbg=NONE cterm=NONE term=NONE
  hi   Pmenu          ctermfg=NONE ctermbg=NONE cterm=NONE term=NONE
  hi   StatusLineNC   ctermfg=NONE ctermbg=NONE cterm=NONE term=NONE
  hi   ErrorMsg       ctermfg=NONE ctermbg=NONE cterm=NONE term=NONE
  hi   IncSearch      ctermfg=NONE ctermbg=NONE cterm=NONE term=NONE
  hi   WildMenu       ctermfg=NONE ctermbg=NONE cterm=NONE term=NONE
  hi   String         ctermfg=NONE ctermbg=NONE cterm=NONE term=NONE
  hi   Function       ctermfg=NONE ctermbg=NONE cterm=NONE term=NONE
  hi   Normal         ctermfg=NONE ctermbg=NONE cterm=NONE term=NONE
  hi   Comment        ctermfg=NONE ctermbg=NONE cterm=NONE term=NONE
  hi   ModeMsg        ctermfg=NONE ctermbg=NONE cterm=NONE term=NONE

  hi   StatusLine   cterm=reverse
  hi StatusLineNC   ctermfg=black ctermbg=Gray
  hi   Comment      ctermfg=LightGray
  hi   String       ctermfg=DarkCyan
  hi   Search ctermfg=black ctermbg=DarkCyan
  hi IncSearch ctermfg=white ctermbg=DarkRed
  hi Visual ctermfg=black ctermbg=Green
  hi Function ctermfg=LightRed
" " Window cmd.exe {{{
" if &term !~ 'gui'
"     hi Visual cterm=NONE term=NONE
"
"     hi   StatusLine     ctermfg=black       ctermbg=DarkCyan
"     hi   Search         ctermfg=black       ctermbg=DarkCyan
"     hi   MatchParen     ctermfg=black       ctermbg=DarkCyan
"     hi   Visual         ctermfg=black       ctermbg=DarkCyan
"     hi   Question       ctermfg=black       ctermbg=DarkCyan
"
"     hi   Pmenu          ctermfg=black       ctermbg=DarkGray
"     hi   StatusLineNC   ctermfg=black       ctermbg=DarkGray
"
"     hi   ErrorMsg       ctermfg=white       ctermbg=DarkRed
"     hi   IncSearch      ctermfg=white       ctermbg=DarkRed
"     hi   WildMenu       ctermfg=white       ctermbg=DarkRed
"
"     hi   String         ctermfg=DarkCyan    ctermbg=None
"     hi   Function       ctermfg=DarkGreen   ctermbg=None
"     hi   Normal         ctermfg=white       ctermbg=None
"     hi   Comment        ctermfg=DarkGray    ctermbg=None
"     hi   ModeMsg        ctermfg=black       ctermbg=DarkYellow
" endif
"
" " }}}
"
" Linking {{{


" Unifying Groups
hi! link Character Constant
hi! link Number Constant
hi! link Boolean Constant
hi! link Float Constant

hi! link Conditional Statement
hi! link Repeat Statement
hi! link Label Statement
hi! link Operator Statement
hi! link Keyword Statement
hi! link Exception Statement

hi! link Include PreProc
hi! link Define PreProc
hi! link Macro PreProc
hi! link PreCondit PreProc

hi! link StorageClass Type
hi! link Structure Type
hi! link Typedef Type

hi! link SpecialChar Special
hi! link Tag Special
hi! link Delimiter Special
hi! link SpecialComment Special
hi! link Debug Special
" 

hi! link Constant Normal
hi! link Statement Normal
" hi! link PreProc ???
hi! link Type Normal
hi! link Special String
" hi! link Title Normal
" hi! link Identifier Normal
hi! link Folded Normal
hi! link VertSplit StatusLineNC

" }}}
