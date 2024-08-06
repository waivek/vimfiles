let s:test = v:false

function! s:Inline()
    if s:test
        let l:line = 'let s:argument = 123 + 456'
        let l:nextline = 'let s:result = eval(s:argument)'
    else
        let l:line = getline('.')
    endif
    if match(l:line, '=\s*\zs.*') == -1 || match(l:line, '\S\+\ze\s*=\s*') == -1
        return
    endif
    let l:rhs = trim(matchstr(l:line, '=\s*\zs.*'))
    let l:lhs = trim(matchstr(l:line, '\S\+\ze\s*=\s*'))
    let l:lhs = '\<'.l:lhs.'\>'
    let l:substitute_command = '.+1s/'.l:lhs.'/'.l:rhs.'/'
    try
        " ensure 'undo' is a single command and cursor is at the right position
        execute "normal! i "
        execute "normal! x"
        execute l:substitute_command
    catch
        return
    endtry
    .-1delete
endfunction

nmap <Plug>Inline :call <SID>Inline()<CR>
