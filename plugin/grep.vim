

function! s:GetGreppablePaths(regex, excludes)
    let regex = a:regex
    let excludes = a:excludes
    let paths = filter(copy(v:oldfiles), 'v:val =~? regex')
    call filter(paths, { _, path -> filereadable(expand(path)) })
    for exclude in excludes
        call filter(paths, { _, path -> stridx(tolower(path), exclude) == -1})
    endfor
    call map(paths, { _, path -> '"'.expand(path).'"'})
    return paths
endfunction

function! s:Grep(key, paths)
    let key = a:key
    let paths = a:paths
    let path_string = join(paths, " ")
    let filepath = tempname()
    let directory = fnamemodify(filepath, ":h")
    " let quickfix_filepath = 'C:\Users\vivek\AppData\Local\Temp\result.txt'
    let quickfix_filepath = expand(directory . '/result.txt')
    call writefile(paths, filepath)
    echom "filepath: " . filepath
    let rush_command = printf('rush -i %s --keep-order "rg --vimgrep %s {}" > %s', filepath, key, quickfix_filepath)

    echo "Searching " . len(paths) . " files"
    call system(rush_command)
    execute "cfile " .  quickfix_filepath
    redraw
    let match_count = len(getqflist())
    echo printf("%d Matches", match_count)
endfunction

function! s:VueGrep(key)
    let regex = '\.vue$'
    let excludes = [ 'undofiles' ]
    let s:vue_paths = empty(s:vue_paths) ? s:GetGreppablePaths(regex, excludes) : s:vue_paths
    call s:Grep(a:key, s:vue_paths)
endfunction

function! s:PyGrep(key)
    let regex = '\.py$'
    let excludes = [ 'appdata', 'program files', 'undofiles' ]
    let s:python_paths = empty(s:python_paths) ? s:GetGreppablePaths(regex, excludes) : s:python_paths
    call s:Grep(a:key, s:python_paths)
endfunction

function! s:VimGrep(key)
    let regex = '\.vim$\|vimrc$'
    let excludes = [ 'plugged', 'pack' ]
    let s:vim_paths = empty(s:vim_paths) ? s:GetGreppablePaths(regex, excludes) : s:vim_paths
    call s:Grep(a:key, s:vim_paths)
endfunction

let s:python_paths = []
let s:vim_paths = []
let s:vue_paths = []

command! -nargs=1 PyGrep call s:PyGrep(<q-args>)
command! -nargs=1 VimGrep call s:VimGrep(<q-args>)
command! -nargs=1 VueGrep call s:VueGrep(<q-args>)

