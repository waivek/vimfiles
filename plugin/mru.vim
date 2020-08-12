
" GetStrBeforeColon() {{{
function! s:GetStrBeforeColon(str)
    let colon_pos = match(a:str, ":")
    let fname = a:str[:colon_pos-1]
    return fname
endfunction
" }}}
" MruDCompletion() {{{
function! s:MruDCompletion (ArgLead, CmdLine, CursorPos)
    let filenames = []
    let tail = ""
    " file.c -> file\.c
    let regex = substitute(a:ArgLead, '\.', '\\.', "g")
    " f*x -> f.*x
    let regex = substitute(regex, "*", ".*", "g")
    let serial_number = ""
    let i = 1
    for fname in v:oldfiles
        let tail = fnamemodify(fname, ":t")
        let parent = fnamemodify(fname, ":h:t")
        if tail =~# '\<' . regex
            let serial_number = i . ":" . parent . "/" . tail
            call add(filenames, serial_number)
        endif
        let i = i+1
    endfor
    return filenames
endfunction
" }}}
" MruCompletion() {{{
function! s:MruCompletion (ArgLead, CmdLine, CursorPos)
    let filenames = []
    let tail = ""
    " file.c -> file\.c
    let regex = substitute(a:ArgLead, '\.', '\\.', "g")
    " f*x -> f.*x
    let regex = substitute(regex, "*", ".*", "g")
    let serial_number = ""
    let i = 1
    for fname in v:oldfiles
        let tail = fnamemodify(fname, ":t")
        if tail =~# '\<' . regex
            let serial_number = i . ":" . tail
            call add(filenames, serial_number)
        endif
        let i = i+1
    endfor
    return filenames
endfunction
" }}}
" MruFunction () {{{
" For empty string open's first file
function! s:MruFunction(args)
    let fname = ""
    " They entered a full file name like `cs.vim`
    if match(a:args, ":") == -1
        let filenames = s:MruCompletion(a:args, 0, 0)
        " There is at least one result
        if !empty(filenames)
            let fname = filenames[0]
        endif
    else
        let fname = a:args
    endif
    if !empty(fname)
        let pos_plus_one = s:GetStrBeforeColon(fname)
        execute "edit " . v:oldfiles[pos_plus_one-1]
    else
        echo "Invalid Input"
    endif
endfunction
" }}}
" MruQuickfix() {{{
function! s:MruQuickfix(term) 
    let L = []
    let regex = substitute(a:term, '\.', '\\.', "g")
    let regex = substitute(regex, "*", ".*", "g")
    for path in v:oldfiles
        let tail = fnamemodify(path, ":t")
        if tail =~# '\<' . regex
            let D = {
                        \"filename" : path
                        \}
            call add(L, D)
        endif
    endfor
    call setqflist(L)
    copen
endfunction
" }}}
command! -complete=customlist,s:MruCompletion -nargs=? MRU call s:MruFunction("<args>")
command! -complete=customlist,s:MruDCompletion -nargs=? MRUD call s:MruFunction("<args>")
command! -nargs=? MRUQ call s:MruQuickfix("<args>")
