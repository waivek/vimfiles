" deprecated {{{
function! s:JumpDictToFilepath(jump_dict)
    let l:jump_dict = a:jump_dict
    let l:filepath = bufname(l:jump_dict["bufnr"])
    if !isabsolutepath(l:filepath)
        let l:filepath = expand("%:p:h") . "/" . l:filepath
    endif
    return l:filepath
endfunction
" }}}

function! s:GetJumpList()
    let reg_save = @"
    let l:jump_string = execute("jumps")
    let @" = reg_save
    let lines = split(l:jump_string, "\n")[1:]
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

function! s:StackHasJump(jump_stack, jump_dict)
    let l:jump_stack = a:jump_stack
    let l:jump_dict = a:jump_dict
    let l:bufnrs = map(copy(l:jump_stack), "v:val['bufnr']")
    let l:bufnr = l:jump_dict["bufnr"]
    return index(l:bufnrs, l:bufnr) != -1
endfunction

function! s:GetJumpStack()
    let l:jump_list = s:GetJumpList()
    let l:jump_stack = []
    for l:jump_dict in reverse(l:jump_list)
        if s:StackHasJump(l:jump_stack, l:jump_dict)
            continue
        endif

        call add(l:jump_stack, l:jump_dict)
    endfor
    return l:jump_stack
endfunction

function! s:LogError(message, line, col, function_name)
    let l:message = a:message
    let l:line = a:line
    let l:col = a:col
    let l:function_name = a:function_name
    echo printf("[jprev.vim:%d:%d] (%s) %s", l:line, l:col, l:function_name, l:message)
endfunction

function! s:DoJPrevious()

    let l:jump_stack = s:GetJumpStack()
    if len(l:jump_stack) == 0
        call s:LogError("No jumps found", line("."), col("."), "s:DoJPrevious")
        return
    endif

    let l:bufnrs = map(copy(l:jump_stack), "v:val['bufnr']")
    let l:index = index(l:bufnrs, bufnr("%"))
    if l:index == -1
        call s:LogError("Current buffer not in jump stack", line("."), col("."), "s:DoJPrevious")
        return
    endif

    let l:next_index = l:index + 1
    if l:next_index >= len(l:jump_stack)
        echo "No more jumps"
        return
    endif

    let l:next_jump = l:jump_stack[l:next_index]
    let l:ctrl_o_count_string = l:next_jump["jump"]
    let l:ctrl_o_count = str2nr(l:ctrl_o_count_string)

    execute "normal! " . l:ctrl_o_count . "\<C-o>"

endfunction

function! s:Main()
    call s:DoJPrevious()
endfunction

if v:vim_did_enter
    Capture call s:Main()
endif

command! JPrevious call s:DoJPrevious()
command! Jprevious call s:DoJPrevious()

