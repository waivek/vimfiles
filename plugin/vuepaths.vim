

let s:paths = [ { "os": "linux", "working_dir": "~/frontend" } ]

function! s:IsVueProject()
    let file_parent = expand('%:p:h')
    let vite_path = findfile('vite.config.ts', file_parent . ';')
    let project_root_exists = !empty(vite_path)
    return project_root_exists
endfunction

function! s:FindVueProjectRoot()
    let file_parent = expand('%:p:h')
    let vite_path = findfile('vite.config.ts', file_parent . ';')
    let project_root_exists = !empty(vite_path)
    let project_root = fnamemodify(vite_path, ':h')
    return project_root
endfunction

function! s:MakePathArray()
    let project_root = s:FindVueProjectRoot()
    let path_array = [ '.', project_root, project_root . '/src', project_root . '/src/components' ]
    let path_string = join(path_array, ',')
    return path_string
endfunction

function! s:SetVuePathLocal()
    if !s:IsVueProject()
        return
    endif
    let path_string = s:MakePathArray()
    let &l:path = path_string
endfunction
" command! A call s:SetVuePathLocal()

augroup vue
    autocmd!
    autocmd BufEnter * call s:SetVuePathLocal()
augroup END


" function! NuxtLocalPath()
"     setlocal path+=pages
"     setlocal path+=components
"     setlocal path+=server/api
" endfunction
" command! NuxtLocalPath call NuxtLocalPath()
