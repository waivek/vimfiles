
" Linux ONLY

function! s:VD(path)
    let path_exists = filereadable(a:path)
    if !path_exists
        echohl WarningMsg
        echomsg 'File does not exist: ' . a:path
        echohl None
        return
    endif

    " Check if a:path is a sqlite database
    let is_sqlite = trim(system('file ' . a:path . ' | grep -c "SQLite"'))
    if is_sqlite == 0
        echohl WarningMsg
        echomsg 'File is not a sqlite database: ' . a:path
        echohl None
        return
    endif

    " Open path in sqlite and check if table exists
    let table_name = fnamemodify(a:path, ':t:r')
    let cmd = 'sqlite3 ' . a:path . ' ".tables"'
    let tables = trim(system(cmd))
    let table_list = split(tables, '\s\+')
    if index(table_list, table_name) == -1
        let command = 'vd ' . a:path
    else
        let command = 'vd ' . a:path . ' ' . table_name
        let command = printf('vd %s +:%s::', a:path, table_name)
    endif
    execute 'vert term ' . command
endfunction

command! -complete=file -nargs=1 VD call s:VD(expand('<args>'))
