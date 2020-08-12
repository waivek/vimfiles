
" GetTheWordNextToMe
function! s:NextUpper()
    let start_pos = getpos('.')
    call search('[A-Z]')
    normal! h
    let end_pos = getpos('.')

    call setpos('.', start_pos)
    normal! v
    call setpos('.', end_pos)
endfunction

" GetTheWordNextToMe
function! s:UpperWord()
    let search_column = search('[A-Z]', 'cb', line("."))
    if search_column == 0
        call search('[A-Z]')
    endif
    let start_pos = getpos('.')

    call search('[A-Z]', 'e')
    normal! h
    let end_pos = getpos('.')

    call setpos('.', start_pos)
    normal! v
    call setpos('.', end_pos)
endfunction

xnoremap <silent> u :<c-u>call <sid>NextUpper()<CR>
onoremap <silent> u :<c-u>call <sid>NextUpper()<CR>

xnoremap <silent> iu :<c-u>call <sid>UpperWord()<CR>
onoremap <silent> iu :<c-u>call <sid>UpperWord()<CR>

nnoremap <silent> U :<c-u>call search('[A-Z]')<CR>
vnoremap <silent> U :<c-u>call search('[A-Z]')<CR>

nnoremap <silent> [u :<c-u>call search('[A-Z]', 'b')<CR>
vnoremap <silent> [u :<c-u>call search('[A-Z]', 'b')<CR>

