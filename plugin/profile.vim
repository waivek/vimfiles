
function! s:AscendingSortByKeyPriority(lhs, rhs)
    let keys = s:keys
    let lhs = a:lhs
    let rhs = a:rhs
    for key in keys
        if lhs[key] > rhs[key]
            return 1
        elseif lhs[key] < rhs[key]
            return -1
        endif
    endfor
    return 0
endfunction
function! s:DescendingSortByKeyPriority(lhs, rhs)
    let keys = s:keys
    let lhs = a:lhs
    let rhs = a:rhs
    for key in keys
        if lhs[key] < rhs[key]
            return 1
        elseif lhs[key] > rhs[key]
            return -1
        endif
    endfor
    return 0
endfunction
let s:keys = []
function! s:SortDictionaries(dictionaries, keys, direction="ASC")
    let dictionaries = a:dictionaries
    let keys = a:keys
    let direction = a:direction

    let s:keys = keys
    if direction ==# "ASC"
        call sort(dictionaries, function('s:AscendingSortByKeyPriority'))
    elseif direction ==# "DESC"
        call sort(dictionaries, function('s:DescendingSortByKeyPriority'))
    endif
    return dictionaries
endfunction

let s:my_dictionaries = [   { "letter" : "b", "number": 5 },
                          \ { "letter" : "a", "number": 4},
                          \ { "letter" : "e", "number": 3},
                          \ { "letter" : "c", "number": 2, "age": 10 },
                          \ { "letter" : "c", "number": 2, "age": 20 },
                          \ { "letter" : "d", "number": 1}
                          \ ]

" call s:SortDictionaries(s:my_dictionaries, ['number', 'age'], 'DESC')
" for D in s:my_dictionaries
"     echo string(D)
" endfor

function! s:IncrementWithPadding(number_string)
    return cacx#PadIfReqd(a:number_string, str2nr(a:number_string) + 1)
endfunction
function! s:IncrementFilename(filename)
    return substitute(a:filename, '^.*v\zs\(\d\+\)\ze.*$', '\=s:IncrementWithPadding(submatch(1))', "")
endfunction
function! s:IsValidProfileFilename(filename)
    return match(a:filename, '^2\d\d\d\d\d\.[a-zA-Z_]\+\.v\d\+\.txt') == 0
endfunction
function! s:GetProfileFileDictionaries()
    let files = split(glob('~/vimfiles/performance/*.txt'), "\n")
    let l:now = localtime()
    let file_dictionaries = map(files, { _, file -> { "filename": fnamemodify(file, ":t"), "m_timeago": l:now-getftime(file) } })
    call filter(file_dictionaries, { _, D -> s:IsValidProfileFilename(D["filename"]) })
    return file_dictionaries
endfunction
function! s:ProfileCompletion(ArgLead, CmdLine, CursorPos)
    let date_filename = printf("%s.", strftime("%y%m%d"))
    let files = split(glob('~/vimfiles/performance/*.txt'), "\n")
    let dictionaries = s:GetProfileFileDictionaries()
    call s:SortDictionaries(dictionaries, [ "filename" ])
    let stack = [ dictionaries[0] ]
    for D in dictionaries
        let previous_key = substitute(stack[-1]["filename"], '^\(2\d\d\d\d\d\.[a-zA-Z_]\+\)\.v\d\+\.txt', '\=submatch(1)', "")
        let current_key = substitute(D["filename"], '^\(2\d\d\d\d\d\.[a-zA-Z_]\+\)\.v\d\+\.txt', '\=submatch(1)', "")
        if previous_key ==# current_key
            let stack[-1] = D
        else
            call add(stack, D)
        endif
    endfor
    let latest_dictionaries = stack
    call s:SortDictionaries(latest_dictionaries, [ "m_timeago" ])
    let version_incremented_filenames = map(copy(latest_dictionaries), { _, D -> s:IncrementFilename(D["filename"]) })
    if len(trim(a:ArgLead)) > 0
        let key = trim(tolower(a:ArgLead))
        call filter(version_incremented_filenames, { _, filename -> match(tolower(filename), key) > -1 })
        return version_incremented_filenames
    else
        return [ date_filename ] + version_incremented_filenames
    endif
endfunction

function! s:ProfileFunction(profile_filename)
    let profile_filename = a:profile_filename
    if !s:IsValidProfileFilename(profile_filename)
        echohl WarningMsg | echo 'Filename '.profile_filename.' does not match format: "{date}.{title}.{version}.txt"' | echohl Normal
        return
    endif
    let command = printf('profile start ~/vimfiles/performance/%s | profile func * | profile file *', profile_filename)
    execute command
    echo command
endfunction

command! -complete=customlist,s:ProfileCompletion -nargs=? Profile call s:ProfileFunction("<args>")
