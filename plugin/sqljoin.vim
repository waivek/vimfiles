

function! s:JoinCreateTableStatement()
    " Assumption: cursor is on the CREATE TABLE statement
    let start = line('.')
    call search('(')
    normal! %
    let end = line('.')
    execute start . ',' . end . 'join'
endfunction

function! s:SQLJoin()
    execute 'g/CREATE TABLE/SQLJoinCreateTableStatement'
    silent %s/(\s*/(/g
    silent %s/\s*)/)/g
    silent %s/\s*,/,/g
    silent! %s/\s\{2,}/ /g
endfunction

function! s:SQLSplit()
    silent %s/CREATE.*\zs)\ze\s*\(STRICT\)\?\s*;\s*$/\r)
    silent g/^\s*create/s/[(,]\s*\zs\S\+\s*\(INTEGER\|REAL\|TEXT\)/\r    \0/g
    silent %s/,\s*\zs\(FOREIGN\|UNIQUE\)/\r    \0/g
    silent %s/\s*$//g
endfunction

command! SQLJoin call s:SQLJoin()
command! SQLJoinCreateTableStatement call s:JoinCreateTableStatement()

command! SQLSplit call s:SQLSplit()
