function! PrintPythonVariable()
    let print_fmt = 'print("variable_name: %s" % (variable_name))'
    let reg_save = @a
    normal! gv"ay
    let @a = substitute(print_fmt, "variable_name", @a, "g")
    normal! oa
    normal! ^
    let @a = reg_save
endfunction
vnoremap z :<c-u>call PrintPythonVariable()<CR>

function! Enumerate()
    if match(getline("."), "enumerate") == -1
        s/for\s\+\zs/i, /
        s/in \zs[^:]\+/enumerate(\0)
    else
        s/i, //
        s/enumerate(\(.*\)):/\1:
    endif
endfunction
command! Enumerate call Enumerate()

setlocal path+=~/Documents/Python/

iabbrev <buffer> respones response

function! ProfileImport()
    s/.*import \(.*\)/s = time(); \0; performances.append({"duration": time() - s, "package": "\1"})
endfunction

function! GdInFile()
    " pre_yank {{{
    let reg_save = @"
    let yank_start = getpos("'[")
    let yank_end = getpos("']")
    " }}}

    normal! yiw
    let search_pattern = 'def\s\+\zs'.@".'\>'

    let @/ = search_pattern

    let view_save = winsaveview()
    let wrap_save = &wrapscan
    let &wrapscan = 1
    try
        silent normal! N
        if view_save["lnum"] != line(".")
            normal! zt
        endif
    catch /^Vim[^)]\+):E486\D/
        echohl Directory | echon "Definition not found: " | echohl Normal | echon @"."()"
        call winrestview(view_save)
    endtry
    let &wrapscan = wrap_save

    " post_yank {{{
    let @" = reg_save
    call setpos("'[", yank_start)
    call setpos("']", yank_end)
    " }}}
endfunction
nnoremap <buffer> <silent> gd :call GdInFile()<CR>

function! s:PreviousIndentSpecialized()
    let start_indent = indent(".")
    let previous_indent = start_indent == 0 ? 0 : start_indent-1
    let regexp = printf('^\s\{0,%d\}\S', previous_indent)
    keepjumps call search(regexp, 'be')
endfunction
function! s:DetectIfInTryBlock()
    let result = v:false
    let view_save = winsaveview()
    let while_limit = 100
    let while_counter = 0
    while indent(".") != 0 && while_counter < while_limit
        let current_line = trim(getline("."))
        if stridx(current_line, "try:") == 0 || stridx(current_line, "except") == 0
           let result = v:true
        endif
        call s:PreviousIndentSpecialized()
        let while_counter = while_counter + 1
    endwhile
    if while_counter == while_limit
        echohl Error | echo "Hit While Limit: ".string(while_limit) | echohl Normal
    endif
    call winrestview(view_save)
    return result
endfunction
function! s:GoToTryBlockEnd()
    normal! $
    call search('try:', 'bc')
    call search('^\s\+except')

    let except_line_nr = line(".")
    let except_line_indent = indent(except_line_nr)
    let line_numbers = range(except_line_nr+1, line("$"))
    let except_end_line_nr = except_line_nr
    for line_number in line_numbers
        let current_indent = indent(line_number)
        if current_indent > except_line_indent
            let except_end_line_nr = line_number
            continue
        elseif trim(getline(line_number)) == ""
            continue
        else
            break
        endif
    endfor

    execute except_end_line_nr
endfunction
function! s:RemoveTryBlock()
    normal! $
    call search('try:', 'bc')
    normal! j
    normal! ma
    call search('^\s\+except')
    normal! k
    normal! mb
    normal! 'aV'bd

    call search('try:', 'bc')
    normal! ma
    call s:GoToTryBlockEnd()
    normal! mb
    normal! 'aV'bp
    normal! '[<']
endfunction
function! s:SingleLineBreakpoint()
    normal! V
    call s:InsertBreakpointVisual()
