function! s:PrintDomVariable()
    let reg_save = @"
    normal! gvy

    let print_fmt = 'console.log("variable_name:");console.log(variable_name);'
    let @" = substitute(print_fmt, "variable_name", @", "g")

    normal! o"
    normal! ^
    let @" = reg_save
endfunction
function! s:PrintJavaScriptVariable()
    let reg_save = @"
    normal! gvy
    if match(@", ",") > -1
        let @" = trim(@")
        let print_fmt = 'console.log("variable_names : " + join_command);'
        let list_join_command = "[" . @" . "].join(', ')"
        let variable_name_string = "(" . @" . ")"
        let print_fmt = substitute(print_fmt, "variable_names", variable_name_string, "g")
        let print_fmt = substitute(print_fmt, "join_command", list_join_command, "g")
        let @"=print_fmt
    else
        let print_fmt = 'console.log("variable_name: " + variable_name);'
        let @" = substitute(print_fmt, "variable_name", @", "g")
    endif
    normal! o"
    normal! ^
    let @" = reg_save
endfunction
vnoremap z :<c-u>call <SID>PrintJavaScriptVariable()<CR>
vnoremap Z :<c-u>call <SID>PrintDomVariable()<CR>

" nnoremap <buffer> <silent> ) :call search("^function")<CR>
" nnoremap <buffer> <silent> ( :call search("^function", "b")<CR>

function! s:RemoveTemplateStrings()
    s/\${\([^}]*\)}/" + \1 + "/g
    s/`/"/g
endfunction
function! s:AddTemplateStrings()
    s/"\s*+\s*\([^"][^ +]*\)\s*+\s*"/${\1}/g
    s/"/`/g
endfunction

" ASSUMPTIONS -
" 1. in non-template string, the double-quote (") is used for strings
" 2. the backtick (`) only occurs as a representation of template strings and nowhere else
function! s:ToggleTemplateStrings()
    let current_line = getline(".")
    let is_template_string = stridx(current_line, "`") > -1
    if is_template_string
        call s:RemoveTemplateStrings()
    else
        call s:AddTemplateStrings()
    endif
endfunction
function! s:Timeout()
endfunction
command! RemoveTemplateStrings call s:RemoveTemplateStrings()
command! AddTemplateStrings call s:AddTemplateStrings()
command! ToggleTemplateStrings call s:ToggleTemplateStrings()
nnoremap  <silent> <buffer> g' :call <SID>ToggleTemplateStrings()<CR>
