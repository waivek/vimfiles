
" BUG: Bounds are not updated when you paste something with 'p'
" 1.   The case where a visually selected text is replaced via 'p' can be
"      handled through the TextYankPost autocommand.
" 2.   Unsure how to handle when text is pasted in normal mode
"
" EXAMPLES:
" test_string_with_no_spaces(argument_1, argument_2)



"   'iskeyword' contains _   match("_", "\\k")   underscore treated as SPACE in WORD definition   snake mode
"   ——————————————————————   —————————————————   ——————————————————————————————————————————————   ——————————
"                      YES                   0                                               NO          OFF
"                       NO                  -1                                              YES           ON


let s:show_debug_messages = v:false

let g:word_start_col = -1
let g:word_end_col = -1
let g:word_line = -1

let g:autocommands = ["START"]
let g:cursor_relative_index = -1

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

function! Log(autocmd_name)
    let g:cursor_relative_index = col(".") - g:word_start_col
    call add(g:autocommands, a:autocmd_name)
    if s:show_debug_messages
        echo printf("[%2d/%2d] %s", g:cursor_relative_index, (g:word_end_col - g:word_start_col), CompressList2String(g:autocommands))
    endif
endfunction

function! VerifyBounds()
    call Log("CM")
    if !s:show_debug_messages
        echohl ModeMsg | echo "-- SNAKE MODE --" | echohl None
    endif
    let is_out_of_bounds = line(".") !=# g:word_line || col(".") < g:word_start_col || col(".") > g:word_end_col
    let is_in_bounds = !is_out_of_bounds
    if is_in_bounds
        return
    endif

    " Exit Snake Mode
    set isk+=_
    call Log("END")
    au! SnakeMode
    let g:word_start_col = -1
    let g:word_end_col = -1
    let g:word_line = -1
    let g:autocommands = [ "START" ]
    let g:cursor_relative_index = -1
    echo ""
endfunction

breakdel *
" breakadd func 1 YankPost
function! YankPost()
    call Log("TYP")
    if v:event["operator"] ==# "c" || v:event["operator"] == "d"
        let text_length = len(v:event["regcontents"][0])
        let g:word_end_col = g:word_end_col - text_length
    endif
endfunction

function! LeftInsert()
    let backspace_count = count(@., "\<BS>")
    let dot_register_without_backspaces = substitute(@., "\<BS>", "", "g")
    let number_of_characters_inserted = len(dot_register_without_backspaces) - backspace_count
    let g:word_end_col = g:word_end_col + number_of_characters_inserted
    call Log("I_Leave")
endfunction

function! StartSnakeMode()
    set isk-=_
    augroup SnakeMode
        au!
        au TextYankPost * call YankPost()
        au InsertLeave  * call LeftInsert()
        au CursorMoved * call VerifyBounds()
        au InsertChange * call Log("InsertChange")
        au InsertEnter  * call Log("InsertEnter")
        au TextChanged  * call Log("TC")
        au TextChangedI * call Log("TCI")
        au TextChangedP * call Log("TC_P")
    augroup END
endfunction

function! s:Snake(command)
    execute "normal! " . a:command
    
    let current_position = getpos(".")
    let saved_register = @"
    normal! yiw
    let @" = saved_register
    call setpos(".", current_position)

    let g:word_start_col = col("'[")
    let g:word_end_col = col("']")
    let g:word_line = line(".")

    call StartSnakeMode()

endfunction

nnoremap <silent> f_ :call <SID>Snake("f_")<CR>
nnoremap <silent> F_ :call <SID>Snake("F_")<CR>
nnoremap <silent> t_ :call <SID>Snake("t_")<CR>
nnoremap <silent> T_ :call <SID>Snake("T_")<CR>


nmap <silent> - f_
nmap <silent> _ F_
xmap <silent> - f_
xmap <silent> _ F_

nnoremap <silent> c- ct_
nnoremap <silent> c_ cT_
nnoremap <silent> d- df_
nnoremap <silent> d_ dF_
