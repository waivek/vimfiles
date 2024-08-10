
let s:script_dir = expand('<sfile>:p:h')

" make -pn | grep 'LIB_NAME =' | awk '{print $3}'
let s:shell_command = "make -pn | grep 'LIB_NAME =' | awk '{print $3}'"
let s:library_name = trim(system(s:shell_command))

let s:library_path = join([s:script_dir, s:library_name], '/')
if !filereadable(s:library_path)
    echo "Library not found: " . s:library_path
    finish
endif

function! ExecuteQuery(db_path, query)
    let result = libcall(s:library_path, "execute_query", a:db_path . "\n" . a:query)
    return result
endfunction

function! DropTable(db_path)
    let query = "DROP TABLE IF EXISTS users;"
    echo ExecuteQuery(a:db_path, query)
endfunction

function! CreateTable(db_path)
    let query = "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, name TEXT, email TEXT);"
    echo ExecuteQuery(a:db_path, query)
endfunction

function! InsertData(db_path, name, email)
    let query = "INSERT INTO users (name, email) VALUES ('" . a:name . "', '" . a:email . "');"
    echo ExecuteQuery(a:db_path, query)
endfunction

function! SelectData(db_path)
    let query = "SELECT * FROM users;"
    return ExecuteQuery(a:db_path, query)
endfunction

command! -nargs=1 CreateTable call CreateTable(<f-args>)
command! -nargs=+ InsertData call InsertData(<f-args>)
command! -nargs=1 SelectData call SelectData(<f-args>)

function! s:WriteToSTDOUT(string)
    let l:echo_friendly_string = substitute(a:string, '\n', '\\n', 'g')
    execute "!echo " . l:echo_friendly_string
endfunction

try
    let db_path = "test.db"

    " Create the table
    call DropTable(db_path)
    call CreateTable(db_path)

    " Insert some data
    call InsertData(db_path, "John Doe", "john.doe@example.com")
    call InsertData(db_path, "Jane Smith", "jane.smith@example.com")

    " Select and display the data
    let result = SelectData(db_path)

    " Expected data for comparison
    let expected = "id = 1\nname = John Doe\nemail = john.doe@example.com\n\nid = 2\nname = Jane Smith\nemail = jane.smith@example.com\n\n"

    " Compare the results
    if result != expected
        call s:WriteToSTDOUT(printf("Test failed: Expected %s but got %s", expected, result))
        let pass_path = 'pass.txt'
        let pass_lines = split(result, '\n')
        call writefile(pass_lines, pass_path)
        let fail_path = 'fail.txt'
        let fail_lines = split(expected, '\n')
        call writefile(fail_lines, fail_path)
        call s:WriteToSTDOUT("Results written to " . pass_path . " and " . fail_path)
    else
        call s:WriteToSTDOUT("Test passed")
    endif

catch
    call s:WriteToSTDOUT("An error occurred: " . v:exception)
endtry
