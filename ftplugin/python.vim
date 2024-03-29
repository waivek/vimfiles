


" function! s:PrintPythonVariable()
"     let print_fmt = 'print("variable_name: %s" % (variable_name))'
"     let reg_save = @a
"     normal! gv"ay
"     let @a = substitute(print_fmt, "variable_name", @a, "g")
"     normal! oa
"     normal! ^
"     let @a = reg_save
" endfunction
" vnoremap z :<c-u>call <SID>PrintPythonVariable()<CR>

function! s:Enumerate()
    if match(getline("."), "enumerate") == -1
        s/for\s\+\zs/i, /
        s/in \zs[^:]\+/enumerate(\0)
    else
        s/i, //
        s/enumerate(\(.*\)):/\1:
    endif
endfunction

function! s:ProfileImport()
    s/.*import \(.*\)/s = time(); \0; performances.append({"duration": time() - s, "package": "\1"})
endfunction

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

function! s:ToggleBreakpointNormal()
    let in_try = s:DetectIfInTryBlock()
    if in_try
        call s:RemoveTryBlock()
    else
        call s:SingleLineBreakpoint()
    endif
endfunction


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
    let import_line = trim(matchstrpos(getline("."), 'import [^#;]*')[0])
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
    if getpos("'a") != [ 0, 0, 0, 0 ]
        normal! 'a
    endif
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

function! s:InsertTimerVisual()
    let timer_id = input('Timer ID: ')
    if timer_id ==# ""
        return
    endif
    execute "normal! i "
    execute "normal! x"
    let indent = indent(".")
    let spaces = repeat(" ", indent)
    let start_string = printf('%stimer.start("%s")', spaces, timer_id)."\n"
    let print_string = printf('%stimer.print("%s")', spaces, timer_id)."\n"
    '>put=print_string
    '<-1put=start_string
endfunction


function! s:PythonShortcuts()
    " [[ PREVIOUS class|def
    " ]] NEXT class|def
    " [M PREVIOUS Method End
    " ]M NEXT Method End
endfunction

function! s:GetBlockIndent()
    " Edge-Case 1:
    " ============
    "
    " def main():
    ">
    "     pass
    let candidate_lineno = search('\S', 'bcn')
    let candidate_is_def_line = getline(candidate_lineno) =~# '^\s*def'
    if candidate_is_def_line
        let candidate_lineno = search('\S', 'cn')
    endif
    return indent(candidate_lineno)
endfunction
function! s:ClassOrMethodEnd(value)
    if a:value == 'class'
        let error_string = "Not in class"
        let search_regexp = '^\s*class'
    elseif a:value == 'method'
        let error_string = "Not in method"
        let search_regexp = '^\s*def'
    endif
    let view_save = winsaveview()
    let initial_line = line(".")

    " go to method START (take care of nested methods)

    if a:value == 'method'
        let on_def_line = getline(".") =~# '^\s*def'
        let structure_start_line = line(".")
        if on_def_line == v:false
            let line_start_indent = s:GetBlockIndent()
            let infinity_index = 10
            while v:true
                let structure_start_line = search(search_regexp, 'b') " no 'c' is used here since we've asserted that we are not on a 'def' line
                if structure_start_line == 0
                    break
                endif
                if indent(".") < line_start_indent
                    let structure_start_line = line(".")
                    break
                endif
                let infinity_index = infinity_index - 1
                if infinity_index == 0
                    echoerr "infinity_index: 0"
                    return
                endif
            endwhile
        endif
    else
        let structure_start_line = search(search_regexp, 'bc')
    endif

    if structure_start_line == 0
        echo error_string
        return
    endif
    let structure_start_indent = indent(structure_start_line)
    let regexp = printf('^\s\{0,%d\}\S', structure_start_indent)
    let search_line = search(regexp)
    if search_line == 0 " The class is the last structure in the file.
        normal! G
    endif
    let regexp = printf('^\s\{%d,\}[^# ]', structure_start_indent+1)
    call search(regexp, 'b')
    normal! $
    if line(".") < initial_line
        call winrestview(view_save)
        echo error_string
    endif
endfunction

function! s:MethodEnd()
    call s:ClassOrMethodEnd('method')
endfunction
function! s:MethodEndVisual()
    let start_pos = getpos(".")
    call s:MethodEnd()
    let end_pos = getpos(".")
    call setpos("'<", start_pos)
    call setpos("'>", end_pos)
    normal! gv
endfunction


function! s:ClassEnd()
    call s:ClassOrMethodEnd('class')
endfunction
function! s:ClassEndVisual()
    let start_pos = getpos(".")
    call s:ClassEnd()
    let end_pos = getpos(".")
    call setpos("'<", start_pos)
    call setpos("'>", end_pos)
    normal! gv
