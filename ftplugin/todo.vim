
" Filetype plugin for TODO files

" Set the syntax highlighting to use the custom TODO syntax
setlocal syntax=todo

" Additional settings for TODO files
setlocal commentstring=#\ %s

" function to toggle ✓ at the start of the line
function s:ToggleDone()
    let l:line = getline('.')
    let on_line_end = col('.') == len(l:line)
    let line_starts_with_tick = match(l:line, '✓') == 0
    let old_line_length = len(l:line)
    if line_starts_with_tick
        " remove tick and spaces after tick
        let l:line = substitute(l:line, '✓\s*', '', '')
    else
        " add tick and space after tick
        let l:line = '✓ ' . l:line
    endif
    call setline('.', l:line)
    let new_line_length = len(l:line)
    " restore cursor position
    let l:diff = new_line_length - old_line_length
    if on_line_end
        " place cursor at end
        call cursor(0, new_line_length)
    else
        call cursor(0, col('.') + l:diff)
    endif

endfunction

" Map <tab> to toggle the done status of the current line on normal mode
nnoremap <buffer> <tab> :call <SID>ToggleDone()<CR>
