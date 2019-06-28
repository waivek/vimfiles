set history=10000
set viminfo='10000,<50,s10,h,rA:,rB:,%,f1
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

let &pythonthreedll='C:\Program Files (x86)\Python\Python37-32\python37.dll'

if has('python3')
    silent! python3 1
endif

let g:CoolTotalMatches=1
let g:UltiSnipsJumpForwardTrigger='<tab>'

iabbrev qq “”
iabbrev -- –
iabbrev –- <BS>—
iabbrev 's ’s
iabbrev 't ’t

set scrolloff=10
nnoremap p ]p
nnoremap P ]P

if mapcheck('<C-x>', "v") != ""
    vunmap <C-x>
endif

if g:colors_name == "codedark"
    hi IncSearch guibg=#682900
endif
