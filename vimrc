" Indent related options during formatting via gq:
" Auto-indenting of hypens (-)     = 'comments'
" Auto-indenting of the word 'for' = 'cinwords'

" VIMRC GUIDES:
"
" 1. Reduce as many functions into nested ternary operators. Avoids complexity
"    and reduces `function` blocks from polluting vimrc
"
" 2. Ensure compatibility. Check for `repeat#set` function existence etc. You
"    should be able to use this vimrc in WSL and linux without getting errors.
"
" 3. Prioritize typing latency and buffer switching latency. Plugins slow you
"    down when typing. Without `jedi` & `scroll.vim` it feels faster and more
"    productive. `tagalong.vim` was also incurring mental overhead cost as it 
"    kept fucking up PASTE operation.
"
"    Filetypes: .vim 329, .html 324, .py  292, .json 107, .css      89, .bat 79, 
"               .js   57, .md    46, .php  36, .afl   25, .go       24, .svg 21, 
"               .log  18, .rst   14, .m3u8 13, .sql   10, .snippets 10 


set history=10000
set viminfo='10000,<50,s10,h,rA:,rB:,%,f1,n~/vimfiles/_viminfo
" Unix {{{
if has("unix")
    set viminfo='10000,<50,s10,h,rA:,rB:,%,f1,n~/.vim/_viminfo
endif
" }}}
filetype indent plugin on | syntax on 

call plug#begin()
Plug 'dense-analysis/ale'
" Plug 'neoclide/coc.nvim', { 'tag': 'v0.0.81' }
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'AndrewRadev/sideways.vim'
Plug 'puremourning/vimspector'
Plug 'leafOfTree/vim-vue-plugin'
call plug#end()
if has("win32")
    source ~/vimfiles/ide.vim
endif

if has("win32")
    let $WSL = 'C:\Users\vivek\AppData\Local\Packages\CanonicalGroupLimited.UbuntuonWindows_79rhkp1fndgsc\LocalState\rootfs\'
endif


if has("win32")
    source ~/vimfiles/plugin/colorscheme.vim
    colorscheme codedark
    " colorscheme apprentice
    " colorscheme dracula

endif

set nobackup
" set backup
" set writebackup " Only creates Dropbox Errors
" set backupdir=C:/Users/vivek/vimfiles/backupfiles,.

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
" Indentation
set smartindent   " Automatically indents when and where required
set tabstop=4     " Sets tab width to 4
set shiftwidth=4  " Allows you to use < and > keys in -- VISUAL --
set softtabstop=4 " Makes vim see four spaces as a <TAB>
set expandtab     " Inserts 4 spaces when <TAB> is pressed
set formatoptions+=j " Remove comment leader when joining lines, where it makes sense
set formatoptions+=ro

" set nowritebackup " Only creates Dropbox Errors
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
    " au BufRead *.vue set filetype=php 
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




" DEPRECATED:
"
"   Argumentative is modified. At the end of s:MoveLeft() and s:MoveRight, these two lines were inserted:
"       call s:ArgMotion(0)
"       call search('\S')
"   This positions the cursor at the beginning of the argument. Default behaviour positions the cursor at the end of the argument.
"

function! s:DisableUltiSnipsTracker()
    if exists("#UltiSnips_AutoTrigger")
        au! UltiSnips_AutoTrigger
    endif
endfunction
augroup VimrcDisableUltiSnipsTracker
    au!
    au VimEnter * call s:DisableUltiSnipsTracker()
augroup END

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

map <silent> <C-k>      <C-f>
map <silent> <PageDown> <Plug>scroll_page_down
" nmap <silent> <C-f>      <Plug>scroll_page_down

map <silent> <C-l>      <C-b>
map <silent> <PageUp>   <Plug>scroll_page_up
" nmap <silent> <C-b>      <Plug>scroll_page_up

let g:scroll_smoothness = 1


" }}}
" Functions and Mappings {{{


" START tmprgsv
" PATH ~/vimfiles/template.vim

let s:reg_save = ''
function! s:SaveRegister(register)
    execute 'let s:reg_save = @'.a:register
endfunction
function! s:RestoreRegister(register)
    execute printf('let @%s = s:reg_save', a:register)