endfunction
function! s:InsertBreakpointVisual()
    let reg_save = @"
    let indent = indent(".")
    let spaces = repeat(" ", indent)
    normal! gvd
    let lines = split(@", "\n")
    let lines_with_extra_indent = []
    for line in lines
        call add(lines_with_extra_indent, "    ".line)
    endfor
    let lines = [ spaces."try:" ] + lines_with_extra_indent + [ spaces."except Exception as e:", spaces."    error = e", spaces."    breakpoint()" ]
    let @" = join(lines, "\n") . "\n"
    normal! P
    " normal! ']jdd
    " normal! ``
    let @" = reg_save
endfunction

function s:ToggleBreakpointNormal()
    let in_try = s:DetectIfInTryBlock()
    if in_try
        call s:RemoveTryBlock()
    else
        call s:SingleLineBreakpoint()
    endif
endfunction

nnoremap <buffer> <silent> <space>b :call <SID>ToggleBreakpointNormal()<CR>
vnoremap <buffer> <silent> <space>b :<c-u>call <SID>InsertBreakpointVisual()<CR>

function! s:GoToRepeatChangeFunction()
    normal! gg
    call search("function! RepeatChange()")
    normal! zt
endfunction

function! s:GoToMainPythonFunction()
    normal! gg
    call search("def main()")
    normal! zt
    normal! M
endfunction
nnoremap <silent> <buffer> 'm :call <SID>GoToMainPythonFunction()<CR>
nnoremap <silent> <buffer> `m :call <SID>GoToMainPythonFunction()<CR>

function! s:InsertFileTimer()
    let view_save = winsaveview()
    normal! gg
    let timer_line = search("Timer(")
    if timer_line == 0
        echohl Error | echo "Missing: Timer()" | echohl Normal
        return
    endif
    let timer_id = expand("%:t")
    let start_string = printf('timer.start("%s")', timer_id)."\n"
    let print_string = printf('timer.print("%s")', timer_id)."\n"
    put=start_string
    $put=print_string
endfunction

function! s:SingleLineTimer()
    let first_function =  matchstrpos(getline("."), '\w\+\ze(')[0]
    let import_line = matchstrpos(getline("."), 'import [^#;]*')[0]
    if len(first_function) == 0 && len(import_line) == 0
        return
    endif
    let timer_id = len(first_function) == 0 ? import_line : first_function
    let indent = indent(".")
    let spaces = repeat(" ", indent)
    let start_string = printf('%stimer.start("%s")', spaces, timer_id)."\n"
    let print_string = printf('%stimer.print("%s")', spaces, timer_id)."\n"
    let reg_save = @"
    let yank_start_save = getpos("'[")
    let yank_stop_save = getpos("']")
    let @" = start_string
    normal! P
    normal! j
    let @" = print_string
    normal! p
    normal! k
    normal! 
endfunction

function! s:DeleteTimer()
    if stridx(getline("."), "timer") == -1
        return
    endif
    let reg_save = @"
    normal! 0f"ya"
    let timer_id = @"
    let @" = reg_save
    let partial_pattern = String2Pattern(timer_id)
    let full_pattern = 'timer\..*'.partial_pattern
    if stridx(getline("."), "start") > -1
        normal! j
        normal! ma
    elseif stridx(getline("."), "print") > -1
        normal! k
        normal! ma
    endif
    execute 'g/'.full_pattern.'/d'
    normal! 'a
endfunction
function! s:ToggleTimerSingleLine()
    if stridx(getline("."), "timer") == -1
        call s:SingleLineTimer()
    else
        call s:DeleteTimer()
    endif
endfunction

function! s:VisualUltisnipsTimer()
    call UltiSnips#SaveLastVisualSelection()
    normal! gvstimer
    call feedkeys("A\<C-j>")
    return
endfunction

nnoremap <silent> <buffer> <space>t :call <SID>ToggleTimerSingleLine()<CR>
vnoremap <silent> <space>t :<c-u>call <SID>VisualUltisnipsTimer()<CR>

nnoremap <silent> <space>T :call <SID>InsertFileTimer()<CR>
