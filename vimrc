" Indent related options during formatting via gq:
" Auto-indenting of hypens (-)     = 'comments'
" Auto-indenting of the word 'for' = 'cinwords'



set history=10000
set viminfo='10000,<50,s10,h,rA:,rB:,%,f1,n~/vimfiles/_viminfo
" Unix {{{
if has("unix")
    set viminfo='10000,<50,s10,h,rA:,rB:,%,f1,n~/.vim/_viminfo
endif
" }}}
filetype indent plugin on | syntax on 

let $PLUGINDIR = glob('~/vimfiles/pack/plugins')
let $WSL = 'C:\Users\vivek\AppData\Local\Packages\CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc\LocalState\rootfs\'


if has("win32")
    source ~/vimfiles/plugin/colorscheme.vim
    colorscheme apprentice
    " colorscheme dracula

endif


" Unix {{{
if has("unix")
    source ~/.vim/plugin/colorscheme.vim
    colorscheme apprentice
endif
" }}}
set undofile
if has("win32")
    set undodir=C:/Users/vivek/vimfiles/undofiles,.
endif
" Unix {{{
if has("unix")
    set undodir=C:/Users/vivek/.vim/undofiles,.
endif
" }}}
set sidescroll=0

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
noremap <silent> l gk
noremap <silent> k gj
onoremap l k
onoremap k j

nnoremap , ;
xnoremap , ;

inoremap jk 
inoremap Jk 
inoremap jK 
inoremap JK 
inoremap J: 
inoremap j: 

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

nnoremap <C-k> <C-f>
nnoremap <C-l> <C-b>

" }}}
" Option Settings {{{
set complete=.,w
" Indentation
set smartindent   " Automatically indents when and where required
set tabstop=4     " Sets tab width to 4
set shiftwidth=4  " Allows you to use < and > keys in -- VISUAL --
set softtabstop=4 " Makes vim see four spaces as a <TAB>
set expandtab     " Inserts 4 spaces when <TAB> is pressed

set nowritebackup " Only creates Dropbox Errors
set noswapfile " Only creates Dropbox Errors

set nrformats-=octal " To make CTRL-A work on 07

set backspace=indent,eol,start " Fixes backspace inside insert mode
set laststatus=2

set splitright
set nowrap

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

augroup VimrcGuiFullscreen
    au GUIEnter * simalt ~x
augroup END
set guioptions=mre
set showtabline=0
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
    au FileType help nnoremap <buffer> <expr> K index([ "helpHyperTextJump", "helpSpecial", "helpOption", "helpBar", "Function" ], Cursor2Highlight()) > -1 ? 'K' : ':helpc<CR>'
    au BufRead *.md set formatprg=
augroup END

" function! s:Eatchar(pat)
"    let c = nr2char(getchar(0))
"    return (c =~ a:pat) ? '' : c
" endfunc
" iabbrev –- —<C-R>=<SID>Eatchar('\s')<CR>
" iabbrev -- –

iabbrev qq “”
iabbrev 's ’s
iabbrev 't ’t
" }}}
" GROUP TOGETHER FOR EASIER DEBUGGING {{{
let &pythonthreedll='C:\Program Files (x86)\Python\Python37-32\python37.dll'
let &pythonthreedll='C:\Program Files\Python310\python310.dll'

if has('python3')
    silent! python3 1
endif
" au VimEnter * call UltiSnips#TrackChange()
if &guifont !=# 'Consolas:h12:cANSI:qDRAFT'
    " Setting guifont causes vim to go from maximized mode to windowed mode
    set guifont=Consolas:h12:cANSI:qDRAFT
endif
setlocal encoding=utf8
" }}}
" Plugin Settings {{{
packadd matchit
packadd cfilter

let g:CoolTotalMatches=1




" Argumentative is modified. At the end of s:MoveLeft() and s:MoveRight, these two lines were inserted:
"     call s:ArgMotion(0)
"     call search('\S')
" This positions the cursor at the beginning of the argument. Default behaviour positions the cursor at the end of the argument.
nmap <Left> <Plug>Argumentative_MoveLeft
nmap <Right> <Plug>Argumentative_MoveRight

