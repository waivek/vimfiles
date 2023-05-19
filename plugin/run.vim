

function! s:RunPython()
    let command = '!start cmd /k python ' . expand("%:p")
    " let command = '!start wt -w 0 nt -p "Command Prompt" python ' . expand("%:p")
    execute command
endfunction

function! s:RunNode()
    let command = '!start cmd /k node ' . expand("%:p")
    execute command
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

