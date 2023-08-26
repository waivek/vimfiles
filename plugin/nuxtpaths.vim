
let s:paths = [ { "os": "linux", "working_dir": "~/tsnuxt" } ]

function s:SetPath()
    for path in s:paths
        let os = path["os"]
        let working_dir = path["working_dir"]
    endfor
endfunction

function! s:IsInsideNuxtProject()
    let file_parent = expand('%:p:h')
    let l:nuxt_dir = finddir('.nuxt', file_parent . ';')
    let l:components_dir = finddir('components', file_parent . ';')
    let value = !empty(l:nuxt_dir) && (l:nuxt_dir != '.') && !empty(l:components_dir) && (l:components_dir != '.')
    return value
endfunction
command! IsInsideNuxtProject call s:IsInsideNuxtProject()


function! NuxtLocalPath()
    setlocal path+=pages
    setlocal path+=components
    setlocal path+=server/api
endfunction
command! NuxtLocalPath call NuxtLocalPath()
