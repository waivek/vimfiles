
function! s:Rename(new_name)
    if match(a:new_name, '^\(\f\| \)\+$') == -1
        echohl WarningMsg | echo "Invalid File Name: ".a:new_name | echohl Normal
    endif
    let old_path = expand("%:p")
    let curdir = expand("%:p:h")
    let new_path = expand(curdir."/".a:new_name)
    call rename(old_path, new_path)
    execute "edit ".new_path
    bd #

    " This is required to update the value of expand("%")
endfunction
command -complete=file -nargs=1 Rename call <SID>Rename(<q-args>)
