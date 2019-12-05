set history=10000
set viminfo='10000,<50,s10,h,rA:,rB:,%,f1,n~/vimfiles/_viminfo
" set viminfo+='1000,
" Plugin & Filetypes {{{
filetype indent plugin on | syntax on 
" }}}
colorscheme codedark
" Remaps {{{
" hjkl to jkl; {{{
noremap j h
noremap k gj
noremap l gk
noremap ; l
inoremap jk 
inoremap Jk 
inoremap jK 
onoremap k j
onoremap l k

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
" }}}

inoremap jk 
cnoremap jk <C-f>

nnoremap h "+
nnoremap Q @:
xnoremap h "+
nnoremap , ;
xnoremap , ;
xmap Q :norm! @a<CR>
xmap . :norm! .<CR>

nnoremap <silent> ch :cd %:p:h<CR>
nnoremap <silent> c. :cd ..<CR>
tnoremap jk <C-W>N
" }}}
" Option Settings {{{
" Indentation {{{
set smartindent " Automatically indents when and where required
set tabstop=4 " Sets tab width to 4 
set shiftwidth=4 " Allows you to use < and > keys in -- VISUAL --
set softtabstop=4 " Makes vim see four spaces as a <TAB>
set expandtab " Inserts 4 spaces when <TAB> is pressed
" }}}

set undofile
set undodir=C:/Users/vivek/vimfiles/undofiles,.
set nowritebackup " Only creates Dropbox Errors
set noswapfile " Only creates Dropbox Errors

set nrformats-=octal " To make CTRL-A work on 07

set backspace=indent,eol,start " Fixes backspace inside insert mode
set laststatus=2

set splitright
set nowrap
runtime macros/matchit.vim
set sidescroll=1


" Searching {{{
set ignorecase smartcase  

set hlsearch
set incsearch

cno <expr>  <tab>    getcmdtype() =~ '[/?]' ? (getcmdtype() == '/' ? '<c-g>' : '<c-t>') : feedkeys('<tab>', 'int')[1]
cno <expr>  <s-tab>  getcmdtype() =~ '[/?]' ? (getcmdtype() == '/' ? '<c-t>' : '<c-g>') : feedkeys('<s-tab>', 'int')[1]

set nowrapscan
" }}}
" Completion {{{
set wildcharm=<C-z>
set wildmenu
set wildmode=full

" }}}

" Setting guifont causes vim to go from maximized mode to windowed mode
if &guifont != 'Consolas:h12:cANSI:qDRAFT'
    set guifont=Consolas:h12:cANSI:qDRAFT
endif

set guioptions=mre
set showtabline=2
set guitablabel=%t
setlocal encoding=utf8
silent! unmenu 📁
menu 📁.▶\ \ Open\ in\ Default\ Viewer :call system(shellescape(expand("%:p")))<CR>
menu 📁.📁\ \ Show\ File\ in\ Directory :call system('explorer "' . expand("%:p:h") . '"')<CR>
menu 📁.📂\ \ Open\ Plugins\ Directory :call system('explorer %userprofile%\vimfiles\pack\plugins\opt')<CR>
menu 📁.🔍\ \ Open\ Search\ Everything :call system('everything -path .')<CR>
map <RightMouse> <C-o>
set belloff=all

inoremap <C-v> <C-r>+

au! BufRead *.afl set filetype=afl 
au Filetype afl setlocal cms=#%s

let &pythonthreedll='C:\Program Files (x86)\Python\Python37-32\python37.dll'

if has('python3')
    silent! python3 1
endif

let g:CoolTotalMatches=1
let g:UltiSnipsJumpForwardTrigger='<tab>'

" Argumentative is modified. At the end of s:MoveLeft() and s:MoveRight, these
" two lines were inserted:
"     call s:ArgMotion(0)
"     call search('\S')
" This positions the cursor at the beginning of the argument. 
" Default behaviour positions the cursor at the end of the argument.
nmap <Left> <Plug>Argumentative_MoveLeft
nmap <Right> <Plug>Argumentative_MoveRight

function! Eatchar(pat)
   let c = nr2char(getchar(0))
   return (c =~ a:pat) ? '' : c
endfunc
" iabbr <silent> if if ()<Left><C-R>=Eatchar('\s')<CR>

iabbrev qq “”
iabbrev -- –
iabbrev –- —<C-R>=Eatchar('\s')<CR>
iabbrev 's ’s
iabbrev 't ’t

set scrolloff=2

if mapcheck('<C-x>', "v") != ""
    vunmap <C-x>
endif

if g:colors_name == "codedark"
    hi IncSearch guibg=#682900
endif

set foldmethod=marker
" }}}

function! SetWebsitePath()
    let working_directory = getcwd()
    if getcwd() == 'C:\Users\vivek\Desktop\website'
        let &path='.,,fonts/**'
    else
        set path&
    endif
endfunction

au! DirChanged * call SetWebsitePath()

function! SetFileSpecificSettings()
    let file_name = expand("%:p:t")
    if file_name == "websites.html"
        function! TransferIncompleteItem()
            normal dd{{pcst<dl>f>,vityo<dd>"</dd>
            normal lfd%lf>,vit
        endfunction
        command! -buffer TransferIncompleteItem call TransferIncompleteItem()
    endif
endfunction
au! BufRead * call SetFileSpecificSettings()

let g:jedi#completions_enabled = 0
let g:jedi#show_call_signatures = 0

let g:ale_linters = { 'python' : [ 'pyflakes' ] }
let g:ale_lint_on_text_changed = 0
let g:ale_lint_on_enter = 0

let g:cursorword_highlight = 0
hi link CursorWord0 Search
hi link CursorWord1 Search

let g:pasta_enabled_filetypes = ['python', 'html']
let g:markdown_fenced_languages = ['xml', 'python', 'html']

au GUIEnter * simalt ~x

function! s:global_function_syntax_groups()
    syntax match Function /[a-zA-Z0-9_]\+\s*\ze(/
    syntax match FunctionWithPeriods /[a-zA-Z.0-9_]\+\s*\ze(/ contains=Function
endfunction

function! s:add_highlight_groups()
    if g:colors_name == "codedark"
        hi FunctionWithPeriods guifg=#a7a765
    elseif g:colors_name == "apprentice"
        hi FunctionWithPeriods guifg=#d8afaf
    endif
endfunction

augroup AddFunctionHighlightGroups
    au!
    au Syntax * call s:global_function_syntax_groups()
    au Syntax * call s:add_highlight_groups()
augroup END

noremap j b
noremap ; w
noremap w $
noremap b ^
vnoremap w g_

let $PLUGINDIR = 'C:\users\vivek\vimfiles\pack\plugins'

set grepprg=rg\ --vimgrep\ --smart-case
let &grepformat = "%f:%l:%c:%m"
" set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case

function! CurlyQuotes()
    call search("[\"']", "c", line("."))
    let visual_start_position = getpos("'<")
    let visual_end_position = getpos("'>")

    let reg_save = @a
    normal! v"ay
    let quote_type = @a
    let @a = reg_save

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
nnoremap cq :call CurlyQuotes()<CR>

function! s:SearchInSelection()
    let keyseq =  '/\%>' . (line("'<") - 1) . 'l\%<' . (line("'>") + 1) . "l"
    call feedkeys(keyseq)
endfunction
vnoremap / :<c-u>call <sid>SearchInSelection()<CR>
" vnoremap / :<c-u>call feedkeys('/\%>' . (line("'<") - 1) . 'l\%<' . (line("'>") + 1) . "l")<CR>
let $TMP='C:\users\vivek\temp'
