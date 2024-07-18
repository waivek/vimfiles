
function! s:DateCompleteFunc(findstart, base)
    " This function is called twice, when doing C-x, C-u
    if a:findstart == 1
        return col(".")
    else
        let fmt_filename = strftime("%y%m%d")
        let fmt_hyphenspace = strftime("%Y - %m - %d")
        let fmt_hyphen = strftime("%Y-%m-%d")
        let fmt_dotspace = strftime("%Y . %m . %d")
        let fmt_dot = strftime("%Y.%m.%d")
        return [ fmt_filename, fmt_dot, fmt_hyphen, fmt_dotspace, fmt_hyphenspace ]
    endif
endfunction
" 2021.01.01
" 2021 . 01 . 01 
" 2021 . 01 . 01 
" 210101 2021 . 01 . 01 2021 . 01 . 01
" 2021 . 01 . 01 
" 2021-02-19
 "let s:cfu = ""
function! s:DateInsert()
    let s:cfu=&completefunc
    set completefunc=s:DateCompleteFunc
    inoremap <A-;> <C-n>
    inoremap <A-:> <C-p>
    function! s:DateRestore()
        let &completefunc=s:cfu
        inoremap <expr> <A-;> <SID>DateInsert()
        iunmap <A-:>
        au! DateInsertGroup
    endfunction
    augroup DateInsertGroup
        au!
        au CompleteDone * call s:DateRestore()
    augroup END
    return "\<C-x>\<C-u>"
endfunction
inoremap <expr> <A-;> <SID>DateInsert()
cnoremap <expr> <A-;> strftime("%y%m%d")
