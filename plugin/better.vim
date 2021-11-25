
" BetterPreviousChangelist {{{
" HOW TO TEST- 1. Comment out a line. 2. Go to a line somewhere else and press O. 3. Call function
"
" Idea:  Add a variable line_count. Then if next change falls with line_count
"        lines of current line, we can ignore that change. Default behavour of
"        g; is as if line_count = 0, because event if the change happened on
"        the same line and column, the cursor doesn’t merge the changes. With
"        line_count, we would be able to target the use case more, which is
"        jumping to the previous change on some other "screen" as opposed to
"        the previous change which took place on this screen.

" Note: We are now doing linewise changelist. Multiple changes on the same line
" will be merged in the context of g;
function! BetterPreviousChangelist() range
    let line_save = line(".")
    " line    |    45 |    45 |    45 |    45
    " cushion |     0 |     1 |     2 |     3
    " exclude | 45-45 | 44-46 | 43-47 | 42-48
    let cushion = v:count1
    while v:true
        " Note: silent! ignores error messages
        silent! normal! g;
        let [change_dictionaries, current_change_number] = getchangelist()
        let no_more_changes = current_change_number == 0 || change_dictionaries == []
        let outside_cushion = abs(line(".") - line_save) > cushion
        if no_more_changes || outside_cushion
            if no_more_changes
                echo "At start of changelist"
            endif
            break
        endif
    endwhile
endfunction
nnoremap <silent> g; :call BetterPreviousChangelist()<CR>
command! -range Shim :echo "Range"<CR>
nnoremap <silent> g; :Shim<CR>
" nnoremap <expr> g; ':<C-u>echo ' . v:count1 . '<CR>'
nnoremap  g; :<C-u>call BetterPreviousChangelist()<CR>

" nnoremap <silent> <expr> g; ":echo 'HEY'" . v:count1 . "<CR>"
" }}}

" BetterPreviousJumplist {{{
let g:lines = ""
function! GetJumpList()
    let reg_save = @"
    redir @"
    silent jumps
    redir END
    let jump_string = @"
    let @" = reg_save
    let lines = split(jump_string, "\n")[1:]
    let line_dicts = []

    " Parse :jumps into a list
    for line in lines
        if line[0] == ">"
            let line = " " . line[1:]
        endif
        if len(trim(line)) == 0
            continue
        endif
        let split_L = split(trim(line))
        let [jump, line, col; rest] = split_L
        let D = { "jump" : jump, "line" : line, "col" : col, "filetext" : join(rest) }
        call add(line_dicts, D)
    endfor

    " Turn jumps to +/- for before and after usage
    let prefix="-"
    for i in range(len(line_dicts))
        let D = line_dicts[i]
        if D["jump"] == "0"
            let prefix = "+"
        else
            let D["jump"] = prefix . D["jump"]
            let line_dicts[i] = D
        endif
    endfor


    " Add bufnr to line_dicts
    let jumplist = getjumplist()[0]
    " Assert(len(jumplist) == len(line_dicts)) {{{
    if len(jumplist) != len(line_dicts)
        echoerr printf("length of jumplist (%d) != length of line_dicts (%d)", len(jumplist), len(line_dicts))
        return
    endif
    " }}}
    for i in range(len(line_dicts))
        let line_dict = line_dicts[i]
        let jump_dict = jumplist[i]
        " Assert that linenumber and colnumber match {{{
        " getjumplist()[0][0] {'jump': '-89', 'col' : '23', 'lnum': '740', 'filetext': 'set formatoptions-=o'}
        " line_dict           { 'bufnr': 28,  'col' : 23,   'line':  740, 'coladd': 0}
        if line_dict["line"] != jump_dict["lnum"]
            echoerr printf('mismatch at index %d, line_dict["line"] (%d) != jump_dict["lnum"] (%s)', i, line_dict["line"], jump_dict["lnum"])
        endif
        if line_dict["col"] != jump_dict["col"]
            echoerr printf('mismatch at index %d, line_dict["col"] (%d) != jump_dict["col"] (%s)', i, line_dict["col"], jump_dict["col"])
        endif
        " }}}
        let line_dict["bufnr"] = jump_dict["bufnr"]
        let line_dicts[i] = line_dict
    endfor
    return line_dicts
