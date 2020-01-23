" TODO: Tilde (~) operator
" TODO: Replacement (r, R)
" TODO: Insertion without deletion
" We are tracking most things via the CursorMoved autocommand. We cannot use the
" TextChanged command to detect tile (~) and replacement (r) operations, because
" the TextChanged autocommand is run after the CursorMoved autocommand which
" unbinds the VerifySnake function

let s:show_debug_messages = v:true
let g:stored_word = ""
let g:word_start_col = -1
let g:word_end_col = -1

let g:autocommands = ["START"]
let g:cursor_relative_index = -1
" function! s:norma_a_curly_quotes() | function! s:normal_to_curly_quotes()
" function! s:normalab_to_curly_quotes()

" function! s:String2Pattern(string)
"     let highlighted_string = a:string
"     let magic_escape_chars =  '[]\$^*~."/'
"     let search_string = escape(highlighted_string, magic_escape_chars)
"     let search_string = substitute(search_string, "\\n", '\\n', "g")
"     return search_string
" endfunction

function! CompressList2String(list)
    let duplicate_value = v:null
    let frequencies = []
    let duplicate_count = 0
    let frequency_dict = {}
    for item in a:list
        if duplicate_value ==# item
            let frequency_num = frequencies[-1][1]
            let frequencies[-1][1] = frequency_num + 1
        else
            let duplicate_value = item
            call add(frequencies, [item, 1]) 
        endif
    endfor
    let rep_strings = []
    for [string, freq] in frequencies
        if freq ==# 1
            call add(rep_strings, string)
        else
            call add(rep_strings, string . " (" . freq . ")")
        endif
    endfor
    let rep_string = join(rep_strings, " → ")
    return rep_string
endfunction
" let L = ["a", "b", "b", "b", "c", "c", "b", "b", "b", "d"]
" echo CompressList2String(L)

" function! s:normal_to_curly_quotes() | function! s:normal_to_curly_quotes()
function! CustomLogger(autocmd_name)
    let g:cursor_relative_index = col(".") - g:word_start_col
    call add(g:autocommands, a:autocmd_name)
    if s:show_debug_messages
        echo printf("[%2d/%2d] %s", g:cursor_relative_index, (g:word_end_col - g:word_start_col), CompressList2String(g:autocommands))
    endif
endfunction

" function! s:normal__trly_quotes() | function! s:normal_to_curly_quotes()
" function! s:a_a_a_a() 

" Handles 'x' and 'd' operator
function! HandleDelete()
    call CustomLogger("TextYankPost")
    if v:event["operator"] !=# "d"
        return
    endif
    function! RestartVerification()
        au! SnakeMode TextChanged

        call CustomLogger("TextChanged")

        set isk+=_
        let current_position = getpos(".")
        let saved_register = @"
        normal! yiw
        let g:stored_word = @"
        let g:word_start_col = col("'[")
        let g:word_end_col = col("']")
        let @" = saved_register
        call setpos(".", current_position)
        set isk-=_

        au SnakeMode CursorMoved * call s:VerifySnake()
    endfunction
    au! SnakeMode CursorMoved
    au SnakeMode TextChanged * call RestartVerification()
endfunction

function! s:VerifySnake()
    if mode() ==# "v" || mode() ==# "V" || mode() ==# ''
        return
    endif
    " echohl ModeMsg | echo "-- 🐍 SNAKE 🐍 --" | echohl None
    call CustomLogger("CursorMoved")

    set isk+=_

    let current_position = getpos(".")
    let saved_register = @"
    normal! yiw
    let word_under_cursor = @"
    let @" = saved_register
    let g:word_start_col = col("'[")
    let g:word_end_col = col("']")

    let single_letter_change_index = col("'.") - col("'[")

    call setpos(".", current_position)

    if word_under_cursor ==# g:stored_word
        set isk-=_
    elseif substitute(word_under_cursor, @., @-, "") ==# g:stored_word
        " this lets snake mode persiste even if a change is made to a part of the snake-case string
        set isk-=_
        let g:stored_word = word_under_cursor
    else
        echo
        call CustomLogger("END")
        au! SnakeMode
        let g:word_start_col = -1
        let g:word_end_col = -1
        let g:autocommands = [ "START" ]
        let g:cursor_relative_index = -1
    endif
endfunction

function! s:Snake(command)
    execute "normal! " . a:command
    
    let current_position = getpos(".")
    let saved_register = @"
    normal! yiw
    let g:stored_word = @"
    let g:word_start_col = col("'[")
    let g:word_end_col = col("']")
    let @" = saved_register
    call setpos(".", current_position)


    set isk-=_

    " |InsertEnter|		starting Insert mode
    " |InsertChange|		when typing <Insert> while in Insert or Replace mode
    " |InsertLeave|		when leaving Insert mode
    " |InsertCharPre|		when a character was typed in Insert mode, before
    " function! s:normal_eWS_Quotes()
    " x → TextYankPost
    augroup SnakeMode
        au!
        au TextYankPost * call HandleDelete()
        au InsertEnter  * call CustomLogger("InsertEnter")
        au InsertChange * call CustomLogger("InsertChange")
        au InsertLeave  * call CustomLogger("InsertLeave")
        " au TextChanged  * call s:VerifySnake()
        au TextChangedI * call CustomLogger("TextChangedI")
        au TextChangedP * call CustomLogger("TextChangedP")
        au  CursorMoved * call s:VerifySnake()
    augroup END
endfunction

nnoremap <silent> f_ :call <SID>Snake("f_")<CR>
nnoremap <silent> F_ :call <SID>Snake("F_")<CR>
nnoremap <silent> t_ :call <SID>Snake("t_")<CR>
nnoremap <silent> T_ :call <SID>Snake("T_")<CR>

