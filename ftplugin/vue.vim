if has("win32") || has("win64")
    source ~/vimfiles/ftplugin/html.vim
else
    source ~/.vim/ftplugin/html.vim
endif

set suffixesadd=.vue

let g:vue_pre_processors = [] " Speeds up reading time of vue files
