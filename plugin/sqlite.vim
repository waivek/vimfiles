let s:sep = has("win32") || has("win64") ? "\\" : "/"

function! s:EchoWarning(msg)
    echohl WarningMsg | echom a:msg | echohl None
endfunction

function! s:IsSqlFile()
    let extension = expand("%:e")
    if extension != 'sql'
        call s:EchoWarning("Not a sql file: " . expand("%:p"))
        return 0
    endif
    return 1
endfunction

function! s:FileReadable(path)
    if !filereadable(a:path)
        call s:EchoWarning("Database file not found: " . a:path)
        return 0
    endif
    return 1
endfunction

function! s:IsSQLiteDatabase(path)
    let is_sqlite = trim(system('file ' . a:path . ' | grep -c "SQLite"'))
    if is_sqlite == 0
        call s:EchoWarning("File is not a sqlite database: " . a:path)
        return 0
    endif
    return 1
endfunction

function! s:OpenDbWithPath(path)
    if !s:FileReadable(a:path) || !s:IsSQLiteDatabase(a:path)
        return
    endif
    let command = "sqlite3 " . a:path
    " above command but make it interactive
    " sqlite3 /home/vivek/hateoas/data/main.db -cmd .schema
    execute "vert term " . command
endfunction

function! s:OpenDbWithoutPath()
    if !s:IsSqlFile()
        return
    endif
    let db_name = expand("%:t:r")
    let cwd = fnamemodify(expand("%:p"), ":h")
    let db_path_1 = cwd . s:sep . db_name . ".db"
    let db_path_2 = cwd . s:sep . "data" . s:sep . db_name . ".db"
    let db_exists = filereadable(db_path_1) || filereadable(db_path_2)

    if !db_exists
        call s:EchoWarning("Database file not found: " . db_path_1)
        call s:EchoWarning("Database file not found: " . db_path_2)
        return
    endif
    let db_path = filereadable(db_path_1) ? db_path_1 : db_path_2
    call s:OpenDbWithPath(db_path)
endfunction

function OpenDB(...)
    if a:0 == 0
        call s:OpenDbWithoutPath()
    elseif a:0 == 1
        call s:OpenDbWithPath(a:1)
    else
        echohl ErrorMsg
        echom "Invalid number of arguments"
        echohl None
    endif
endfunction

" OpenDB -> Calls OpenDbWithoutPath()
" OpenDB <path> -> Calls OpenDbWithPath(<path>)

command! -nargs=* -complete=file OpenDB call OpenDB(<f-args>)

