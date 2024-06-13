
" upon editing a file / cd'ing into a directory, set the path if parent
" matches a list of predefined strings
function! s:ExpandUser(path)
    return fnamemodify(a:path, ':p')
endfunction
function! s:SetPaths(paths)
    let l:expanded_paths = [] " expand '~' in a:paths
    for l:path in a:paths
        call add(l:expanded_paths, s:ExpandUser(l:path))
    endfor
    return l:expanded_paths
endfunction

function! s:ChooseCandidate(candidates)
    let l:current_path = expand('%:p')
    for l:candidate in a:candidates
        let l:current_path_starts_with_candidate = stridx(l:current_path, l:candidate) == 0
        if l:current_path_starts_with_candidate
            return l:candidate
        endif
    endfor
    return ''
endfunction

function! s:DirChangedOrFileLoaded()
    let l:directories_to_paths = {
        \ '~/sqlite-editor': [ '~/sqlite-editor/static/css' ],
        \ '~/hateoas': [ '~/hateoas/static/css' ],
        \ '~/ui-components-css': [ '~/ui-components-css/static/**', '~/ui-components-css/templates/**' ]
        \ }
    " run s:ExpandUser on l:directories_to_paths
    for l:key in keys(l:directories_to_paths)
        let l:value = l:directories_to_paths[l:key]
        let l:expanded_value = s:SetPaths(l:value)
        " delete the old key
        call remove(l:directories_to_paths, l:key)
        " add the new key
        let l:directories_to_paths[s:ExpandUser(l:key)] = l:expanded_value
    endfor

    let l:candidates = s:SetPaths(keys(l:directories_to_paths))
    let l:current_dir = fnamemodify(expand('%:p:h'), ':p')
    let l:candidate = s:ChooseCandidate(l:candidates)
    if l:candidate == ''
        return
    endif
    let l:paths = l:directories_to_paths[l:candidate]
    " reset path
    setlocal path=.,
    for l:path in l:paths
        let l:full_path = s:ExpandUser(l:path)
        " set local path
        execute 'setlocal path+=' . l:full_path
    endfor
endfunction

" echo s:SetPaths(['~/sqlite-editor', '~/sqlite-editor/static/css'])
" call s:DirChangedOrFileLoaded()

augroup Workspace
    au!
    au BufEnter * call s:DirChangedOrFileLoaded()
    " au BufWritePost * call s:DirChangedOrFileLoaded()
    " au BufReadPost * call s:DirChangedOrFileLoaded()
    au DirChanged * call s:DirChangedOrFileLoaded()
augroup END


