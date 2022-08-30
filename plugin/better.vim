
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
function! s:BetterPreviousChangelist() range
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
nnoremap <silent> g; :call <SID>BetterPreviousChangelist()<CR>
command! -range Shim :echo "Range"<CR>
" nnoremap <silent> g; :Shim<CR>
" nnoremap <expr> g; ':<C-u>echo ' . v:count1 . '<CR>'

" nnoremap <silent> <expr> g; ":echo 'HEY'" . v:count1 . "<CR>"
" }}}

" BetterPreviousJumplist {{{
let g:lines = ""
function! s:GetJumpList()
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
function! s:BetterPreviousJumplist()
    let jump_dicts = s:GetJumpList()
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

function! s:LastJump()
    let jump_dicts = s:GetJumpList()
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
command! Jprevious call s:BetterPreviousJumplist()

cabbrev   jl      Jlast
cabbrev   jla     Jlast
cabbrev   jlas    Jlast
cabbrev   jlast   Jlast
command! Jlast call s:LastJump()
" }}}

" BetterZF {{{
" Test Cases:
" 1. Python code blocks & comment blocks
" 2. JavaScript code blocks & comment blocks
" 3. VimScript code blocks & comment blocks
function! s:BetterZF()
    " We do it this way to avoid 'indent', 'expandtab' headaches
    let reg_save = @"
    let start_line = getline("'<")
    let cms = trim(printf(&cms, ""))
    let sub_string = cms . " " . repeat("{", 3)
    let fold_start_line = substitute(start_line, '^\s*\zs\S.*', sub_string, "") . "\n"
    let fold_end_line = substitute(fold_start_line, "{", "}", "g")
    let @" = fold_end_line
    normal! '>p
    let @" = fold_start_line
    normal! '<P
    normal! ^f 
    let @" = reg_save
    call feedkeys("i ")
endfunction
vnoremap zf :<c-u>call <SID>BetterZF()<CR>

" }}}

" BD_Bang {{{
function! s:BD_Bang()
    let only_one_window = winnr("$") == 1
    if only_one_window
        return "bd!"
    else
        return "b!# | bd! #"
    endif
endfunction
cabbrev <expr> bd! <SID>BD_Bang()
" }}}

" BetterBacktick (buggy,deprecated){{{
function! s:BetterBacktick()
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
" nnoremap <silent> `` :call <SID>BetterBacktick()<CR>
" }}}

" ChangeUp {{{
function! s:ChangeUp()
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
" }}}

" ChangeDown {{{
function! s:ChangeDown()
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
" }}}

nnoremap <silent> `l :call <SID>ChangeUp()<CR>
nnoremap <silent> `k :call <SID>ChangeDown()<CR>

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
" BetterIT {{{
function! s:BetterIT(mode)

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
" }}}

xnoremap it :<c-u>call <SID>BetterIT("selection")<CR>
onoremap it :<c-u>call <SID>BetterIT("operation")<CR>

" BetterQuestionMark (deprecated, too complex, easier to remap n and N) {{{
function! s:Unmap()
    if getcmdtype() !=# "/"
        return
    endif
    nunmap n
    nunmap N
    au! UnmapN
endfunction
function! s:BetterQuestionMark(...)
    if getcmdtype() !=# "?"
        return
    endif
    " echoerr 'BetterQuestionMark'
    let v:searchforward = 1
    echoerr "Set searchforward"
    " echo "v:searchforward - " . v:searchforward
    " nnoremap n :normal! N<CR>
    " nnoremap N :normal! n<CR>
    " augroup UnmapN
    "     au!
    "     au CmdlineLeave * call s:Unmap()
    " augroup END
endfunction
function! s:ResetSearchForward(...)
    " call feedkeys(":let v:searchforward = 1\<CR>:echo ''\<CR>") 
    silent! ://
endfunction
augroup BQM
    au!
    " au CmdlineLeave \? call s:ResetSearchForward()
    " au CmdlineLeave \? call timer_start(1000, function('s:ResetSearchForward'))
augroup END
" }}}

" BetterStar {{{
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
" }}}

" BetterHash {{{
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
" }}}

function! s:GetActiveBuffers()
    " https://vi.stackexchange.com/questions/21006/how-to-get-the-names-of-all-open-buffers
    let l:blist = getbufinfo({ 'buflisted': 1 })
    let l:result = []
    for l:item in l:blist
        "skip unnamed buffers; also skip hidden buffers?
        if empty(l:item.name) || l:item.hidden
            continue
        endif
        " call add(l:result, { 'bufnr': l:item.bufnr, 'changedtick': l:item.changedtick, 'name': shellescape(l:item.name) })
        " call add(l:result, { 'bufnr': l:item.bufnr, 'changedtick': l:item.changedtick, 'name': l:item.name })
        call add(l:result, { 'bufnr': l:item.bufnr, 'name': l:item.name })
    endfor
    return l:result
endfunction


function! s:GetModifiedFiles()

    let l:dictionaries = []
    let l:buffers = s:GetActiveBuffers()
    for l:item in l:buffers
        let l:time = getftime(l:item['name'])
        let seconds_passed = localtime() - l:time
        if seconds_passed > 3600 * 6 || bufnr() == l:item['bufnr']
            continue
        endif
        let l:item['time'] = l:time
        call add(l:dictionaries, l:item)
    endfor
    let l:results = map(copy(l:dictionaries), { idx, D -> { 'bufnr': D['bufnr'], 'name': fnamemodify(D['name'], ":t") } })
    call sort(l:results, { d1, d2 -> d1['name'] > d2['name'] ? 1 : -1 })
    let l:lines = map(copy(l:results), { idx, D -> printf(" %2d : %s", D['bufnr'], D['name']) })
    echo join(l:lines, "\n")
    call feedkeys(":b")
endfunction
command! GMF call s:GetModifiedFiles()
nnoremap g' :call <SID>GetModifiedFiles()<CR>

nnoremap <silent> * :call <SID>BetterStar()<CR>
nnoremap <silent> # :call <SID>BetterHash()<CR>

noremap <expr> n v:searchforward == 1 ? 'n' : 'N'
noremap <expr> N v:searchforward == 1 ? 'N' : 'n'