endfunction

" IDEA: As you are going through previous files, show gui of files behind and ahead
" IDEA: Implement <Space>i to go forward
" IDEA: Let the commands accept COUNT’s
" IDEA: Change it to something more spammable instead of <Space>
function! BetterPreviousJumplist()
    let jump_dicts = GetJumpList()
    let start_index = -1
    for i in range(len(jump_dicts))
        let D = jump_dicts[i]
        if D["jump"] == "0"
            let start_index = i
        endif
    endfor
    if start_index == -1
        let start_index = len(jump_dicts) - 1 
    endif

    let diff_buffer_jump_dict = {}
    for i in range(start_index+1)
        let jump_dict = jump_dicts[i]
        if jump_dict["bufnr"] != bufnr("%")
            let diff_buffer_jump_dict = jump_dict
        endif
    endfor

    if diff_buffer_jump_dict == {}
        echohl Error
        echo "All previous jumps are in the same file"
        echohl Normal
        return
    endif

    let ctrl_o_count = diff_buffer_jump_dict["jump"][1:]
    let jump_command = printf("normal! %d\<C-o>", ctrl_o_count)
    execute jump_command
endfunction

function! LastJump()
    let jump_dicts = GetJumpList()
    let last_jump_dict = jump_dicts[-1]
    let last_jump_int = str2nr(last_jump_dict["jump"])
    if last_jump_int <= 0
        return
    endif
    let ctrl_i_count = abs(last_jump_int)
    let jump_command = printf("normal! %d\<C-i>", ctrl_i_count) " the space is CTRL-I represented as a TAB
    echo jump_command
    execute jump_command

endfunction

cabbrev   jp      Jprevious
cabbrev   jpr     Jprevious
cabbrev   jpre    Jprevious
cabbrev   jprev   Jprevious
command! Jprevious call BetterPreviousJumplist()

cabbrev   jl      Jlast
cabbrev   jla     Jlast
cabbrev   jlas    Jlast
cabbrev   jlast   Jlast
command! Jlast call LastJump()
" }}}

" BetterZF {{{
" Test Cases:
" 1. Python code blocks & comment blocks
" 2. JavaScript code blocks & comment blocks
" 3. VimScript code blocks & comment blocks
function! BetterZF()
    let fmt_save = &formatoptions
    set formatoptions-=o
    execute "normal! '>o" . repeat("}", 3)
    TComment
    execute "normal! '<O" . repeat("{", 3)
    TComment
    normal! ^f 
    let &formatoptions = fmt_save
    call feedkeys("i ")
endfunction
vnoremap zf :<c-u>call BetterZF()<CR>

" }}}

" BD_Bang {{{
function! BD_Bang()
    let only_one_window = winnr("$") == 1
    if only_one_window
        return "bd!"
    else
        return "b!# | bd! #"
    endif
endfunction
cabbrev <expr> bd! BD_Bang()
" }}}

" BetterBacktick (buggy,deprecated){{{
function! BetterBacktick()
    if empty(getchangelist()[0])
        " Jump to previous jump. Useful in Read-Only files.
        normal! ``
        return
    endif
    let onNewestChange = getchangelist()[1] == 100 || getchangelist()[1] == 99
    if onNewestChange
        let topScreenLine = line(".") - winline() + 1
        let botScreenLine = min([line(".") - winline() + winheight(0), line("$")])
        while v:true
            " Note: silent! ignores error messages
            silent! normal! g;
            let [change_dictionaries, current_change_number] = getchangelist()
            let no_more_changes = current_change_number == 0 || change_dictionaries == []
            let outside_window = line(".") < topScreenLine || line(".") > botScreenLine
            if no_more_changes || outside_window
                if no_more_changes
                    echo "At start of changelist"
                endif
                break
            endif
        endwhile
    else
        normal! 100g,
    endif
endfunction
" nnoremap <silent> `` :call BetterBacktick()<CR>
" }}}

