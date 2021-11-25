
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
    let start = line("w0")
    let end = line("w$")
    let scrolloff = &scrolloff
    return printf('/\%%>%dl\%%<%dl\<', start-1+scrolloff, end+1-scrolloff)
endfunction


nnoremap <expr> <space>f <SID>SearchOnScreen()
