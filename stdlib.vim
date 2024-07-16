
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


function! s:YankVisualSelection()
     
    " SAVE (start)
    let reg_save = @"
    let visual_start_save = getpos("'<") " ? Optional ? 
    let visual_end_save   = getpos("'>") " ? Optional ?
    let paste_start_save  = getpos("'[")
    let paste_end_save    = getpos("']")
    " SAVE (end)

    silent normal! yiw
    let yanked_word = @"

    " RESTORE (start)
    let @" = reg_save
    call setpos("'<", visual_start_save)
    call setpos("'>", visual_end_save)
    call setpos("'[", paste_start_save)
    call setpos("']", paste_end_save)
    " RESTORE (end)

    return yanked_word

endfunction
