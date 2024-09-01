
function! s:GetTodoPathIfExists()
    let l:root = findfile('todo.txt', expand('%:p:h') . ';')
    if l:root == ''
        return ''
    endif
    return fnamemodify(l:root, ':p')
endfunction

function! s:OpenTodoIfExists()
    let l:todo_path = s:GetTodoPathIfExists()
    if l:todo_path == ''
        echo 'No todo.txt found'
        return
    endif
    execute 'edit ' . l:todo_path
endfunction

nmap <Plug>(OpenTodoIfExists) :call <SID>OpenTodoIfExists()<CR>