endfunction

function! s:AsyncMethodMappings(timer_id)
    nmap <silent> <buffer> ]m :call <SID>MethodEnd()<CR>
    xmap <silent> <buffer> ]m :<c-u>call <SID>MethodEndVisual()<CR>
    omap <silent> <buffer> ]m :<c-u>call <SID>MethodEndVisual()<CR>

    nmap <silent> <buffer> <CR> :call <SID>MethodEnd()<CR>
    xmap <silent> <buffer> <CR> :<c-u>call <SID>MethodEndVisual()<CR>
    omap <silent> <buffer> <CR> :<c-u>call <SID>MethodEndVisual()<CR>
endfunction

function! s:PythonTernary()
    s/=\s*\([^?]\+\)\s*?\s*\([^:]\+\)\s*:\s*\(.\+\)$/= \2 if \1 else \3
    s/\S\zs  \ze\S/ /g
endfunction

function! s:PythonComprehension()
    execute "normal! i "
    execute "normal! x"
    let start_space = substitute(getline("."), '\S.*', "", "")
    call search('^\s*for ', 'bc')
    s/:\s*$/ ]/
    m.+1
    .-1join
    s/^\s*/\=start_space.'[ '/
endfunction

let s:alphabet = "A"
function! s:InsertAlphabetPrint()
    " if trim(getline(":")
    " let start_space = substitute(getline("."), '\S.*', "", "")
    " let alphabet_line = start_space . printf('print("%s")', s:alphabet)
    " let s:alphabet = nr2char(char2nr(s:alphabet) + 1)
    " put=alphabet_line
endfunction

if !exists("s:q2b_is_running") 
    let s:q2b_is_running = v:false
endif
if s:q2b_is_running == v:false
    function! s:QF2Buffer()
        let s:q2b_is_running = v:true
        let lines = map(getqflist(), { idx, D -> D['text'] })
        let lines = map(lines, { idx, text -> substitute(text, '^\s*#\s*', '', '') })
        let lines = map(lines, { idx, text -> trim(text) })
        let lines_joined = join(lines, "\n")
        let filename = strftime("%y%m%d") . ".py"
        let filepath = "~/temp/" . filename
        execute "edit " . filepath
        g/^/d
        put=lines_joined
        g/^[A-Za-z!)0-9>%<;(|`+$@{?-\*#&}\-_=~^]\{77,\}$/d
        g/^\s*$/d
        write
        let s:q2b_is_running = v:false
    endfunction
endif


function! s:PythonNewTestFunction()
    let l:function_name = "test_" . input("def test_")
    let l:string = 'def ' . l:function_name . "(): \n    pass\n\n"
    " %s/^\zedef main/\='def ' . l:function_name .'():    pass'
    silent! /^def main/ | '{put=l:string
    %s/def main():\n    \zs\ze\S.*()\n/\=l:function_name.'()    # ' 
    call search('pass', 'b')
endfunction


command! -buffer NTF call s:PythonNewTestFunction()

command! Q2B silent call s:QF2Buffer()


command! -buffer IAP call s:InsertAlphabetPrint()

command! -buffer Enumerate call s:Enumerate()
command! -buffer Ternary call s:PythonTernary()
command! -buffer Comprehension call s:PythonComprehension()


call timer_start(1, function('s:AsyncMethodMappings'))
nnoremap <silent> <buffer> 'm :call <SID>GoToMainPythonFunction()<CR>
nnoremap <silent> <buffer> `m :call <SID>GoToMainPythonFunction()<CR>
nmap <buffer> <silent> ]c :call <SID>ClassEnd()<CR>
xmap <buffer> <silent> ]c :<c-u>call <SID>ClassEndVisual()<CR>
onoremap ]c :<c-u>call <SID>ClassEndVisual()<CR>


nnoremap <buffer> <silent> <space>b :call <SID>ToggleBreakpointNormal()<CR>
vnoremap <buffer> <silent> <space>b :<c-u>call <SID>InsertBreakpointVisual()<CR>
nnoremap <silent> <buffer> <space>t :call <SID>ToggleTimerSingleLine()<CR>
vnoremap <silent> <space>t :<c-u>call <SID>InsertTimerVisual()<CR>
nnoremap <silent> <space>T :call <SID>InsertFileTimer()<CR>
inoremap <buffer> jF print(f"{ = }")T{

iabbrev <buffer> respones response
iabbrev <buffer> Respones Response

setlocal nosmartindent " To indent lines /^#/ with >

command! Py !start python -i C:/Users/vivek/repl.py



let g:pyindent_searchpair_timeout = 50

