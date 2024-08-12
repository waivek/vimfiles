
function! s:VisualLength(string)
    let l:string = a:string
    " get the length of characters where multi-byte characters are counted as 1
    return strchars(l:string)
endfunction

function! s:DemonstrateVisualLength()
    let l:word = "あいうえお"
    echo s:VisualLength(l:word)
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

function! s:IsValidIndex(string, index)
    let l:string = a:string
    let l:index = a:index
    let l:tokens = s:Tokenize(l:string)
    let l:valid = index(l:tokens, l:index) != -1
    if l:valid
        return v:true
    else
        return v:false
    endif
endfunction

function! s:PruneInsertString(insert_string)
    " we take insert_string, then first match whitespaces then non whitespaces
    " and then whitespaces again. we remove everything after this point.
    let l:insert_string = a:insert_string
    let l:pattern = '\s*\S\+\zs.*'
    let l:pruned_string = substitute(l:insert_string, l:pattern, '', '')
    return l:pruned_string
endfunction

function! s:GetInsertString(current_line, adjacent_line, current_index)
    let l:current_line = a:current_line

    let l:adjacent_line = a:adjacent_line
    let l:current_index = a:current_index
    if s:DEBUG
        echo printf("current_line: `%s`\nadjacent_line: `%s`\ncurrent_index: %s", l:current_line, l:adjacent_line, l:current_index)
    endif
    let l:current_line_left = strpart(l:current_line, 0, l:current_index)
    " let l:current_line_left = l:current_line[0:l:current_index]
    let l:adjacent_index = 0
    let l:loop_guard = 1000
    while v:true
        let l:string1 = l:current_line_left
        let l:len1 = s:VisualLength(l:string1)

        let l:string2 = strpart(l:adjacent_line, 0, l:adjacent_index)
        let l:len2 = s:VisualLength(l:string2)

        " echo printf("(length=%s) string1=`%s`", l:len1, l:string1)
        " echo printf("(length=%s) string2=`%s`", l:len2, l:string2)
        " echo "\n"
        if l:len1 == l:len2
            if s:IsValidIndex(l:adjacent_line, l:adjacent_index)
                break
            endif
        endif
        if l:adjacent_index == len(l:adjacent_line)
            if s:DEBUG
                echo "adjacent_index is reached the end of the line"
            endif
            break
        endif

        let l:adjacent_index += 1
        if l:loop_guard == 0
            " echoerr printf("loop_guard is reached: %s", l:loop_guard)
            echoerr printf("loop_guard is reached: %s", l:loop_guard)
            break
        endif
        let l:loop_guard -= 1
    endwhile
    if s:DEBUG
        echo "\n"
        echo printf("current_index : %s\nadjacent_index: %s", l:current_index, l:adjacent_index)
        echo printf("(length=%s)current_line_left : `%s`\n(length=%s)adjacent_line_left: `%s`", s:VisualLength(l:current_line_left), l:current_line_left, s:VisualLength(strpart(l:adjacent_line, 0, l:adjacent_index)), strpart(l:adjacent_line, 0, l:adjacent_index))
    endif
    let l:insert_string = strpart(l:adjacent_line, l:adjacent_index, len(l:adjacent_line))
    let l:pure_insert_string = s:PruneInsertString(l:insert_string)
    if s:DEBUG
        echo printf("insert_string: `%s`\npure_insert_string: `%s`", l:insert_string, l:pure_insert_string)
    endif
    return l:pure_insert_string

endfunction

imap <silent> <expr> <C-y> <SID>GetInsertString(getline('.'), getline(line('.') - 1), col('.')-1)
imap <silent> <expr> <C-e> <SID>GetInsertString(getline('.'), getline(line('.') + 1), col('.')-1)

" ~/.vim/tmp/insert_word_test_cases.txt
let s:DEBUG = v:false
if v:vim_did_enter
    let s:current_line = "→ "
    " let s:current_line = ""
    let s:current_line = "  "
    let s:current_line = "  a"
    let s:current_line = "  ab"
    let s:current_line = "  abc"
    let s:adjacent_line = "📁 abc def ghi"

    let s:cursor_index = len(s:current_line)
    " call s:GetInsertString(s:current_line, s:adjacent_line, s:cursor_index)


    " let s:adjacent_line_error1 = "xy linter"
    " let s:current_line_error1 = "x abc"
    " let s:cursor_index_error1 = 3
    " let s:expected_insert_string_error1 = " linter"

    " let s:insert_string_error1 = s:GetInsertString(s:current_line_error1, s:adjacent_line_error1, s:cursor_index_error1)
    " if s:insert_string_error1 == s:expected_insert_string_error1
    "     echo "Test case 1 passed"
    " else
    "     echohl Error | echo printf("Expected: `%s`", s:expected_insert_string_error1) | echohl None
    "     echohl Error | echo printf("Actual  : `%s`", s:insert_string_error1) | echohl None
    "     echohl Error | echo "Test case 1 failed" | echohl None
    " endif
    "
endif
