function! s:Samples()
    let l:samples = [
                \ '// run.vim: 1 2 3',
                \ '// run.vim: 4 5 6'
                \]
endfunction


function! s:RunTerminalCommand(command)
    execute a:command
    " while &buftype != 'terminal'
    "     sleep 10m
    " endwhile
    " while term_getstatus(bufnr()) == 'running'
    "     sleep 10m
    " endwhile
    " sleep 10m
    " normal! gg
endfunction

function! s:ShouldRunTerminalInHorizontal(last_line, cms)
    let l:last_line = a:last_line
    let l:cms = a:cms
    let l:last_line_contains_run_vim_config = l:last_line =~ printf('%s run.vim:', l:cms)
    if !l:last_line_contains_run_vim_config
        return v:false
    endif

endfunction

function! s:RunPython()
    if has('win32')
        " let path = expand("%:p:h")
        " let module_path = 'C:\Users\vivek\Python\waivek\waivek'
        " let working_dir = 'C:\Users\vivek\Python\waivek'
        let parent_folder_name = expand("%:p:h:t")
        if parent_folder_name == 'waivek'
            let filename_without_extension = expand("%:t:r")
            let command = '!start cmd /k cd ' . working_dir . ' && python -m waivek.' . filename_without_extension
        else
            let command = '!start cmd /k python ' . expand("%:p")
        endif
        execute command
    else
        let parent_folder_name = expand("%:p:h:t")

        let last_line = getline("$")
        if last_line =~ '^# run.vim:'
            let args = substitute(last_line, '^# run.vim:', '', '')
            let args = trim(args)
            let command = 'vert terminal python ' . expand("%:p") . ' ' . args
        else
            let command = 'vert terminal python %'
        endif

        call s:RunTerminalCommand(command)
        set nonumber
    endif
endfunction

function! s:RunNode()
    if has('win32')
        let command = '!start cmd /k node ' . expand("%:p")
        execute command
    else
        let command = 'vert terminal node ' . expand("%:p")
        call s:RunTerminalCommand(command)
    endif
endfunction

function! s:RunGo()
    if has('win32') || has('win64')
        let command = '!start cmd /k go run ' . expand("%:p")
        execute command
    else
        let command = 'vert terminal go run ' . expand("%:p")
        call s:RunTerminalCommand(command)
    endif
endfunction

function! s:RunTodo()
    let command = '!start chrome live.co/todo.php'
    execute command
endfunction

function! s:RunAutoHotkey()
    let command = '!start %'
    execute command
endfunction

function! s:RunVim()
    let command = 'so %'
    " We add try catch for when we have multi page output and exit without
    " reaching the end of the file via `q`, we can get an `Interrupted` error
    try
        execute command
    catch /Interrupted/
    endtry
    echo "source " . expand("%:t")
    " redraw | echo "source " . expand("%:t")
endfunction


function! s:RunBash()
    let command = 'vert term bash -c "source %"'
    execute command
endfunction


function! s:Run()
    if &ft == "python"
        call s:RunPython()
    elseif &ft == "javascript"
        call s:RunNode()
    elseif &ft == "go"
        call s:RunGo()
    elseif expand("%:p:h") == expand("~/vimfiles/todo")
        call s:RunTodo()
    elseif &ft == "autohotkey"
        call s:RunAutoHotkey()
    elseif &ft == "vim"
        call s:RunVim()
    elseif &ft == "sh"
        call s:RunBash()
    endif
endfunction

function! s:RunCreateCommandCompletion(A, L, P)
    let l:options = [ "vertical (default)", "horizontal", "full" ]
    return filter(l:options, 'v:val =~ "^' . a:A . '"')
endfunction

function! s:RunCreateCommand(run_command_name)
    let l:last_line = getline("$")
    if l:last_line =~ '^# run.vim:'
        echon "Last line already contains run.vim config: "
        echohl String | echo l:last_line | echohl None
        return
    endif
    let l:run_command_name = a:run_command_name
    if l:run_command_name == "horizontal"
        let l:run_command = 'term python %'
    elseif l:run_command_name == "full"
        let l:run_command = 'term ++rows=100 python %'
    elseif l:run_command_name == "vertical (default)"
        let l:run_command = 'vert term python %'
    else
        echo printf("Invalid run command name: %s", l:run_command_name)
        return
    endif
    call append("$", printf("# run.vim: %s", l:run_command))
    normal! G
endfunction

nnoremap <Plug>Run :call <SID>Run()<CR>

command! -complete=customlist,s:RunCreateCommandCompletion -nargs=? RunCreateCommand call s:RunCreateCommand(<f-args>)
