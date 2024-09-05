
" Filetype plugin for TODO files

" Set the syntax highlighting to use the custom TODO syntax

" check if extension is vim
if expand('%:e') != 'vim'
    setlocal syntax=todo

    " Additional settings for TODO files
    setlocal commentstring=#\ %s
endif

" function to toggle ✓ at the start of the line
function s:ToggleDone()
    let l:line = getline('.')
    let on_line_end = col('.') == len(l:line)
    let line_starts_with_tick = match(l:line, '✓') == 0
    let old_line_length = len(l:line)
    if line_starts_with_tick
        " remove tick and spaces after tick
        " [old]
        " let l:line = substitute(l:line, '✓\s*', '', '')

        " replace the first tick of the line with a space
        " [new]
        let l:line = substitute(l:line, '✓', ' ', '')
    else
        " add tick and space after tick
        " [old]
        " let l:line = '✓ ' . l:line

        " replace the first space of the line with a tick
        " [new]
        let l:line = substitute(l:line, ' ', '✓', '')
    endif
    call setline('.', l:line)
    let new_line_length = len(l:line)
    " restore cursor position
    let l:diff = new_line_length - old_line_length
    if on_line_end
        " place cursor at end
        call cursor(0, new_line_length)
    else
        call cursor(0, col('.') + l:diff)
    endif

endfunction

function! s:ToggleDoneRange()
    " Get the start and end line numbers of the visual selection
    let l:start_line = line("'<")
    let l:end_line = line("'>")

    " Loop through each line in the range
    for l:line_number in range(l:start_line, l:end_line)
        " Move the cursor to the current line
        call cursor(l:line_number, 1)

        " Call the ToggleDone function
        call s:ToggleDone()
    endfor
endfunction

" Map the visual mode key to call the function
vnoremap <buffer> <tab> :<C-u>call <SID>ToggleDoneRange()<CR>
" Map <tab> to toggle the done status of the current line on normal mode
nnoremap <buffer> <tab> :call <SID>ToggleDone()<CR>

function! s:FindAllMatches(string, pattern)
    " takes a string and a pattern, returns a list of dictionaries which is of
    " the format:
    "
    "   { value, start, end }
    "
    " We use a needle, where once we get a match we skip the needle the length
    " of the match, to avoid submatches polluting the list

    let l:matches = []
    let l:needle = 0
    while l:needle < strlen(a:string)
        let l:match = matchstr(a:string, a:pattern, l:needle)
        if l:match == ''
            break
        endif
        let l:start = match(a:string, a:pattern, l:needle)
        let l:end = l:start + strlen(l:match)
        call add(l:matches, {'value': l:match, 'start': l:start, 'end': l:end})
        let l:needle = l:end
    endwhile
    return l:matches
endfunction


function! s:HighlightExistingFiles()
    if hlexists('ExistingFile')
        " clear the syntax group
        syntax clear ExistingFile
    endif
    " let l:file_pattern = '\v\S+\.\w+'
    let l:file_pattern = '\v\f+\.\w+'
    for l:line in getline(1, '$')
        let l:matches = s:FindAllMatches(l:line, l:file_pattern)
        " echoerr "Matches: " . string(l:matches)
        if !empty(l:matches)
            for l:match in l:matches
                let l:file = l:match.value
                if filereadable(l:file)
                    let l:escaped_file = escape(l:file, '.')
                    let l:command = 'syntax match ExistingFile /' . l:escaped_file . '/'
                    execute l:command
                endif
            endfor
        endif
    endfor
endfunction

augroup FileHighlighting
    autocmd!
    autocmd BufEnter *.todo setlocal filetype=todo
    autocmd Syntax todo call s:HighlightExistingFiles()
augroup END
