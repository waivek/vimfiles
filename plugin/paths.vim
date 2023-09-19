" NOTE: `findfile` can return a relative path or an absolute path

function! s:IsVimrc()
    let vimrc_path = expand('$MYVIMRC')
    let vimrc_dir = fnamemodify(vimrc_path, ':h')
    let current_file_full_path = expand('%:p')
    return stridx(current_file_full_path, vimrc_dir) == 0
endfunction

function! s:MakeVimPathString()
    let project_root = fnamemodify(expand('$MYVIMRC'), ':h')
    let path_array = [ '.', project_root, project_root . '/plugin', project_root . '/colors' ]
    let path_string = join(path_array, ',')
    return path_string
endfunction

function! s:SetVimPathLocal()
    let &l:path = s:MakeVimPathString()
endfunction

" set path+=~/Python/waivek/waivek
function! s:PathSpecficSettings()
    let working_directory = getcwd()
    if working_directory ==# glob('~/Desktop/website')
        let &path='.,,fonts/**,css/**'
    elseif working_directory ==# glob('~/vimfiles')
        let &path='.,,plugin/,colors/'
    else
        " set path&
        " set path+=~/Python/waivek/waivek
    endif
endfunction

function! s:IsVueProject()
    return !empty(findfile('vite.config.ts', '.;'))
endfunction

function! s:FindVueProjectRoot()
    let vite_path = findfile('vite.config.ts', '.;')
    if !isabsolutepath(vite_path)
        let vite_path = fnamemodify(vite_path, ':p')
    endif
    let project_root = fnamemodify(vite_path, ':h')
    return project_root
endfunction

function! s:MakeVuePathString()
    let project_root = s:FindVueProjectRoot()
    let path_array = [ '.', project_root, project_root . '/src', project_root . '/src/components' ]
    let path_string = join(path_array, ',')
    return path_string
endfunction

function! s:SetVuePathLocal()
    if !s:IsVueProject()
        return
    endif
    let path_string = s:MakeVuePathString()
    let &l:path = path_string
endfunction

function! s:SetPathLocal()
    if s:IsVueProject()
        call s:SetVuePathLocal()
    elseif s:IsVimrc()
        call s:SetVimPathLocal()
    endif
endfunction

augroup vue
    autocmd!
    autocmd BufEnter * call s:SetPathLocal()
    autocmd DirChanged * call s:SetPathLocal()
augroup END


augroup VimrcPathSpecificSettings
    au!
    " au DirChanged * call s:PathSpecficSettings()
augroup END

