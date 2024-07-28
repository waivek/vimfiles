
" keep track of all `write` commands done to each file inside vim on a
" database file

" we show 10 files to try to guess which file the user is trying to jump to

" file ranking considerations:
" 1. number of writes
" 2. number of writes in the last 1 hour / 1 day / 1 week
" 3. whether the file is loaded in the buffer 
" 4. whether the file is in the current root directory

" Define functions to call the C library
function! OpenDBSqlite(db_name)
    return libcall("/home/vivek/.vim/plugin/database.so", "open_db", a:db_name)
endfunction

function! ExecSQL(sql)
    return libcall("/home/vivek/.vim/plugin/database.so", "exec_sql", a:sql)
endfunction

function! QuerySQL(sql)
    return libcall("/home/vivek/.vim/plugin/database.so", "query_sql", a:sql)
endfunction

function! CloseDB()
    return libcall("/home/vivek/.vim/plugin/database.so", "close_db", "")
endfunction


function! s:LogWriteToDatabase()
    call OpenDBSqlite("test.db")

    " Create a table
    call ExecSQL("CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, value TEXT);")

    " Insert a row
    call ExecSQL("INSERT INTO test (value) VALUES ('Hello, Vim!');")

    " Query the table
    echo QuerySQL("SELECT value FROM test;")

    " Close the database
    call CloseDB()

endfunction

command! LogWriteToDatabase :call s:LogWriteToDatabase()
" call s:LogWriteToDatabase()
