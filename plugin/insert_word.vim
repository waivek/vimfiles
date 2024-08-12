
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

" [ref] function! s:LineToWordStartEndTuples(lnum)
function! s:LineToWordStartEndTuples(line)
    " returns a list of tuples, each tuple is of the form (word, [start, end])
    " [ref] let l:line = getline(a:lnum)
    let l:line = a:line
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

function! s:Tokenize(line)
    let l:line = a:line
    " get the starting indices of every character, adjust for multi-byte
    " characters
    let l:indices = []
    let l:idx = 0
    for l:char in split(l:line, '\zs')
        call add(l:indices, l:idx)
        let l:idx += len(l:char)
    endfor
    return l:indices
endfunction

function! s:MapIndexBetweenLines(line1, line2, index1)
    let l:line1 = a:line1
    let l:line2 = a:line2
    let l:index1 = a:index1
    let l:tokens1 = s:Tokenize(l:line1)
    let l:tokens2 = s:Tokenize(l:line2)

    let l:token_index1 = index(l:tokens1, l:index1)
    if l:token_index1 == -1
        let l:token_index1 = l:tokens1[-1]
    endif

    let l:index2 = l:tokens2[l:token_index1]

    " index1, tokens1, tokens2
    " echo printf("index1: %s\ntokens1: %s\ntokens2: %s", string(l:index1), string(l:tokens1), string(l:tokens2))

    return l:index2
endfunction

function! s:DemonstrateIndexMapping()
    " change this to 0, 1, 2 to see different results
    let l:index1 = 1
    let l:line1 = "  hello world"
    let l:line2 = "→ hello world"
    let l:index2 = s:MapIndexBetweenLines(l:line1, l:line2, l:index1)
    let l:subline1 = l:line1[l:index1:]
    let l:subline2 = l:line2[l:index2:]
    echo printf("l:index1: %s\nl:index2: %s", string(l:index1), string(l:index2))
    echo printf("l:subline1: `%s`\nl:subline2: `%s`", l:subline1, l:subline2)
endfunction

function! s:ReplaceMultibyteCharacterWithSpace(line)
    return substitute(a:line, '[^x00-x7F]', ' ', 'g')
endfunction

function! s:InsertWordFromAdjacentLine(current_line, adjacent_line, cursor_index)
    " problem: multibyte characters mess up cursor_index positions of line and adjacent line
    " case 1, we are above / below a space. in this case, we insert spaces until we reach a word start. we simulate this by getting the line, doing a substitute to only preserve the leading spaces and then appending the spaces to the word
    " Don’t Merge the two cases, so that if we ever want to change the behaviour, we simply have to revert to the lines marked [refact]ro
    let l:prefix = ''
    " let l:adjacent_line_without_multibyte = s:ReplaceMultibyteCharacterWithSpace(a:adjacent_line)
    let l:adjacent_line_without_multibyte = a:adjacent_line
    let l:character = l:adjacent_line_without_multibyte[a:cursor_index]
    if l:character =~ '\s'
        " only preserve the leading whitespace
        let l:line_from_character = l:adjacent_line_without_multibyte[a:cursor_index:]
        let l:prefix = substitute(l:line_from_character, '\w.*', '', '')
    endif

    " case 2: we are above a word. in this case, we get the word
    let l:index = len(l:prefix) + a:cursor_index
    " let l:word = s:GetWordOrPartialWord(a:adjacent_line, l:index)
    let l:word = s:GetWordOrPartialWord(l:adjacent_line_without_multibyte, l:index)
    return l:prefix . l:word
endfunction



" imap <expr> <C-y> <SID>InsertWordFromAdjacentLine(getline('.'), getline(line('.') - 1), col('.') - 1)
"
" " → imap <expr> <C-e> <SID>InsertWordFromAdjacentLine(getline('.'), getline(line('.') + 1), col('.') - 1)
" imap <expr> <C-e> <SID>InsertWordFromAdjacentLine(getline('.'), getline(line('.') + 1), col('.') - 1)
