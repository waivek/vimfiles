function! PrintPythonVariable()
    let print_fmt = 'print("variable_name: %s" % (variable_name))'
    let reg_save = @a
    normal! gv"ay
    let @a = substitute(print_fmt, "variable_name", @a, "g")
    normal! oa
    normal! ^
    let @a = reg_save
endfunction
vnoremap z :<c-u>call PrintPythonVariable()<CR>
