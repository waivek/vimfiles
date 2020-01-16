set history=10000
set viminfo='10000,<50,s10,h,rA:,rB:,%,f1,n~/vimfiles/_viminfo
filetype indent plugin on | syntax on 

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

set backspace=indent,eol,start " Fixes backspace inside insert mode
set laststatus=2

set ignorecase smartcase  
set hlsearch incsearch
set nowrapscan
cno <expr>  <tab>    getcmdtype() =~ '[/?]' ? (getcmdtype() == '/' ? '<c-g>' : '<c-t>') : feedkeys('<tab>', 'int')[1]
cno <expr>  <s-tab>  getcmdtype() =~ '[/?]' ? (getcmdtype() == '/' ? '<c-t>' : '<c-g>') : feedkeys('<s-tab>', 'int')[1]

set wildcharm=<C-z>
set wildmenu
set wildmode=full

setlocal encoding=utf8
let &pythonthreedll='C:\Program Files (x86)\Python\Python37-32\python37.dll'
if has('python3')
    silent! python3 1
endif
if &guifont != 'Consolas:h12:cANSI:qDRAFT'
    " Setting guifont causes vim to go from maximized mode to windowed mode
    set guifont=Consolas:h12:cANSI:qDRAFT
endif

