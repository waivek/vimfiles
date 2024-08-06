
source mini.vimrc
call plug#begin()
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
call plug#end()
let g:coc_global_extensions = [ 'coc-json', 'coc-pyright', 'coc-vimlsp', '@yaegassy/coc-tailwindcss3', '@yaegassy/coc-volar', 'coc-css', 'coc-tsserver' ]
