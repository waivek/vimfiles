" Indent related options during formatting via gq:
" Auto-indenting of hypens (-)     = 'comments'
" Auto-indenting of the word 'for' = 'cinwords'

set history=10000
set viminfo='10000,<50,s10,h,rA:,rB:,%,f1,n~/vimfiles/_viminfo
filetype indent plugin on | syntax on 

source ~\vimfiles\plugin\colorscheme.vim
colorscheme apprentice
colorscheme apprentice_extended

" Remaps {{{

" NONE   Normal, Visual, Select, Operator-pending
" n      Normal
" v      Visual and Select (YOU ALMOST NEVER WANT THIS)
" s      Select
" x      Visual            (YOU ALMOST ALWAYS WANT THIS)
" o      Operator-pending

" Horizontal Movement  
" (b w) → (^ $)
 noremap b ^
 noremap w $
xnoremap w g_

" (j ;) → (b w)
 noremap j b
onoremap J B
 noremap ; w
onoremap : W

" (C-j C-;) → (h l)
xnoremap <C-j> h
xnoremap <C-;> l

" Vertical Movement
onoremap l k
 noremap <silent> l gk
onoremap k j
 noremap <silent> k gj

nnoremap , ;
xnoremap , ;

inoremap jk 
inoremap Jk 
inoremap jK 
inoremap JK 
cnoremap jk <C-f>
tnoremap jk <C-W>N

cnoremap <C-l> <Up>
cnoremap <C-k> <Down>
cnoremap <C-j> <C-Left>
cnoremap <C-;> <C-Right>
cnoremap <C-U> <C-E><C-U>
nnoremap <C-w>j <C-w>h
nnoremap <C-w>k <C-w>j
nnoremap <C-w>l <C-w>k
nnoremap <C-w>; <C-w>l
nnoremap <C-w>J <C-w>H
nnoremap <C-w>K <C-w>J
nnoremap <C-w>L <C-w>K
nnoremap <C-w>: <C-w>L

nnoremap zk zj
nnoremap zl zk

nnoremap h "+
nnoremap Q @:
xnoremap h "+
" xmap Q :norm <C-r>a<CR>
xmap Q :norm @a<CR>
xmap . :norm .<CR>

nnoremap <silent> ch :cd %:p:h<CR>
nnoremap <silent> c. :cd ..<CR>
inoremap <C-v> <C-r>+
" :h v_CTRL-X    :h dos-standard-mappings
silent! vunmap <C-x>


" }}}
" Option Settings {{{
set complete=.,w
" Indentation
set smartindent " Automatically indents when and where required
set tabstop=4 " Sets tab width to 4 
set shiftwidth=4 " Allows you to use < and > keys in -- VISUAL --
set softtabstop=4 " Makes vim see four spaces as a <TAB>
set expandtab " Inserts 4 spaces when <TAB> is pressed

set undofile
set undodir=C:/Users/vivek/vimfiles/undofiles,.
set nowritebackup " Only creates Dropbox Errors
set noswapfile " Only creates Dropbox Errors

set nrformats-=octal " To make CTRL-A work on 07

set backspace=indent,eol,start " Fixes backspace inside insert mode
set laststatus=2

set splitright
set nowrap
set sidescroll=1

set scrolloff=2

set foldmethod=marker

" set grepprg=fart\ --line-number
" let &grepformat="[ %\\+%l]%m"

set grepprg=rg\ --vimgrep\ --smart-case
let &grepformat = "%f:%l:%c:%m"

" set shellxescape-=\>
" set shellxescape-=\&
" set shellxquote=(

" Searching 
set ignorecase smartcase  
set hlsearch incsearch
set nowrapscan
" ALlows you to do <TAB> while typing letters in '/'
cnoremap <expr>  <tab>    getcmdtype() =~ '[/?]' ? (getcmdtype() == '/' ? '<c-g>' : '<c-t>') : feedkeys('<tab>', 'int')[1]
cnoremap <expr>  <s-tab>  getcmdtype() =~ '[/?]' ? (getcmdtype() == '/' ? '<c-t>' : '<c-g>') : feedkeys('<s-tab>', 'int')[1]

" Completion
set wildcharm=<C-z>
set wildmenu
set wildmode=full

au GUIEnter * simalt ~x
set guioptions=mre
set showtabline=2
set guitablabel=%t

silent! unmenu 📁
menu 📁.▶\ \ Open\ in\ Default\ Viewer :call system(shellescape(expand("%:p")))<CR>
menu 📁.📁\ \ Show\ File\ in\ Directory :call system('explorer "' . expand("%:p:h") . '"')<CR>
menu 📁.📂\ \ Open\ Plugins\ Directory :call system('explorer %userprofile%\vimfiles\pack\plugins\opt')<CR>
menu 📁.🔍\ \ Open\ Search\ Everything :call system('everything -path .')<CR>
set belloff=all

