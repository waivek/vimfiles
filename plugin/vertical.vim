function! s:DeleteLastSearchItemFromHistoryOnLeave()
    function! s:HistDel(...)
        call histdel('/', -1)
        au! DeleteSearchHistory
    endfunction
    augroup DeleteSearchHistory
        au!
        au CmdlineLeave / call timer_start(1, function("s:HistDel"))
    augroup END
endfunction

function! s:RestoreWrapscanOnCmdlineLeave()
    function! s:NoWs(...)
        setlocal nowrapscan
        au! RestoreWrapscan
        " redraws
    endfunction

    if &l:wrapscan == 0
        setlocal wrapscan
        augroup RestoreWrapscan
            au!
            au CmdlineLeave / call timer_start(1, function("s:NoWs"))
        augroup END
    endif
endfunction

function! s:SearchOnScreen()
    call s:RestoreWrapscanOnCmdlineLeave()
    call s:DeleteLastSearchItemFromHistoryOnLeave()
    let start = line("w0")
    let end = line("w$")
    let scrolloff = &scrolloff
    return printf('/\%%>%dl\%%<%dl\<', start-1+scrolloff, end+1-scrolloff)
endfunction

nnoremap <expr> <Plug>SearchOnScreen <SID>SearchOnScreen()
