
function! GetWordPositions(line)
    let l:line = a:line
    let words = split(l:line, '\s\+')
    let positions = []
    let start_idx = 0

    for word in words
        let start_idx = match(l:line, '\V' . escape(word, '\'))
        let end_idx = start_idx + len(word) - 1
        call add(positions, [word, [start_idx, end_idx]])
        let l:line = substitute(l:line, '\V' . escape(word, '\'), ' ' . repeat(' ', len(word) - 1), '')
    endfor

    return positions
endfunction

function! s:LineToWordStartEndTuples(lnum)
    " returns a list of tuples, each tuple is of the form (word, [start, end])
    let l:line = getline(a:lnum)
    let l:word_start_end_tuples = GetWordPositions(l:line)
    " assert that tuples are correct
    for l:tuple in l:word_start_end_tuples
        let l:word = l:tuple[0]
        let l:start = l:tuple[1][0]
        let l:end = l:tuple[1][1]
        let l:line_word = l:line[l:start:l:end]
        if l:word != l:line_word
            echoerr 'word_start_end_tuples is incorrect'
            return
        endif
    endfor
    " echoerr string(l:word_start_end_tuples)
    return l:word_start_end_tuples
endfunction

function! s:GetWord(line, index)
    let word_start_end_tuples = s:LineToWordStartEndTuples(a:line)
    let word = ''
    for tuple in word_start_end_tuples
        let l:start = tuple[1][0]
        let l:end = tuple[1][1]
        if l:start <= a:index && a:index <= l:end
            let word = tuple[0]
            break
        endif
    endfor
    return word
endfunction

function! s:GetWordOrPartialWord(line, index)
    let word_start_end_tuples = s:LineToWordStartEndTuples(a:line)
    let word = ''
    let l:start_save = -1
    for tuple in word_start_end_tuples
        let l:start = tuple[1][0]
        let l:end = tuple[1][1]
        if l:start <= a:index && a:index <= l:end
            let word = tuple[0]
            let l:start_save = l:start
            break
        endif
    endfor

    " if index and start aren’t the same, adjust the word
    if l:start_save != -1
        let l:word = word[a:index - l:start_save:]
        return l:word
    endif
    return word
endfunction


function! s:InsertWordFromLineBelowCursor()
    " case 1, we are above / below a space. in this case, we insert spaces until we reach a word start. we simulate this by getting the line, doing a substitute to only preserve the leading spaces and then appending the spaces to the word
    " Don’t Merge the two cases, so that if we ever want to change the behaviour, we simply have to revert to the lines marked [refact]ro
    let l:cursor_index = col('.')-1
    let l:line_below_cursor = getline(line('.') + 1)
    let l:prefix = ''
    let l:charachter = l:line_below_cursor[l:cursor_index]
    if l:charachter =~ '\s'
        let l:line_from_charachter = l:line_below_cursor[l:cursor_index:]
        " only preserve the leading whitespace
        let l:line_from_charachter = substitute(l:line_from_charachter, '\w.*', '', '')
        " [refactor] return l:line_from_charachter
        let l:prefix = l:line_from_charachter
    endif

    " case 2: we are above a word. in this case, we get the word
    " [refactor] let l:index = col('.')-1
    let l:index = len(l:prefix) + col('.')-1
    let l:word = s:GetWordOrPartialWord(line('.') + 1, l:index)
    " [refactor] return l:word
    return l:prefix . l:word
endfunction

function! s:InsertWordFromLineAboveCursor()
    " case 1, we are above / below a space. in this case, we insert spaces until we reach a word start. we simulate this by getting the line, doing a substitute to only preserve the leading spaces and then appending the spaces to the word
    " Don’t Merge the two cases, so that if we ever want to change the behaviour, we simply have to revert to the lines marked [refact]ro
    let l:cursor_index = col('.')-1
    let l:line_above_cursor = getline(line('.') - 1)
    let l:charachter = l:line_above_cursor[l:cursor_index]
    let l:prefix = ''
    if l:charachter =~ '\s'
        let l:line_from_charachter = l:line_above_cursor[l:cursor_index:]
        " only preserve the leading whitespace
        let l:line_from_charachter = substitute(l:line_from_charachter, '\w.*', '', '')
        " [refactor] return l:line_from_charachter
        let l:prefix = l:line_from_charachter
    endif
    " case 2: we are above a word. in this case, we get the word
    " [refactor] let l:index = col('.')-1
    let l:index = len(l:prefix) + col('.')-1
    let l:word = s:GetWordOrPartialWord(line('.') - 1, l:index)
    " [refactor] return l:word
    return l:prefix . l:word
endfunction

imap <expr> <C-e> <SID>InsertWordFromLineBelowCursor()
imap <expr> <C-y> <SID>InsertWordFromLineAboveCursor()
" nnoremap <leader>h :echo <SID>LineToWordStartEndTuples(line('.'))<CR>

