function! HighlightGroupUnderCursor()
    let a = synIDattr(synID(line("."),col("."),1),"name")
    let b = synIDattr(synID(line("."),col("."),0),"name")
    let c = synIDattr(synIDtrans(synID(line("."),col("."),1)),"name")
    echo a . ' -> ' . b . ' -> ' . c 
endfunction

map <F10> :call HighlightGroupUnderCursor()<CR>

function! IDcolors (name)
    let id = hlID(a:name)
    let fg = synIDattr(id, "fg")
    let bg = synIDattr(id, "bg")
    let cmd = "hi " . a:name . " guifg=" . fg . " guibg=" . bg
    exec "put='" . cmd . "'"
endfunction

hi Visual guifg=white guibg=DarkRed
hi StatusLine guifg=#fff0f7 guibg=#d46a84
hi Normal guifg=#75616b guibg=#fff0f7
hi WildMenu guifg=#000000 guibg=#F5DEB3
hi Search guifg=#ffffff guibg=#1B9E9E gui=none
command! -complete=highlight -nargs=1 IDcolors call IDcolors(<q-args>)
set guicursor+=v:block-vCursor
hi vCursor gui=reverse
