function! s:CustomComplete(ArgLead, CmdLine, CursorPos)
    let l:basename = expand("%:t")
    let l:candidates = [l:basename]
    return l:candidates
endfunction

function! s:Rename(new_name)
    if match(a:new_name, '^\(\f\| \)\+$') == -1
        echohl WarningMsg | echo "Invalid File Name: ".a:new_name | echohl Normal
    endif
    let old_path = expand("%:p")
    let curdir = expand("%:p:h")
    let new_path = expand(curdir."/".a:new_name)

    let old_undofile = undofile(old_path)
    let new_undofile = undofile(new_path)
    if has('win32') || has('win64')
        let old_undofile = substitute(old_undofile, '/vimfiles/undofiles\', '/vimfiles/undofiles/', '')
        let new_undofile = substitute(new_undofile, '/vimfiles/undofiles\', '/vimfiles/undofiles/', '')
    endif
    let undofile_exists = filereadable(old_undofile)
    call rename(old_path, new_path)
    if undofile_exists
        call rename(old_undofile, new_undofile)
    endif
    execute "edit ".new_path
    bd #
    " This is required to update the value of expand("%")
endfunction
" command -complete=file -nargs=1 Rename call  s:Rename(<q-args>)
command -complete=customlist,s:CustomComplete -nargs=1 Rename call  s:Rename(<q-args>)
