" https://www.vikasraj.dev/blog/vim-dot-repeat
let s:call_count = 0
let s:save_D = ""
function! s:FunctionName(motion = v:null)
    if a:motion == v:null
        let s:call_count = 0
        set operatorfunc=s:FunctionName
        return 'g@'
    endif

    if s:call_count == 0
        " First Occurrence. Save stuff in s:save_D
    endif

    " Merge undoblock
    execute "normal! i "
    execute "normal! x"

    " Load stuff from s:save_D by default

    " Actual Functionality

endfunction
" nmap <expr> <silent> ) <SID>SurroundWithBracketAndInsert()