let g:jedi#added_sys_path = [ '/Users/vivek/Documents/Python' ]
let g:jedi#completions_enabled    = 0
let g:jedi#show_call_signatures   = 1
let g:jedi#auto_vim_configuration = 0 " to prevent jedi from overriding 'completeopt'

function! PyflakesRefinedCallback(buffer, lines) abort
    let l:pattern = '\v^[a-zA-Z]?:?[^:]+:(\d+):(\d+)?:? (.+)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let g:ale_debug = l:match[3]

        " CUSTOMIZATION - Start
        if stridx(l:match[3], "assigned to but never used") > -1
            continue
        endif
        " CUSTOMIZATION - End

        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[3],
        \})
    endfor

    return l:output
endfunction

" Will throw a bug in operating systems where ale plugin is not installed
function! DefineCustomAleLinters()
    if exists("g:loaded_ale")
        call ale#linter#Define('python', {
        \   'name': 'pyflakes_refined',
        \   'executable': function('ale_linters#python#pyflakes#GetExecutable'),
        \   'command': function('ale_linters#python#pyflakes#GetCommand'),
        \   'callback': 'PyflakesRefinedCallback',
        \   'output_stream': 'both',
        \})
    endif
endfunction
augroup VimrcAle
    au!
    au VimEnter * call DefineCustomAleLinters()
augroup END

function! DisableUltiSnipsTracker()
    au! UltiSnips_AutoTrigger
endfunction
augroup VimrcDisableUltiSnipsTracker
    au!
    au VimEnter * call DisableUltiSnipsTracker()
augroup END



let g:ale_linters = { 
            \ 'python' : [ 'pyflakes_refined' ],
            \ 'javascript' : ['xo'],
            \ 'php' : ["php"]
            \ }
" let g:ale_fixers = {
"             \ 'python' : [ 'autoimport' ]
"             \}
" let g:ale_fix_on_save = 1
let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_enter = 0
let g:ale_html_tidy_options = '-q -e -language en --escape-scripts 0'

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

nmap <silent> <C-k>      <C-f>
nmap <silent> <PageDown> <Plug>scroll_page_down
" nmap <silent> <C-f>      <Plug>scroll_page_down

nmap <silent> <C-l>      <C-b>
nmap <silent> <PageUp>   <Plug>scroll_page_up
" nmap <silent> <C-b>      <Plug>scroll_page_up

let g:scroll_smoothness = 1

" }}}
" Functions and Mappings {{{
function! SetFileSpecificSettings()
    let file_name = expand("%:p:t")
    if file_name ==# "twitch_clips.md"
        function! FormatTwitchClips()
            silent! g/^\s*$/d
            silent! %s/https:\/\/www\.twitch\.tv\/\(\w\+\)\/clip\/\(\w\+\)?\?.*$/https:\/\/clips.twitch.tv\/\2 - \1 -
            Tabularize /-
        endfunction
        augroup AlignDashes
            au!
            au BufWritePre <buffer> call FormatTwitchClips()
        augroup END
    elseif file_name ==# "bookmarked_articles.html"
        " TODO: Incomplete
        " let b:ale_html_tidy_options="-q -e -language en"
    elseif file_name ==# "books_and_courses.html"
        let b:ale_html_tidy_options="-q -e -language en --drop-empty-elements 0"
    elseif file_name ==# "css_high_quality_guides.html"
        let b:ale_html_tidy_options="-q -e -language en --drop-empty-elements 0"
    elseif file_name ==# "freedom_vs_correctness.html"
        let b:ale_html_tidy_options="-q -e -language en --drop-empty-elements 0"
    elseif file_name ==# "dotty.vim"
        function! s:GoToRepeatChangeFunction()
            normal! gg
            call search("function! RepeatChange()")
            normal! zt
        endfunction
        nnoremap <silent> <buffer> 'f :call <SID>GoToRepeatChangeFunction()<CR>
        nnoremap <silent> <buffer> `f :call <SID>GoToRepeatChangeFunction()<CR>
    endif
endfunction
augroup VimrcFileSpecificSettings
    au!
    au BufRead * call SetFileSpecificSettings()
augroup END

function! s:PathSpecficSettings()
    let working_directory = getcwd()
    if working_directory ==# glob('~/Desktop/website')
        let &path='.,,fonts/**,css/**'
    elseif working_directory ==# glob('~/vimfiles')
        let &path='.,,plugin/,colors/'
    else
        set path&
    endif
endfunction
augroup VimrcPathSpecificSettings
    au!
    au DirChanged * call s:PathSpecficSettings()
augroup END

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

function! s:PathSyntax()
    syntax clear PathVariable
    syntax clear PathBasename
    syntax clear PathLinuxDirectory

    syntax match PathVariable /\$[a-z_A-Z0-9]\+/
    syntax match PathVariable /\~/

    syntax match PathBasename /[^\/\\]\+\(["']\|$\)/
    syntax match PathLinuxDirectory /\/.*\// contains=ALL

    hi link PathVariable Identifier
    hi link PathBasename Function
    hi link PathLinuxDirectory String
endfunction
augroup AddPathHighlightGroups
    au!
    " au Syntax * call s:PathSyntax()
augroup END

function! s:normal_to_curly_quotes()
    let view_save = winsaveview()
    let col_save = col(".")

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

    let cursor_inside_quotes = col_save >= col("'<")
    if cursor_inside_quotes
        let horizontal_offset = len('“') - len('"') " 3-1 = 2
        let view_save["col"] = view_save["col"] + horizontal_offset
    endif

    call setpos("'<", visual_start_position)
    call setpos("'>", visual_end_position)

    call winrestview(view_save)
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
command! ToggleScreencastMode call <SID>ToggleScreencastMode()

function! s:AddPositionToJumpList()
    let save_a_mark = getpos("'a")
    normal! ma
    normal! `a
    call setpos("'a", save_a_mark)