augroup OneLineFtplugins
    let Cursor2Highlight = { -> synIDattr(synID(line("."),col("."),1),"name") }
    au! 
    au BufRead *.afl set filetype=afl 
    au FileType afl setlocal cms=#%s
    au FileType help nnoremap <buffer> <expr> K index([ "helpHyperTextJump", "helpSpecial", "helpOption", "helpBar" ], Cursor2Highlight()) > -1 ? 'K' : ':helpc<CR>'
augroup END

function! s:Eatchar(pat)
   let c = nr2char(getchar(0))
   return (c =~ a:pat) ? '' : c
endfunc
iabbrev –- —<C-R>=<SID>Eatchar('\s')<CR>

iabbrev qq “”
iabbrev -- –
iabbrev 's ’s
iabbrev 't ’t
" }}}
" GROUP TOGETHER FOR EASIER DEBUGGING {{{
let &pythonthreedll='C:\Program Files (x86)\Python\Python38-32\python38.dll'
if has('python3')
    silent! python3 1
endif
au VimEnter * call UltiSnips#TrackChange()
if &guifont !=# 'Consolas:h12:cANSI:qDRAFT'
    " Setting guifont causes vim to go from maximized mode to windowed mode
    set guifont=Consolas:h12:cANSI:qDRAFT
endif
setlocal encoding=utf8
" }}}
" Plugin Settings {{{
let $PLUGINDIR = glob('~\vimfiles\pack\plugins')
packadd matchit
packadd cfilter

let g:CoolTotalMatches=1
let g:UltiSnipsJumpForwardTrigger='<tab>'

" Argumentative is modified. At the end of s:MoveLeft() and s:MoveRight, these two lines were inserted:
"     call s:ArgMotion(0)
"     call search('\S')
" This positions the cursor at the beginning of the argument. Default behaviour positions the cursor at the end of the argument.
nmap <Left> <Plug>Argumentative_MoveLeft
nmap <Right> <Plug>Argumentative_MoveRight

let g:jedi#completions_enabled    = 0
let g:jedi#show_call_signatures   = 0
let g:jedi#auto_vim_configuration = 0 " to prevent jedi from overriding 'completeopt'

let g:ale_linters = { 
            \ 'python' : [ 'pyflakes' ],
            \ 'javascript' : ['xo']
            \ }
let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_enter = 0

let g:cursorword_highlight = 0
hi link CursorWord0 Search
hi link CursorWord1 Search

" let g:pasta_disabled_filetypes = ['python', 'coffee', 'markdown', 'yaml', 'slim', 'nerdtree', 'netrw', 'startify', 'ctrlp']
let g:pasta_disabled_filetypes = []


let g:markdown_fenced_languages = ['xml', 'python', 'html', 'javascript']

" closes all terminals when you exit vim
let g:terminal_kill = "term"
" when you launch a terminal, it cd’s to the currentworkingdirecotry
let g:terminal_cwd = 0

nmap <silent> <C-k>      <Plug>scroll_page_down
nmap <silent> <PageDown> <Plug>scroll_page_down
nmap <silent> <C-f>      <Plug>scroll_page_down

nmap <silent> <C-l>      <Plug>scroll_page_up
nmap <silent> <PageUp>   <Plug>scroll_page_up
nmap <silent> <C-b>      <Plug>scroll_page_up

let g:scroll_smoothness = 1

