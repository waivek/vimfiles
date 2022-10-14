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
    let yank_start_save = getpos("'[")
    let yank_end_save = getpos("']")
    execute "normal! i "
    execute "normal! x"
    call setpos("'[", yank_start_save)
    call setpos("']", yank_end_save)

    " Load stuff from s:save_D by default

    " Actual Functionality

endfunction
" nmap <expr> <silent> ) <SID>SurroundWithBracketAndInsert()
