" s:RestoreWrapscanOnCmdlineLeave() {{{
function! s:RestoreWrapscanOnCmdlineLeave()
    function! s:NoWs(...)
        setlocal nowrapscan
        au! RestoreWrapscan
        redraws!
    endfunction

    if &l:wrapscan == 0
        setlocal wrapscan
        augroup RestoreWrapscan
            au!
            au CmdlineLeave / call timer_start(1, function("s:NoWs"))
        augroup END
    endif
endfunction
" }}}

function! s:SearchFlaskRoute()
    call s:RestoreWrapscanOnCmdlineLeave()
    return '/^@app.route(["'']\/\w*'
endfunction


au BufRead *.py nnoremap  <expr> <buffer> gr <SID>SearchFlaskRoute()
