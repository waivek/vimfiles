
" TODO: Give Function Names in current file as autocomplete options via popup.txt
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
function! s:SearchVimFunction()
    call s:RestoreWrapscanOnCmdlineLeave()
    return '/^\s*function!\?\s\+\(s:\)\?\(\w\+#\)\?'
    " Doesn’t handle dotty#GetMatchByteOffsets()
    " return '/^\s*function!\?\s\+\(s:\)\?'
endfunction
au BufRead *.vim nnoremap  <expr> <buffer> gm <SID>SearchVimFunction()
au BufRead vimrc nnoremap  <expr> <buffer> gm <SID>SearchVimFunction()


function! s:SearchPythonFunction()
    call s:RestoreWrapscanOnCmdlineLeave()
    return '/\(def\|class\)\s\+\w*'
endfunction
au BufRead *.py nnoremap  <expr> <buffer> gm <SID>SearchPythonFunction()

function! s:SearchVimProfileFunction()
    call s:RestoreWrapscanOnCmdlineLeave()
    return '/\c^FUNCTION  .*'
endfunction
au BufRead ~/vimfiles/performance/*.txt nnoremap  <expr> <buffer> gm <SID>SearchVimProfileFunction()
