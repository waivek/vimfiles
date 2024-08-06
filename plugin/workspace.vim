
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
        \ '~/sqlite-editor'     : [ '~/sqlite-editor/static/css' ],
        \ '~/hateoas'           : [ '~/hateoas/static/css' , '~/hateoas/templates/**'],
        \ '~/ui-components-css' : [ '~/ui-components-css/static/**', '~/ui-components-css/templates/**' ],
        \ '~/python_common'     : [ '~/python_common/waivek/**', '~/python_common/examples/**' ]
        \ }
    " run s:ExpandUser on l:directories_to_paths
    for l:directory in keys(l:directories_to_paths)
        let l:paths = l:directories_to_paths[l:directory]
        call remove(l:directories_to_paths, l:directory) " delete the old key
        let l:directories_to_paths[fnamemodify(l:directory, ':p')] = mapnew(l:paths, {_, v -> fnamemodify(v, ':p') }) " add the new key
    endfor



    " call utils#print_tuple_table(items(l:directories_to_paths))
    " for l:directory in keys(l:directories_to_paths)
    "     echo printf("%s: %s", l:directory, l:directories_to_paths[l:directory])
    " endfor


    let l:candidates = s:SetPaths(keys(l:directories_to_paths))
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
    au DirChanged * call s:DirChangedOrFileLoaded()
augroup END


if v:vim_did_enter
    " call s:DirChangedOrFileLoaded()
    Capture call s:DirChangedOrFileLoaded()
endif