endfunction

function! PreviousIndent(mode)
    call s:AddPositionToJumpList()
    let start_indent = indent(".")
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

    " Handle if <Tab>'s are used for indentation. These are not found my the
    " regexp. We then manually go up each line
    if indent(".") == start_indent && indent(".") > 0
        let reversed_line_numbers = reverse(range(line("."))[1:])
        let target_line_number = 1
        for line_number in reversed_line_numbers
            if indent(line_number) < start_indent
                let target_line_number = line_number
                break
            endif
        endfor
        execute printf(":%d", target_line_number)
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

function! GetAlignment(_, string)
    let string = a:string
    let is_number = string =~# '^[0-9.]\+$' 
    if is_number
        return "r"
    else
        return "l"
    endif
endfunction
function! TabularizeCharacterUnderCursor()
    let visual_start_save = getpos("'<")
    let visual_end_save = getpos("'>")
    let yank_start_save = getpos("'[")
    let yank_end_save = getpos("']")
    let quote_reg_save = @"

    normal! vy
    let character_under_cursor = @"
    normal! yy
    let line = @"

    call setpos("'<", visual_start_save)
    call setpos("'>", visual_end_save)
    call setpos("'[", yank_start_save)
    call setpos("']", yank_end_save)
    let @" = quote_reg_save

    let untrimmed_columns = split(line, character_under_cursor)
    let columns = map(untrimmed_columns, {key, val -> trim(val)})
    let alignments = map(columns, function("GetAlignment"))
    let tabular_alignment_command = join(alignments, "1c1")
    let tabular_command = printf("Tabularize /%s/%s1", character_under_cursor, tabular_alignment_command)
    execute tabular_command
    let @a = tabular_command
    echo tabular_command

endfunction
nnoremap <silent> gt :call TabularizeCharacterUnderCursor()<CR>

" }}}

function! RedrawAtTopIfBufferSizeLessThanWindowSize()
    let window_height = winheight(0)
    let buffer_height = line("$")
    let condition = buffer_height < window_height
    return condition ? "gd" : "gdzt"
endfunction
nnoremap <expr> gd RedrawAtTopIfBufferSizeLessThanWindowSize()

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

