
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
    return '/^\s*function!\?\s\+\(s:\)\?\(\w\+#\)\?\w*'
    " Doesn’t handle dotty#GetMatchByteOffsets()
    " return '/^\s*function!\?\s\+\(s:\)\?'
endfunction


function! s:SearchManPageFunction()
    call s:RestoreWrapscanOnCmdlineLeave()
    return '/^\s*\zs[-a-zA-Z]*'
endfunction

function! s:SearchPythonFunction()
    call s:RestoreWrapscanOnCmdlineLeave()
    return '/\(def\|class\)\s\+\w*'
endfunction

function! s:SearchJavascriptFunction()
    call s:RestoreWrapscanOnCmdlineLeave()
    " return '/\(def\|class\)\s\+\w*'
    " return '/^\s*\(async\)\?\s
    " return '\v^\s*(async)?\s*(if|for|while|else)@!\w+\s*\(.*\)\s*[^;]*$'
    " return '/\v^\s*\zs(async)?\s*(if|for|while|else)@!\w*\s*'
    " return '/\v^\s*\zs(async)?\s*(if|for|while|else)@!\w*\s*[^(]*'
    return '/\v^\s*\zs(async)?\s*function\s*\zs\w*\s*[^(]*'

endfunction

function! s:SearchVimProfileFunction()
    call s:RestoreWrapscanOnCmdlineLeave()
    return '/\c^FUNCTION  .*'
endfunction

function! s:SearchEvalFunction()
    call s:RestoreWrapscanOnCmdlineLeave()
    return '/^[a-z_]*'
endfunction

function! s:GdInFile()
    " pre_yank {{{
    let search_save = @/
    let reg_save = @"
    let yank_start = getpos("'[")
    let yank_end = getpos("']")
    " }}}

    normal! yiw
    if &filetype == 'python'
        let search_pattern = '\(def\|class\)\s\+\zs'.@".'\>'
    elseif &filetype == 'vim'
        let search_pattern = '^\s*function!\?\s\+\(s:\)\?\zs'.@".'\>'
    endif

    let @/ = search_pattern

    let view_save = winsaveview()
    let wrap_save = &wrapscan
    let &wrapscan = 1
    try
        silent normal! N
        if view_save["lnum"] != line(".")
            normal! zt
        endif
    catch /^Vim[^)]\+):E486\D/
        echohl Directory | echon "Definition not found: " | echohl Normal | echon @"."()"
        call winrestview(view_save)
    endtry
    let &wrapscan = wrap_save

    " post_yank {{{
    let @/ = search_save
    let @" = reg_save
    call setpos("'[", yank_start)
    call setpos("']", yank_end)
    " }}}
endfunction

au BufRead *.vim nnoremap  <expr> <buffer> gm <SID>SearchVimFunction()
au BufRead vimrc nnoremap  <expr> <buffer> gm <SID>SearchVimFunction()
au BufRead *.py nnoremap  <expr> <buffer> gm <SID>SearchPythonFunction()
au BufRead *.js,*.html nnoremap  <expr> <buffer> gm <SID>SearchJavascriptFunction()
au BufRead *.man nnoremap  <expr> <buffer> gm <SID>SearchManPageFunction()
au BufRead ~/vimfiles/performance/*.txt nnoremap  <expr> <buffer> gm <SID>SearchVimProfileFunction()
au BufRead builtin.txt nnoremap <expr> <buffer> gm <SID>SearchEvalFunction()

au BufRead vimrc,*.vim nnoremap <buffer> <silent> gd :call <SID>GdInFile()<CR>
au BufRead *.py nnoremap <buffer> <silent> gd :call <SID>GdInFile()<CR>