" }}}
" Functions and Mappings {{{
function! SetFileSpecificSettings()
    let file_name = expand("%:p:t")
    if file_name ==# "websites.html"
        function! TransferIncompleteItem()
            normal dd{{pcst<dl>f>,vityo<dd>"</dd>
            normal lfd%lf>,vit
        endfunction
        command! -buffer TransferIncompleteItem call TransferIncompleteItem()
    elseif file_name ==# "twitch_clips.md"
        function! FormatTwitchClips()
            silent! g/^\s*$/d
            silent! %s/https:\/\/www\.twitch\.tv\/\(\w\+\)\/clip\/\(\w\+\)?\?.*$/https:\/\/clips.twitch.tv\/\2 - \1 -
            Tabularize /-
        endfunction
        augroup AlignDashes
            au!
            au BufWritePre <buffer> call FormatTwitchClips()
        augroup END
    endif
endfunction
au! BufRead * call SetFileSpecificSettings()

function! s:PathSpecficSettings()
    let working_directory = getcwd()
    if working_directory ==# glob('~/Desktop/website')
        let &path='.,,fonts/**'
    elseif working_directory ==# glob('~/vimfiles')
        let &path='.,,plugin/,colors/'
    else
        set path&
    endif
endfunction
au! DirChanged * call s:PathSpecficSettings()

function! s:FunctionSyntaxGroups()
    syntax match Function /[a-zA-Z0-9_]\+\s*\ze(/
    syntax match FunctionWithPeriods /[a-zA-Z.0-9_]\+\s*\ze(/ contains=Function
    syntax match CustomMode /\s\+vim:.*/
endfunction
function! s:AddHighlightGroups()
    if !exists("g:colors_name")
        return
    endif
    if g:colors_name == "codedark"
        hi FunctionWithPeriods guifg=#a7a765
    elseif g:colors_name == "apprentice"
        hi FunctionWithPeriods guifg=#d8afaf
    endif
    hi link CustomMode Comment
endfunction
augroup AddFunctionHighlightGroups
    au!
    au Syntax * call s:FunctionSyntaxGroups()
    au Syntax * call s:AddHighlightGroups()
augroup END

function! s:normal_to_curly_quotes()
    call search("[\"']", "c", line("."))
    let visual_start_position = getpos("'<")
    let visual_end_position = getpos("'>")

    let reg_save = @"
    normal! vy
    let quote_type = @"
    let @" = reg_save

    if quote_type == '"'
        normal! vi"
        normal! `<hr“
        normal! f"r”
        normal! `<
    elseif quote_type == "'"
        normal! vi'
        normal! `<hr‘
        normal! f'r’
        normal! `<
    endif
    call setpos("'<", visual_start_position)
    call setpos("'>", visual_end_position)

endfunction
nnoremap cq :call <SID>normal_to_curly_quotes()<CR>

let g:options_D = { }
function! s:ToggleScreencastMode()
    if empty(g:options_D)
        let g:options_D["guioptions"] = &guioptions
        let g:options_D["tabline"] = &showtabline
        let g:options_D["guifont"] = &guifont
        let g:options_D["scrolloff"] = &scrolloff
        let g:options_D["number"] = &number

        let &guioptions=''
        let &showtabline=0
        let &guifont='Consolas:h30:cANSI:qDRAFT'
        let &scrolloff=0
        let &number=1
    else
        let &guioptions = remove(g:options_D, "guioptions")
        let &showtabline = remove(g:options_D, "tabline")
        let &guifont = remove(g:options_D, "guifont")
        let &scrolloff = remove(g:options_D, "scrolloff")
        let &number = remove(g:options_D, "number")
    endif
endfunction
nnoremap <silent> ga :call <SID>ToggleScreencastMode()<CR>

function! s:AddPositionToJumpList()
    let save_a_mark = getpos("'a")
    normal! ma
    normal! `a
    call setpos("'a", save_a_mark)
endfunction
breakdel *
" breakadd func 1 PreviousIndent
function! PreviousIndent(mode)
    call s:AddPositionToJumpList()
    let previous_indent = indent(".") - 1
    if previous_indent == -1
        let previous_indent = 0
    endif
    let regexp = printf('^\s\{0,%d\}\S', previous_indent)
    if a:mode == "v"
        normal! gv
        call search(regexp, 'be')
    elseif a:mode == "n"
        call search(regexp, 'be')
    endif

endfunction
nnoremap <silent> <BS> :call PreviousIndent("n")<CR>
xnoremap <silent> <BS> :<c-u>call PreviousIndent("v")<CR>

" ENCODING ISSUES:

function! s:FixEncoding()
    %substitute/â/“/g
    %substitute/â/”/g
    %substitute/â/‘/g
    %substitute/â/-/g
    %substitute/â¦/…/g
endfunction

function! TabularizeCharacterUnderCursor()
    let visual_start_save = getpos("'<")
    let visual_end_save = getpos("'>")
    let yank_start_save = getpos("'[")
    let yank_end_save = getpos("']")
    let quote_reg_save = @"

    normal! vy
    let character_under_cursor = @"

    call setpos("'<", visual_start_save)
    call setpos("'>", visual_end_save)
    call setpos("'[", yank_start_save)
    call setpos("']", yank_end_save)
    let @" = quote_reg_save

    execute "Tabularize /" . character_under_cursor

endfunction
nnoremap <silent> gt :call TabularizeCharacterUnderCursor()<CR>

" }}}

" trigger other text that exists here
" breakadd func 1 GetTabBehaviour
function! GetTabBehaviour()
    let cursor_on_first_column = col('.') <= 1
    if cursor_on_first_column
        " Insert 4 Spaces
        return "\<C-R>=UltiSnips#ExpandSnippetOrJump()\<CR>"
    endif

    let cursor_after_space = !empty(matchstr(getline('.'), '\%' . (col('.') - 1) . 'c\s'))
    if cursor_after_space
        " Insert 4 Spaces
        return "\<C-R>=UltiSnips#ExpandSnippetOrJump()\<CR>"
    endif

    " cursor_after_space     = v:false
    " cursor_on_first_column = v:false
    let no_snippets_in_scope = empty(UltiSnips#SnippetsInCurrentScope())
    let snippets_in_scope = !empty(UltiSnips#SnippetsInCurrentScope())
    " :help UltiSnips-snippet-options
    " if snippets_in_scope
    "     let line_substring = getline(".")[:col(".") - 2]
    " endif

    let ulti_snips_is_expandable = !(cursor_on_first_column || cursor_after_space || no_snippets_in_scope)
    if ulti_snips_is_expandable
        return "\<C-R>=UltiSnips#ExpandSnippetOrJump()\<CR>"
    else
        return "\<C-n>"
    endif
endfunction
" inoremap <silent> <expr> <Tab> GetTabBehaviour()

" HTML Numbering Macro
" let @a = '0f<f>:let i = i+1i id="h2_=i"'

nnoremap V Vg_

function! RedrawAtTopIfBufferSizeLessThanWindowSize()
    let window_height = winheight(0)
    let buffer_height = line("$")
    let condition = buffer_height < window_height
    return condition ? "gd" : "gdzt"
endfunction
nnoremap <expr> gd RedrawAtTopIfBufferSizeLessThanWindowSize()
" We disable syntax highlighting for long lines
" set synmaxcol=200

function NormalizeTwitchUrl()
    s/https:\/\/www\.twitch\.tv\/\w\+\/clip\/\([a-zA-Z]\+\)?[a-zA-Z_0-9=&]\+/https:\/\/clips.twitch.tv\/\1
endfunction
command! NormalizeTwitchUrl call NormalizeTwitchUrl()

function! EnableSpellApplyFirstSuggestionDisableSpell()
    set spell
    normal! 1z=
    set nospell

endfunction

nnoremap <silent> z= :call EnableSpellApplyFirstSuggestionDisableSpell()<CR>

" HOW TO TEST- 1. Comment out a line. 2. Go to a line somewhere else and press O. 3. Call function
"
" Idea:  Add a variable line_count. Then if next change falls with line_count
"        lines of current line, we can ignore that change. Default behavour of
"        g; is as if line_count = 0, because event if the change happened on
"        the same line and column, the cursor doesn’t merge the changes. With
"        line_count, we would be able to target the use case more, which is
"        jumping to the previous change on some other "screen" as opposed to
"        the previous change which took place on this screen.






function! BetterOlderChangeJump()
    let print_debug_messages = v:false
    let change_list = getchangelist()
    let [change_dictionaries, current_change_number] = change_list
    " echo "(change_dictionaries, current_change_number): " . join([string(change_dictionaries)[:5] . "..." . string(change_dictionaries)[-5:], current_change_number], ', ')
    " change_dictionaries[current_change_number-1]
    " echo "change_dictionaries[current_change_number-1]: " . string(change_dictionaries[current_change_number-1])
    let next_change_D = change_dictionaries[current_change_number-1]
    " col(".") starts from 1, next_change_D["col"] starts from 0
    if next_change_D["lnum"] == line(".") && next_change_D["col"] == col(".")-1
        if print_debug_messages
            echo "next_change_D: " . string(next_change_D)
            echo "line("."): " . string(line("."))
            echo "Merging changes..."
        endif
        normal! 2g;
    else
        if print_debug_messages
            echo "next_change_D: " . string(next_change_D)
            echo "line("."): " . string(line("."))
            echo "Normal behaviour"
        endif
        normal! g;
    endif
endfunction
nnoremap <silent> g; :call BetterOlderChangeJump()<CR>

function! FileGrep(key)
    silent! %s/^[^"]/"\0/g
    silent! %s/[^"]$/\0"/g
    silent! write
    let files_joined_by_space = join(readfile(expand('%')), " ")
    let grep_command = printf("grep %s %s", a:key, files_joined_by_space)
    silent! execute grep_command
    let match_count = len(getqflist())
    echo printf("%d Matches", match_count)
endfunction
command! -nargs=1 FileGrep call FileGrep("<args>")

function! YoutubeUrlToThumbnailUrl()
    s/https:\/\/www\.youtube\.com\/watch?v=\(\w\{-}\)\W/https:\/\/i.ytimg.com\/vi\/\1\/maxresdefault.jpg
endfunction
command! YoutubeUrlToThumbnailUrl call YoutubeUrlToThumbnailUrl()
