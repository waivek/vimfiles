set history=10000
set viminfo='10000,<50,s10,h,rA:,rB:,%,f1,n~/vimfiles/_viminfo
filetype indent plugin on | syntax on 
set nocompatible


setlocal encoding=utf8


" Reasons To Use over /pack/
" 1. Faster to toggle plugins. With /pack/ you have to open Folder and move
" 2. Automates `helptags .`, and documentation is always taken care of
call plug#begin()
Plug 'dense-analysis/ale'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()


let &pythonthreedll='C:\Program Files\Python310\python310.dll'
let s:vim_path = ""
if has("win32")
    let s:vim_path = glob("~/vimfiles")
elseif has("unix")
    let s:vim_path = glob("~/vim")
endif

set undofile
if has("win32")
    set undodir=C:/Users/vivek/vimfiles/undofiles,.
endif

if has('python3')
    silent! python3 1
endif
if &guifont != 'Consolas:h12:cANSI:qDRAFT'
    set guifont=Consolas:h12:cANSI:qDRAFT
endif

set backspace=indent,eol,start " Fixes backspace inside insert mode
set laststatus=2
if len(glob(s:vim_path."/colors/codedark.vim")) > 0
    colorscheme codedark
endif

" Search
set ignorecase smartcase  
set hlsearch incsearch
set nowrapscan
cno <expr>  <tab>    getcmdtype() =~ '[/?]' ? (getcmdtype() == '/' ? '<c-g>' : '<c-t>') : feedkeys('<tab>', 'int')[1]
cno <expr>  <s-tab>  getcmdtype() =~ '[/?]' ? (getcmdtype() == '/' ? '<c-t>' : '<c-g>') : feedkeys('<s-tab>', 'int')[1]

" Completion
set wildcharm=<C-z>
set wildmenu
set wildmode=full
set belloff=all
set completeopt=menuone,popup

set smartindent   " Automatically indents when and where required
set tabstop=4     " Sets tab width to 4
set shiftwidth=4  " Allows you to use < and > keys in -- VISUAL --
set softtabstop=4 " Makes vim see four spaces as a <TAB>
set expandtab     " Inserts 4 spaces when <TAB> is pressed

set foldmethod=marker

set guioptions=M
au GUIEnter * simalt ~x " Maximized

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

inoremap jk 
inoremap <C-v> <C-r>+
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

nnoremap <C-k> <C-f>
nnoremap <C-l> <C-b>
" }}}

nnoremap <Space>l <C-^>
nnoremap <silent> <Space>/ :s#\\#/#g<CR>
nnoremap <silent> <Space>\ :s#/#\\#g<CR>

inoremap <C-v> <C-r>+

set nowrap

source ~/vimfiles/ide.vim