function! ChangeUp()
    let [change_dictionaries, current_change_number] = getchangelist()
    if current_change_number > len(change_dictionaries)-1
        let current_change_number = len(change_dictionaries)-1
    endif
    let indices = range(current_change_number, 0, -1)
    let current_line = line(".")
    let target_pos = getpos(".")
    for i in indices
        let change_D = change_dictionaries[i]
        let is_above = change_D["lnum"] < current_line
        if is_above
            let target_pos = [ change_D["lnum"], change_D["col"], change_D["coladd"] ]
            break
        endif
    endfor
    call cursor(target_pos)
endfunction
function! ChangeDown()
    let [change_dictionaries, current_change_number] = getchangelist()
    if current_change_number > len(change_dictionaries)-1
        let current_change_number = len(change_dictionaries)-1
    endif
    let indices = range(current_change_number, 0, -1)
    let current_line = line(".")
    let target_pos = getpos(".")
    for i in indices
        let change_D = change_dictionaries[i]
        let is_above = change_D["lnum"] > current_line
        if is_above
            let target_pos = [ change_D["lnum"], change_D["col"], change_D["coladd"] ]
            break
        endif
    endfor
    call cursor(target_pos)
endfunction
nnoremap <silent> `l :call ChangeUp()<CR>
nnoremap <silent> `k :call ChangeDown()<CR>

" Test Case: {{{
" <span><a></a></span>
"
"
"
" <body>
"     <div>
"         <ul>
"             <li></li>
"             <li></li>
"             <li></li>
"             <li></li>
"         </ul>
"     </div>
" </body>
" }}}
function! BetterIT(mode)

    let is_selection = a:mode ==# "selection"
    let visual_is_one_char = getpos("'<") == getpos("'>")
    let extend = is_selection && !visual_is_one_char

    let view_save = winsaveview()
    " `gvit` triggers extend 'it', regular `vit` is one character and doesn't
    normal! gvit
    if extend
        return " OUTCOME 1: EXTEND SELECTION
    endif
    normal! 
    call winrestview(view_save)
    normal! vit
    " OUTCOME 2: SINGLE LINE SELECTION
    if line("'<") != line("'>") " OUTCOME 3: MULTILINE SELECTION
        if indent("'<") == 0
            normal! oj0V
        else
            normal! kg_oj0V
        endif
    endif
endfunction
xnoremap it :<c-u>call BetterIT("selection")<CR>
onoremap it :<c-u>call BetterIT("operation")<CR>

" augroup HotReload
"     au!
"     au BufWritePost <buffer> source %
" augroup END

function! Unmap()
    if getcmdtype() !=# "/"
        return
    endif
    nunmap n
    nunmap N
    au! UnmapN
endfunction
function! BetterQuestionMark()
    if getcmdtype() !=# "?"
        return
    endif
    nnoremap n :normal! N<CR>
    nnoremap N :normal! n<CR>
    augroup UnmapN
        au!
        au CmdlineLeave * call Unmap()
    augroup END
endfunction
augroup BetterQuestionMark
    au!
    au CmdlineLeave * call BetterQuestionMark()
augroup END


function! s:BetterStar()
    call search('\k', 'c')
    " let yanked_word = normal! yiw {{{
    let reg_save = @"
    let paste_start_save = getpos("'[")
    let paste_end_save = getpos("']")
    normal! yiw
    let yanked_word = @"
    let @" = reg_save
    call setpos("'[", paste_start_save)
    call setpos("']", paste_end_save)
    " }}}
    let @/ = '\C\<'.yanked_word.'\>'
    call feedkeys("n")
endfunction
function! s:BetterHash()
    call search('\k', 'c')
    " let yanked_word = normal! yiw {{{
    let reg_save = @"
    let paste_start_save = getpos("'[")
    let paste_end_save = getpos("']")
    normal! yiw
    let yanked_word = @"
    let @" = reg_save
    call setpos("'[", paste_start_save)
    call setpos("']", paste_end_save)
    " }}}
    let @/ = '\C\<'.yanked_word.'\>'
    call feedkeys("N")
endfunction

nnoremap <silent> * :call <SID>BetterStar()<CR>
nnoremap <silent> # :call <SID>BetterHash()<CR>
