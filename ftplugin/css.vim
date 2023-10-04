function! s:AroundRule()
    call search('[a-z-]\+\s*:\s*[^;{]*;', 'bc')
    let start_pos = getpos('.')
    call search('[a-z-]\+\s*:\s*[^;{]*;\s*', 'e')
    let end_pos = getpos('.')

    call setpos('.', start_pos)
    normal! v
    call setpos('.', end_pos)
endfunction

function! s:InnerRule()
    call search('[a-z-]\+\s*:\s*[^;{]*;', 'bc')
    let start_pos = getpos('.')
    call search('[a-z-]\+\s*:\s*[^;{]*;', 'e')
    let end_pos = getpos('.')

    call setpos('.', start_pos)
    normal! v
    call setpos('.', end_pos)
endfunction

xnoremap <silent> ir :<c-u>call <sid>InnerRule()<CR>
xnoremap <silent> ar :<c-u>call <sid>AroundRule()<CR>

onoremap <silent> ir :<c-u>call <sid>InnerRule()<CR>
onoremap <silent> ar :<c-u>call <sid>AroundRule()<CR>

set isk-=-
setlocal isk-=-