function! FileGrep(key)
    silent! %s/^[^"]/"\0/g
    silent! %s/[^"]$/\0"/g
    silent! write
    let files_joined_by_space = join(readfile(expand('%')), " ")
    let grep_command = printf('grep "%s" %s', a:key, files_joined_by_space)
    " echoerr grep_command
    " return
    silent! execute grep_command
    let match_count = len(getqflist())
    echo printf("%d Matches", match_count)
endfunction
command! -nargs=1 FileGrep call FileGrep(<q-args>)

function! YoutubeUrlToThumbnailUrl()
    s/https:\/\/www\.youtube\.com\/watch?v=\(\w\{-}\)\W/https:\/\/i.ytimg.com\/vi\/\1\/maxresdefault.jpg
endfunction
command! YoutubeUrlToThumbnailUrl call YoutubeUrlToThumbnailUrl()

function! ConsoleCompletion(ArgLead, CmdLine, CursorPos)
    let pattern = a:ArgLead
    return filter(["plugin", "website", "twitch", "vimfiles" ], {pos, x -> x =~# pattern})
endfunction
function! Console(flag)
    let flag = a:flag
    if flag == ""
        silent !start cmd
    elseif flag == "plugin"
        silent !start cmd /k "cd C:\Users\vivek\vimfiles\pack\plugins\start\"
    elseif flag == "website"
        silent !start cmd /k "cd C:\Users\vivek\Desktop\website\"
    elseif flag == "twitch"
        silent !start cmd /k "cd C:\Users\vivek\Desktop\Twitch\"
    elseif flag == "vimfiles"
        silent !start cmd /k "cd C:\Users\vivek\vimfiles\"
    endif
endfunction
command! -complete=customlist,ConsoleCompletion -nargs=? CMD call Console(<q-args>)

function! ChangeDirectoryCompletion(ArgLead, CmdLine, CursorPos)
    let pattern = a:ArgLead
    return filter(["plugin", "website", "twitch", "vimfiles", "youtube", "live" ], {pos, x -> x =~# pattern})
endfunction
function! ChangeDirectory(flag)
    let flag = a:flag
    if flag == ""
        return
    elseif flag == "plugin"
        cd C:\Users\vivek\vimfiles\pack\plugins\start\
        echo 'C:\Users\vivek\vimfiles\pack\plugins\start\'
    elseif flag == "website"
        cd C:\Users\vivek\Desktop\website\
        echo 'C:\Users\vivek\Desktop\website\'
    elseif flag == "twitch"
        cd C:\Users\vivek\Desktop\Twitch\
        echo 'C:\Users\vivek\Desktop\Twitch\'
    elseif flag == "vimfiles"
        cd C:\Users\vivek\vimfiles\
        echo 'C:\Users\vivek\vimfiles\'
    elseif flag == "youtube"
        cd C:\Users\vivek\Desktop\youtube_dl\
        echo 'C:\Users\vivek\Desktop\youtube_dl\'
    elseif flag == "live"
        cd C:\Users\vivek\Desktop\live\www\html
        echo 'C:\Users\vivek\Desktop\live\www\html'
    endif
endfunction
command! -complete=customlist,ChangeDirectoryCompletion -nargs=? CD call ChangeDirectory(<q-args>)

function! AddFile(u, n)
    if stridx(a:u, "http") > -1
        echoerr "First argument is a URL"
        let url = a:u
        let name = a:n
    else
        echoerr "Second argument is a url"
        let name = a:u
        let url = a:n
    endif
    let website_relative_path = expand("%:h")
    let fileroot = expand("%:t:r")
    let extension = fnamemodify(url, ":e")
    let download_directory = printf('%s\images\%s', website_relative_path, fileroot)
    let download_command = printf('aria2c %s --dir %s -o %s.%s --allow-overwrite=true --auto-file-renaming=false', url, download_directory, name, extension)
    " echo "download_command: " . string(download_command)
    " let @+ = download_command
    execute "!" . download_command
endfunction
command! -nargs=* AddFile call AddFile(<f-args>)

" Preconditions:
"     HTML file should contain a <nav> tag
"     <nav> tag should contain an li a.href={filename}
function! UpdateNavigation()
    let fold_save = &foldenable
    let &foldenable = 0
    %!python update_lists.py
    0
    call search("<nav>")
    call search(expand("%"))
    normal ysat<strong>
    let &foldenable = fold_save
    normal! zo
    normal! 0
    call search("<nav>", "b")
    normal! zz
    :w
endfunction
command! UpdateNavigation call UpdateNavigation()

let &fillchars='vert:|,fold: '

hi! link Folded Function
function! FoldTextMinimal()
    let indent = indent(v:foldstart)
    let leading_spaces = repeat(" ", indent)
    " let leading_spaces = "+" . leading_spaces[1:]
    let first_line = getline(v:foldstart)
    let foldmessage = trim(substitute(foldtext(), ".*lines: ", "", "g"))

    return leading_spaces . "[+] " . foldmessage . " ..."
endfunction
set foldtext=FoldTextMinimal()


" ---------- LATEST SNIPPETS ----------

nnoremap V Vg$

" set synmaxcol=200 " We disable syntax highlighting for long lines


nnoremap <Space>l <C-^>

" h express-mappings
" h g:
" h g=

function! Chars(string)
    return split(a:string, '\zs')
endfunction
function! WriteAbbrev()
    let variations = [ "wirte", "rwite", "wite" ]
    let abbrev_command_fmt = 'cabbrev <expr> %s len(getcmdline()) == %d ? "write" : "%s"'
    for variation in variations
        for i in range(len(variation))
            let subcommand = variation[:i]
            let abbrev_command = printf(abbrev_command_fmt, subcommand, len(subcommand), subcommand)
            execute abbrev_command
        endfor
    endfor
endfunction
call WriteAbbrev()
cabbrev <expr> o len(getcmdline()) == 1 ? "!start %" : "o"

function! s:GetRecentBufNrs()
    let first_window_nr = 1
    let last_window_nr = winnr("$")
    let max_bufs = 5
    let recent_bufs = []
    for win_nr in range(first_window_nr, last_window_nr)
        let old_jumps_to_new_jumps = getjumplist(win_nr)[0]
        let new_jumps_to_old_jumps = reverse(old_jumps_to_new_jumps)
        let new_bufs_to_old_bufs = map(new_jumps_to_old_jumps, {_, D -> D["bufnr"]})
        for i in range(len(new_bufs_to_old_bufs))

            let limit_reached = len(recent_bufs) > max_bufs
            if limit_reached
                break
            endif

            let buf = new_bufs_to_old_bufs[i]

            let buf_in_recent_bufs = index(recent_bufs, buf) > -1
            if buf_in_recent_bufs
                continue
            endif

            call add(recent_bufs, buf)
        endfor
    endfor
    return recent_bufs
endfunction
function! s:DeleteNonRecentBuffers()
    let recent_buf_nrs = s:GetRecentBufNrs()
    let all_buf_nrs = map(getbufinfo({'buflisted': 1}), {_, buf -> buf.bufnr})
    let non_recent_buf_nrs = filter(all_buf_nrs, {_, bufnr -> index(recent_buf_nrs, bufnr) == -1})

    if empty(non_recent_buf_nrs)
        return
    endif
    let command = printf("bd %s", join(non_recent_buf_nrs, " "))
    execute command
endfunction
augroup VimrcDeleteNonRecentBuffers
    au!
    au VimLeavePre * call <SID>DeleteNonRecentBuffers()
augroup END

cabbrev grep grep -g *.<C-r>=expand("%:e")<CR>

cabbrev <expr> W len(getcmdline()) == 1 ? 'e ~\Desktop\website' : 'W'



"  let g:vimspector_enable_mappings = "HUMAN"

nmap <silent> U <Plug>LineLetters

" new words
function! Remote()
    set stl=
    let b:asyncomplete_enable=0
    ALEDisable
endfunction
command! Remote call Remote()
" stl
" asyncomplete

set number



" Insert Mode Completions {{{

if (executable('pyls'))
    augroup VimrcLsp
        au!
        au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'allowlist': ['python'],
        \ 'config': { 'hover_coneal' : 1},
        \ 'workspace_config': {'pyls': { 'plugins': {'pydocstyle': {'enabled': v:false} } } }
        \ })
    augroup END
endif


" \ 'cmd': {server_info->['tailwindcss-language-server --stdio']},
" \ 'cmd': {server_info->[&shell, &shellcmdflag, 'tailwindcss-language-server --stdio']},
let g:lsp_log_file = expand('~/Desktop/neovim/lsp.log')
" if (executable('tailwindcss-language-server'))
"     augroup TailwindLSP
"         au!
"         au User lsp_setup call lsp#register_server({
"             \ 'name': 'tailwindcss-language-server',
"             \ 'cmd': {server_info->[&shell, &shellcmdflag, 'tailwindcss-language-server --stdio']},
"             \ 'root_uri': {server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'tailwind.config.js'))},
"             \ 'initialization_options': {},
"             \ 'whitelist': ['css', 'php', 'less', 'sass', 'scss', 'vue'],
"             \ })
"     augroup END
" endif

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    " nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> <f2> <plug>(lsp-rename)
endfunction
augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
let g:lsp_diagnostics_enabled = 0
let g:asyncomplete_auto_completeopt = 0
let g:asyncomplete_popup_delay = 0
let g:asyncomplete_enable_for_all = 0




let g:SuperTabDefaultCompletionType="context"
let g:SuperTabCrMapping=1
let g:SuperTabCompleteCase="match"
set completeopt=menuone
set shortmess+=c " Don’t show message and errors in ins-completion-menu
set completeslash=slash " In windows, we want HTML file-completion in insert mode to have '/' in the path



let g:UltiSnipsExpandTrigger='<c-j>'
let g:UltiSnipsJumpForwardTrigger='<c-j>'



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

set formatoptions+=j " Remove comment leader when joining lines, where it makes sense

function! Ftplugin()
    let filetype = &filetype
    let relpath = "~/vimfiles/ftplugin/".filetype.".vim"
    let path = expand(relpath)
    let file_exists = !empty(glob(path))
    if file_exists
        execute "edit ".relpath
    else
        echo relpath." absent"
    endif
endfunction
command! Ftplugin call Ftplugin()

function! DateCompleteFunc(findstart, base)
    " This function is called twice, when doing C-x, C-u
    if a:findstart == 1
        return col(".")
    else
        let fmt_filename = strftime("%y%m%d")
        let fmt_hyphenspace = strftime("%Y - %m - %d")
        let fmt_hyphen = strftime("%Y-%m-%d")
        let fmt_dotspace = strftime("%Y . %m . %d")
        let fmt_dot = strftime("%Y.%m.%d")
        return [ fmt_filename, fmt_dot, fmt_hyphen, fmt_dotspace, fmt_hyphenspace ]
    endif
endfunction

" 2021.01.01
" 2021 . 01 . 01 
" 2021 . 01 . 01 
" 210101 2021 . 01 . 01 2021 . 01 . 01
" 2021 . 01 . 01 
" 2021-02-19

let s:cfu = ""
function! DateInsert()
    let s:cfu=&completefunc
    set completefunc=DateCompleteFunc
    inoremap <A-;> <C-n>
    inoremap <A-:> <C-p>
    function! DateRestore()
        let &completefunc=s:cfu
        inoremap <expr> <A-;> DateInsert()
        iunmap <A-:>
        au! DateInsertGroup
    endfunction
    augroup DateInsertGroup
        au!
        au CompleteDone * call DateRestore()
    augroup END
    return "\<C-x>\<C-u>"
endfunction
inoremap <expr> <A-;> DateInsert()



function! s:BlockSum()
    " let l:message = "VISUAL-BLOCK"
    " call  timer_start(1, function('dotty#Callback', [l:message]))
    let reg_save = @"
    silent! normal! gvy
    let lines = @"
    let @" = reg_save

    try
        let result = eval(join(split(lines, "\n"), "+"))
        let result = printf("%f", result)
    catch /.*/
        let result = "Invalid Block Selection"
    endtry
    " call  timer_start(1, function('dotty#Callback', [result]))
    call common#AsyncPrint(result, 1)

endfunction

function! s:GetVisualMode()
endfunction
function! s:GetMapString()
    echoerr visualmode()
    if visualmode() !=? "\<C-v>"
        echoerr "True"
        return "s"
    endif
    echoerr "False"
    return ":<c-u>echo 'True'\<CR>"
endfunction

" 0.000191
" 0.000221
" 0.000030
" 0.000027


" vmap <silent> <expr> s visualmode() !=? "\<C-v>" ? ":<c-u>call <SID>BlockSum()<CR>" : "s"
vmap <silent> gu :<c-u>call <SID>BlockSum()<CR>


function! PrintCmdlineUpDictionaries()
    for D in g:cmdline_up_dictionaries
        echo printf("%s -> %s", D["start_prefix"], D["final_cmdline"])
    endfor
endfunction
function! s:LogCmdlineUp()

    let g:cmdline_up_dictionaries = []
    let g:cycling_through_matches = v:false

    function! s:LeaveCmdline()
        let g:cmdline_up_dictionaries[-1]["final_cmdline"] = getcmdline()
        let g:cycling_through_matches = v:false
        au! ResetCmdlineFlags
    endfunction

    function! s:CmdlineUp()
        if !g:cycling_through_matches
            call add(g:cmdline_up_dictionaries, { "start_prefix": getcmdline() })
            let g:cycling_through_matches = v:true


            augroup ResetCmdlineFlags
                au!
                au CmdlineLeave : call <SID>LeaveCmdline()
            augroup END

        endif
        return "\<Up>"
    endfunction
    cnoremap <expr> <C-l> <SID>CmdlineUp()


endfunction

" call s:LogCmdlineUp()

    
let g:sqh_provider = 'sqlite'

let g:sqh_connections = {
      \ 'default': {
      \   'database': 'C:/Users/vivek/vimfiles/logs/mru.db'
      \}
\}

let s:greppable_python_paths = []
function! s:PyGrep(key)
    let regex = '\.py$'
    let key = a:key
    " let python_paths = filter(copy(v:oldfiles), 'v:val =~? regex')
    if empty(s:greppable_python_paths)
        let python_paths = filter(copy(v:oldfiles), 'v:val =~? regex')
        call filter(python_paths, { _, path -> filereadable(expand(path)) })
        call filter(python_paths, { _, path -> stridx(tolower(path), "appdata") == -1})
        call filter(python_paths, { _, path -> stridx(tolower(path), "program files") == -1})
        call filter(python_paths, { _, path -> stridx(tolower(path), "undofiles") == -1})
        call map(python_paths, { _, path -> '"'.expand(path).'"'})
        let s:greppable_python_paths = python_paths
    else
        let python_paths = s:greppable_python_paths
    endif
    let path_string = join(python_paths, " ")
    let grep_command = printf('grep "%s" %s', key, path_string)
    if len(grep_command) > 8192
        echo "Too many files"
        return
    endif

    " let @+=grep_command
    " return
    echo "Searching " . len(python_paths) . " files"
    silent! execute grep_command
    redraw
    let match_count = len(getqflist())
    echo printf("%d Matches", match_count)
endfunction
" call timer_start(1, function("PyGrep"))
" call PyGrep()
command! -nargs=1 PyGrep call s:PyGrep(<q-args>)


function! s:OpenTodoFile()
    let date_str = strftime("%y%m%d")
    let filename = date_str . ".txt"
    let path = "~/vimfiles/todo/".filename
    execute "edit ".path
endfunction
nnoremap <silent> <space>o :call <SID>OpenTodoFile()<CR>

function! s:GoAfterEqual()
    if stridx(getline("."), "=") > -1
        normal! 0f=w
        startinsert
    endif
endfunction
nnoremap <silent> E :call <SID>GoAfterEqual()<CR>


function! s:MyCommand()
    normal dst
    normal dst
    normal cst<h4>
endfunction
command! MyCommand call <SID>MyCommand()


function! s:AmazonItem()
    let pos_save = getpos(".")
    keepjumps normal! {j0
    normal! I... Name: 
    normal! j
    normal! I... Price: ₹
    normal! j
    normal! I... Link: 
    s/http.*dp\/\([^\/]\+\)\/.*$/https:\/\/www\.amazon.in\/dp\/\1\/
    call setpos(".", pos_save)
endfunction
command! AmazonItem call <SID>AmazonItem()

function! s:WslFiles()
    %s/C:\\Users\\vivek\\AppData\\Local\\Packages\\CanonicalGroupLimited\.UbuntuonWindows_79rhkp1fndgsc\\LocalState\\rootfs/$WSL
    %s/\\/\//g
endfunction
command! WslFiles call <SID>WslFiles()
