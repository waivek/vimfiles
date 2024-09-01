function! s:MergeEmptyLines()
    let view_save = winsaveview()
    let pos_save = getpos('.')
    %s/^\s*$\n\s*$//
    call setpos('.', pos_save)
    call winrestview(view_save)
endfunction

command! MergeEmptyLines call <SID>MergeEmptyLines()
