function! PrintVimSelection()
    let reg_save = @"
    normal! gvy
    if match(@", ",") > -1
        let @" = trim(@")
        " let print_fmt = 'console.log("variable_names : " + join_command);'
        " let list_join_command = "[" . @" . "].join(', ')"
        let print_fmt = 'echo "variable_names: " . join_command'
        let list_join_command = printf("join([%s], ', ')", @")
        let variable_name_string = "(" . @" . ")"
        let print_fmt = substitute(print_fmt, "variable_names", variable_name_string, "g")
        let print_fmt = substitute(print_fmt, "join_command", list_join_command, "g")
        let @"=print_fmt
    else
        let print_fmt = 'echo "variable_name: " . string(variable_name)'
        let @" = substitute(print_fmt, "variable_name", @", "g")
    endif
    normal! o"
    normal! ^
    let @" = reg_save
endfunction

" TESTS:
function! Test()
    " col(".")
    echo 'col("."): ' . (type(col(".")) == v:t_string ? col(".") : string(col(".")))

    " col("'<")
    echo 'col("''<"): ' . (type(col("'<")) == v:t_string ? col("'<") : string(col("'<")))

    " col("'>")
    echo 'col("''>"): ' . (type(col("'>")) == v:t_string ? col("'>") : string(col("'>")))

    let x = 2
    echo 'x: ' . (type(x) == v:t_string ? x : string(x))

    let L = [1, 2, 3]
    echo 'L: ' . (type(L) == v:t_string ? L : string(L))

    let D = {"a": "b", "c" : "d"}
    echo 'D: ' . (type(D) == v:t_string ? D : string(D))

endfunction

function! Escape()
    
    let reg_save = @"
    normal! gvy
    let selection = @"
    let selection_escaped = substitute(selection, "'", "''", "g")
    " let print_fmt = printf('echo ''%s: '' . %s', selection, selection)
    let print_fmt = printf('echo ''%s: '' . (type(%s) == v:t_string ? %s : string(%s))', selection_escaped,  selection, selection, selection)
    let @" = print_fmt
    normal! o"
    normal! ^

    let @" = reg_save
endfunction
xnoremap <Space>z :<c-u>call Escape()<CR>

" iabbrev <buffer> time_taken time_taken = string(s:Time() - start_time)
function! s:TestFunction1()
endfunction
function! s:TestFunction2(filename)
endfunction
function! s:TestFunction3(filename, word)
endfunction
function! s:TestFunction4(filename, word, position=5)
endfunction


function! s:ExtractArguments()
    function! s:RemoveDefaultAssignments(arg_string)
        let arg_string = a:arg_string
        let equal_index = stridx(arg_string, "=")
        if equal_index > -1
            return strpart(arg_string, 0, equal_index)
        endif
        return arg_string

    endfunction
    let line = trim(getline("."))
    if stridx(line, "function! ") == -1
        return
    endif
    let signature = substitute(line, '^\s*function!.*\w\+(\(.*\))', '\=submatch(1)', "")
    let signatures = split(signature, ",")
    if len(signatures) == 0
        return
    endif
    call map(signatures, { _, signature -> substitute(trim(signature), '=.*', '', '')})
    let assignments = map(copy(signatures), { _, variable_name -> printf('let %s = a:%s', trim(variable_name), trim(variable_name)) })
    let @" = join(assignments, "\n")
    put=@"
    normal! `[v`]=

endfunction
command! ExtractArguments call <SID>ExtractArguments()