endfunction

" END tmprgsv

function! s:SetFileSpecificSettings()
    let file_name = expand("%:p:t")
    if file_name ==# "twitch_clips.md"
        function! s:FormatTwitchClips()
            silent! g/^\s*$/d
            silent! %s/https:\/\/www\.twitch\.tv\/\(\w\+\)\/clip\/\(\w\+\)?\?.*$/https:\/\/clips.twitch.tv\/\2 - \1 -
            Tabularize /-
        endfunction
        augroup AlignDashes
            au!
            au BufWritePre <buffer> call s:FormatTwitchClips()
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
    au BufRead * call s:SetFileSpecificSettings()
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
    if &filetype ==# 'text'
        return
    endif
    syntax match Function /[a-zA-Z0-9_]\+\s*\ze(/
    " syntax match FunctionWithPeriods /[a-zA-Z.0-9_]\+\s*\ze(/ contains=Function

    " syntax match FunctionLeaf /\<[^ ,()]*\>([^,()]*)/

    syntax match CustomMode /\s\+vim:.*/
endfunction
function! s:AddHighlightGroups()
    " hi! link FunctionLeaf Identifier
    " `if !exists("g:colors_name")
    " `    return
    " `endif
    if g:colors_name ==# "codedark"
        hi FunctionWithPeriods guifg=#a7a765
    elseif g:colors_name ==# "apprentice"
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
command! ToggleScreencastMode call s:ToggleScreencastMode()

function! s:AddPositionToJumpList()
    let save_a_mark = getpos("'a")
    normal! ma
    normal! `a
    call setpos("'a", save_a_mark)
endfunction

function! s:PreviousIndent(mode)
    call s:AddPositionToJumpList()
    let start_indent = indent(".")
    let previous_indent = indent(".") - 1
    if previous_indent == -1
        let previous_indent = 0
    endif
    let regexp = printf('^\s\{0,%d\}\S', previous_indent)
    if a:mode ==# "v"
        normal! gv
        call search(regexp, 'be')
    elseif a:mode ==# "n"
        call search(regexp, 'be')
    endif

    " Handle if <Tab>'s are used for indentation. These are not found by the
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
nnoremap <silent> <BS> :call <SID>PreviousIndent("n")<CR>
xnoremap <silent> <BS> :<c-u>call <SID>PreviousIndent("v")<CR>

" ENCODING ISSUES:

function! s:FixEncoding()
    %substitute/â/“/g
    %substitute/â/”/g
    %substitute/â/‘/g
    %substitute/â/-/g
    %substitute/â¦/…/g
endfunction

function! s:GetAlignment(_, string)
    let string = a:string
    let is_number = string =~# '^[0-9.]\+$' 
    if is_number
        return "r"
    else
        return "l"
    endif
endfunction
function! s:TabularizeCharacterUnderCursor()
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
    let alignments = map(columns, function("s:GetAlignment"))
    let tabular_alignment_command = join(alignments, "1c1")
    let tabular_command = printf("Tabularize /%s/%s1", character_under_cursor, tabular_alignment_command)
    execute tabular_command
    let @a = tabular_command
    echo tabular_command

endfunction
nnoremap <silent> gt :call <SID>TabularizeCharacterUnderCursor()<CR>

" }}}

function! s:RedrawAtTopIfBufferSizeLessThanWindowSize()
    let window_height = winheight(0)
    let buffer_height = line("$")
    let condition = buffer_height < window_height
    return condition ? "gd" : "gdzt"
endfunction
nnoremap <expr> gd <SID>RedrawAtTopIfBufferSizeLessThanWindowSize()

function! s:EnableSpellApplyFirstSuggestionDisableSpell()
    set spell
    normal! 1z=
    set nospell
endfunction
nnoremap <silent> z= :call <SID>EnableSpellApplyFirstSuggestionDisableSpell()<CR>

function! s:FileGrep(key)
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
command! -nargs=1 FileGrep call s:FileGrep(<q-args>)


function! s:ConsoleCompletion(ArgLead, CmdLine, CursorPos)
    let pattern = a:ArgLead
    return filter(["plugin", "website", "twitch", "vimfiles" ], {pos, x -> x =~# pattern})
endfunction
function! s:Console(flag)
    let flag = a:flag
    if flag ==# ""
        silent !start cmd
    elseif flag ==# "."
        let file_dir = expand("%:p:h") . '\'
        let command = 'silent !start cmd /k "cd '.file_dir.'"'
        execute command
    elseif flag ==# "plugin"
        silent !start cmd /k "cd C:\Users\vivek\vimfiles\pack\plugins\start\"
    elseif flag ==# "website"
        silent !start cmd /k "cd C:\Users\vivek\Desktop\website\"
    elseif flag ==# "twitch"
        silent !start cmd /k "cd C:\Users\vivek\Desktop\Twitch\"
    elseif flag ==# "vimfiles"
        silent !start cmd /k "cd C:\Users\vivek\vimfiles\"
    endif
endfunction
command! -complete=customlist,s:ConsoleCompletion -nargs=? CMD call s:Console(<q-args>)

function! s:ChangeDirectoryCompletion(ArgLead, CmdLine, CursorPos)
    let pattern = a:ArgLead
    return filter(["plugin", "website", "twitch", "vimfiles", "youtube", "live" ], {pos, x -> x =~# pattern})
endfunction
function! s:ChangeDirectory(flag)
    let flag = a:flag
    if flag == ""
        return
    elseif flag ==# "plugin"
        cd C:\Users\vivek\vimfiles\pack\plugins\start\
        echo 'C:\Users\vivek\vimfiles\pack\plugins\start\'
    elseif flag ==# "website"
        cd C:\Users\vivek\Desktop\website\
        echo 'C:\Users\vivek\Desktop\website\'
    elseif flag ==# "twitch"
        cd C:\Users\vivek\Desktop\Twitch\
        echo 'C:\Users\vivek\Desktop\Twitch\'
    elseif flag ==# "vimfiles"
        cd C:\Users\vivek\vimfiles\
        echo 'C:\Users\vivek\vimfiles\'
    elseif flag ==# "youtube"
        cd C:\Users\vivek\Desktop\youtube_dl\
        echo 'C:\Users\vivek\Desktop\youtube_dl\'
    elseif flag ==# "live"
        cd C:\Users\vivek\Desktop\live\www\html
        echo 'C:\Users\vivek\Desktop\live\www\html'
    endif
endfunction
command! -complete=customlist,s:ChangeDirectoryCompletion -nargs=? CD call s:ChangeDirectory(<q-args>)

function! s:AddAriaFile(u, n)
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
command! -nargs=* AddAriaFile call s:AddAriaFile(<f-args>)

" Preconditions:
"     HTML file should contain a <nav> tag
"     <nav> tag should contain an li a.href={filename}

" how to run
"   
"   cd website
"   grep -g *.html "css/list.css"
"   cdo UpdateNavigation
function! s:UpdateNavigation()
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
command! UpdateNavigation call s:UpdateNavigation()


let &fillchars='vert:|,fold: '
hi! link Folded Function
function! s:FoldTextMinimal()
    let indent = indent(v:foldstart)
    let leading_spaces = repeat(" ", indent)
    " let leading_spaces = "+" . leading_spaces[1:]
    let first_line = getline(v:foldstart)
    let foldmessage = trim(substitute(foldtext(), ".*lines: ", "", "g"))

    return leading_spaces . "[+] " . foldmessage . " ..."
endfunction
set foldtext=s:FoldTextMinimal()


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



nnoremap V Vg$
nmap <silent> U <Plug>LineLetters
set number
set shortmess+=c " Don’t show message and errors in ins-completion-menu
set completeslash=slash " In windows, we want HTML file-completion in insert mode to have '/' in the path





function! s:Ftplugin()
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
command! Ftplugin call s:Ftplugin()

function! s:DateCompleteFunc(findstart, base)
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
 "let s:cfu = ""
function! s:DateInsert()
    let s:cfu=&completefunc
    set completefunc=s:DateCompleteFunc
    inoremap <A-;> <C-n>
    inoremap <A-:> <C-p>
    function! s:DateRestore()
        let &completefunc=s:cfu
        inoremap <expr> <A-;> <SID>DateInsert()
        iunmap <A-:>
        au! DateInsertGroup
    endfunction
    augroup DateInsertGroup
        au!
        au CompleteDone * call s:DateRestore()
    augroup END
    return "\<C-x>\<C-u>"
endfunction
inoremap <expr> <A-;> <SID>DateInsert()
cnoremap <expr> <A-;> strftime("%y%m%d")



" 0.000191
" 0.000221
" 0.000030
" 0.000027
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
vmap <silent> gu :<c-u>call <SID>BlockSum()<CR>

function! s:PrintCmdlineUpDictionaries()
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

call s:LogCmdlineUp()

    
function! s:GoAfterEqual()
    if stridx(getline("."), "=") > -1
        normal! 0f=w
        startinsert
    endif
endfunction
" nnoremap <silent> E :call <SID>GoAfterEqual()<CR>

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
command! AmazonItem call s:AmazonItem()

function! s:Frequency()
    %sort
    %!uniq -c
    %sort! n
endfunction
command! Frequency call s:Frequency()

function! s:HighlightKeywords()
    call clearmatches()
    call matchadd("Identifier", '\[TODO\]')
    call matchadd("String", '\[WRITE\]')
    call matchadd("Function", '\[PRIORITY\]')
endfunction
command! HighlightKeywords call s:HighlightKeywords()
augroup ConfigHl
    au!
    au BufRead ~/vimfiles/config.txt call s:HighlightKeywords()
augroup END

function! s:OpenTodoFile()
    let date_str = strftime("%y%m%d")
    let filename = date_str . ".txt"
    let path = "~/vimfiles/todo/".filename
    execute "edit ".path
endfunction

function! s:OpenMainFile()
    let filename = strftime("main-%Y-%m-%b.txt")
    let path = "~/vimfiles/todo/".filename
    execute "edit ".path
endfunction

function! s:OpenProbabilitiesFile()
    let date_str = strftime("%y%m%d")
    let filename = date_str . ".txt"
    let path = "~/vimfiles/probability/".filename
    execute "edit ".path
endfunction


function! s:ConfigHelper1()
    let directory = 'C:\Users\vivek\Documents\config\PowerShell'
    let default_path = expand("%:p")
    let fname = expand("%:t")
    let config_path = directory.'\'.fname
    let save_as_command = printf(":saveas %s", config_path)
    let mklink_command = printf("mklink %s %s", default_path, config_path)
    echo save_as_command
    echo mklink_command
endfunction
command! ConfigHelper1 call s:ConfigHelper1()

function! s:Gather()
    " call s:SaveRegister('a')

    " normal! ma
    " let @a = ""
    " g//d A
    " 'aput


    execute ":g//m " . line(".")

    call s:RestoreRegister('a')
endfunction
command! Gather call s:Gather()

function! s:PrintSingleLineCommandsAndMaps()
endfunction

function! s:ToList()
    %s/\(.*\)\n/"\1", /g
    s/.*/[ \0 ]/
    s/,  \ze]/ /
endfunction
command! ToList call s:ToList()


function! s:FormatZomato()
    g/jumbo-tracker/normal! vatJ
    v/Pro/d
    %s/<[^>]\+>//g
    %s/^\s*\(Promoted\)\?\s*//
    %s/\s*star-fill.*//
endfunction
command! FormatZomato call s:FormatZomato()


function! s:EnableHotReload()
    source %
    echo "(hmr) " . expand("%:p")
    augroup HotReload
        au!
        au BufWritePost <buffer> source %
    augroup END
endfunction
command! HotReload call s:EnableHotReload()

function! s:GoBackToQuoteAndStartInsert()
    normal! F"
    startinsert
endfunction
nnoremap <silent> "I :call <SID>GoBackToQuoteAndStartInsert()<CR>

function! s:SelectSample()
    let next_line = line(".") + 1
    execute '.m'.(search("^\s*$", "wn")-1)
    execute ":".next_line
endfunction
augroup SpaceSpace
    au!
    au BufRead ~/vimfiles/temp/comma_samples.txt nnoremap <buffer> <space><space> :call <SID>SelectSample()<CR>
augroup END

function! s:SearchUserFunctions()
    cd ~/vimfiles
    grep -g *.vim "^.* [A-Z]\w+\("
    Cfilter! /^\s*"/
    execute 'Cfilter! /\(String2Pattern\|CocAction\|CocHasProvider\)(/'
    Cfilter! /^\s*\(function\|class\)/
    Cfilter! autoload
    Cfilter! plugged
    normal! 
    copen
endfunction
command! SUF call s:SearchUserFunctions()


function! s:Isolate(pattern) range
    if len(a:pattern) == 0
        let pattern = @/
    else
        let pattern = substitute(a:pattern, "^/", "", "")
        let pattern = substitute(pattern, "/$", "", "")
    endif
    let range_passed = a:firstline != a:lastline
    let range_passed = v:false " Override because range is buggy
    if range_passed
        execute printf('%d,%ds/' . pattern . '/\0/g', a:firstline, a:lastline)
        execute printf('%d,%dv/' . pattern . '/d', a:firstline, a:lastline)
        execute printf('silent! normal! %dGgu%dG', a:firstline, a:lastline)
        execute printf('silent! %d,%dsort', a:firstline, a:lastline)
        " execute printf('silent! %d,%d!uniq -c', a:firstline, a:lastline)
        " execute printf('silent! %d,%dsort! n', a:firstline, a:lastline)
    else
        execute '%s/' . pattern . '/\0/g'
        execute 'v/' . pattern . '/d'
        silent! normal! ggguG
        silent! %sort
        silent! %!uniq -c 
        silent! %sort! n
    endif
endfunction
command! -range -nargs=? Isolate <line1>,<line2>call s:Isolate(<q-args>)

function! s:LoadKMarkedFile()
    let single_list = filter(getmarklist(), {idx, D -> D['mark'] ==# "'K"})
    if len(single_list) == 0
        echo "No file marked with 'K"
        return
    endif
    let path = expand(single_list[0]['file'])
    
    if bufexists(path)
        execute "b " . path
    else
        execute "edit " . path
    endif
    normal! 0w
endfunction

function! s:CapitalizeSqlite()
    silent! s/table\|create\|drop\|in\|by\|having\|order\|count\|group\|select\|from\|inner\|join\|using\|where\|like/\U\0/g
endfunction
command! CapitalizeSqlite call s:CapitalizeSqlite()

function! s:EqualHeader()
    t.
    s/^\s*\S \zs.*/\=substitute(submatch(0), ".", "=", "g")
endfunction



function! s:GrepAbbrev()
    if &filetype ==# "vim"
        return "grep -g *.vim -g vimrc"
    endif
    let extension = expand("%:e")
    if extension == ""
        return "grep -g *.". &filetype
    endif
    return "grep -g *.". extension
endfunction


nnoremap =r :call <SID>EqualHeader()<CR>

cabbrev   <expr> <         len(getcmdline()) == 1 && getcmdtype() =~ '[/?]' ? '\C\\><Left><Left>' : '<'
nnoremap         <space>w                                                     /\C\<\><Left><Left>
nnoremap <expr> gt <SID>DotRepeat() " 1.


" Uncategorized


" Single File Specific Commands
command! NormalizeTwitchUrl         s/https:\/\/www\.twitch\.tv\/\w\+\/clip\/\([a-zA-Z]\+\)?[a-zA-Z_0-9=&]\+/https:\/\/clips.twitch.tv\/\1
command! YoutubeUrlToThumbnailUrl   s/https:\/\/www\.youtube\.com\/watch?v=\(\w\{-}\)\W/https:\/\/i.ytimg.com\/vi\/\1\/maxresdefault.jpg
command! WslFilesSubstitute        %s/C:\\Users\\vivek\\AppData\\Local\\Packages\\CanonicalGroupLimited\.UbuntuonWindows_79rhkp1fndgsc\\LocalState\\rootfs/$WSL/|%s/\\/\//g

" command! RunLine execute(substitute(getline("."), '^"\s*', '', ''))

" Remaining: :command, :augroup, :map
" Command:
"     g/^command/v/-complete/|normal! ``
cabbrev <expr> grep len(getcmdline()) == 4 && getcmdtype() == ":" ? <SID>GrepAbbrev() : "grep"
cabbrev <expr> W    len(getcmdline()) == 1 && getcmdtype() == ":" ? 'e ~\Desktop\website' : 'W'
cabbrev <expr> o    len(getcmdline()) == 1 && getcmdtype() == ":" ? "!start %" : "o"
cabbrev <expr> V    len(getcmdline()) == 1 && getcmdtype() == ":" ? (bufexists($MYVIMRC) ? "b ".expand($MYVIMRC): "edit $MYVIMRC") : 'V'
cabbrev <expr> ln   len(getcmdline()) == 2 && getcmdtype() == ":" ? 'lnext' : 'ln'
cabbrev <expr> E    len(getcmdline()) == 1 && getcmdtype() == ":" ? '!start everything -path .' : 'E'
cabbrev <expr> P    len(getcmdline()) == 1 && getcmdtype() == ":" ? '!start everything -parent .' : 'P'
cabbrev <expr> D    len(getcmdline()) == 1 && getcmdtype() == ":" ? '!start .' : 'D'
cabbrev <expr> coc  getcmdline() == "h coc" && getcmdtype() == ":" ? 'coc-nvim' : 'coc'

nnoremap <silent> <space>o :call <SID>OpenTodoFile()<CR>
nnoremap <silent> <space>i :call <SID>OpenMainFile()<CR>
nnoremap <silent> <space>p :call <SID>OpenProbabilitiesFile()<CR>

nnoremap <silent> <space>/ :s#\\#/#g<CR>
nnoremap <silent> <space>\ :s#/#\\#g<CR>

nnoremap          <space>l <C-^>
nnoremap <silent> <space>k :call <SID>LoadKMarkedFile()<CR>
nnoremap          <space>r :MRU 

nmap              <space>f <Plug>SearchOnScreen
nmap     <silent> <space>; <Plug>Run


function! s:AppendCommaToRange()
    silent! '<,'>s/[^,]\zs$/,
endfunction
noremap <expr> <silent> , mode() ==# 'V' ? ":<c-u>call <SID>AppendCommaToRange()<CR>" : ';'


" -- START: `:w` to WRITE
function! s:RemoveTempRemaps(...)
    if mapcheck("r") !=# ""
        nunmap r
    endif
endfunction
function! s:DoTempRemaps()
    nnoremap r :call <SID>ObnoxiousErrorMessage('r')<CR>
    call timer_start(1000, function("s:RemoveTempRemaps"))
endfunction
augroup TempRemap
    au!
    au BufWritePost * call s:DoTempRemaps()
augroup END
function! s:ObnoxiousErrorMessage(keystroke)
    let is_command_window = len(getcmdwintype()) > 0
    let is_quickfix_or_loclist = getwininfo(bufwinid("%"))[0]["quickfix"] == 1
    if is_command_window || is_quickfix_or_loclist
        normal! 
        return
    endif
    for i in range(20)
        echoerr "Don’t Press " . a:keystroke
    endfor
endfunction
nnoremap <silent> <CR> :call <SID>ObnoxiousErrorMessage('CR')<CR>
nnoremap <silent> <S-CR> :w<CR>
cnoremap <expr> w len(getcmdline()) == 0 && getcmdtype() == ":" ? "w<CR>" : "w"
" -- END: `:w` to WRITE

" Global Functions:
" function! s:ReadHandlerErrorFile(path, cf_nr)
function! RHEF(path, cf_nr)
    let error_format_save = &errorformat
    let &errorformat = "%f:%l:%c:%m"
    execute 'cgetfile ' . a:path
    execute 'cc ' . string(a:cf_nr)
    let &errorformat = error_format_save
endfunction

function! PrintList(items)
    echo join(a:items, "\n\n")
endfunction


nnoremap d) dt)

command! Bk !start cmd /k "cd C:\Users\vivek\Desktop\bkp\"
command! Sq !start cmd /k "sqlite3 C:\Users\vivek\Documents\Python\backup-flask\data.db"

nmap 3 #
nmap 8 *
vmap 3 #
vmap 8 *

cnoremap <expr> M len(getcmdline()) == 0 && getcmdtype() == ":" ? "call <SID>ObnoxiousErrorMessage('MRU')<CR>" : "M"

source ~/vimfiles/performance/performance.vim


