
function! s:RunTerminalCommand(command)
    execute a:command
    while &buftype != 'terminal'
        sleep 10m
    endwhile
    while term_getstatus(bufnr()) == 'running'
        sleep 10m
    endwhile
    sleep 10m
    normal! gg
endfunction

function! s:RunPython()
    if has('win32')
        let path = expand("%:p:h")
        let module_path = 'C:\Users\vivek\Python\waivek\waivek'
        let working_dir = 'C:\Users\vivek\Python\waivek'
        if path == module_path
            let filename_without_extension = expand("%:t:r")
            let directory = module_path
            let command = '!start cmd /k cd ' . working_dir . ' && python -m waivek.' . filename_without_extension
        else
            let command = '!start cmd /k python ' . expand("%:p")
        endif
        " let command = '!start wt -w 0 nt -p "Command Prompt" python ' . expand("%:p")
        execute command
    else
        let command = 'vert terminal python ' . expand("%:p")
        call s:RunTerminalCommand(command)
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
    let command = '!start cmd /k go run ' . expand("%:p")
    execute command
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
    execute command
    redraw | echo "source " . expand("%:t")
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
    endif
endfunction

nnoremap <Plug>Run :call <SID>Run()<CR>

