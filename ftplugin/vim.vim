function PrintVimVariable()
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

vnoremap <silent> z :<c-u>call PrintVimVariable()<CR>

