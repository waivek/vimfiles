
if !exists('g:custom_runner')
    let g:custom_runner = ""
endif

function! s:GetRunners()
    let l:ft_to_runner = {
                \ "python"     : "python %",
                \ "javascript" : "node %",
                \ "go"         : "go run %",
                \ "sh"         : "bash -c \"source %\"",
                \ }
    return l:ft_to_runner
endfunction

function! s:RunCreateCommandCompletion(A, L, P)
    return filter([ "vertical", "horizontal", "full" ], 'v:val =~ "^' . a:A . '"')
endfunction

function! s:RunCreateCommand(...)
    let l:last_line = getline("$")
    if l:last_line =~ '^# run.vim:'
        echon "Last line already contains run.vim config: "
        echohl String | echo l:last_line | echohl None
        return
    endif

    let l:ft = &filetype
    let l:runners = s:GetRunners()
    let l:runner = get(l:runners, l:ft, "")
    if l:runner == ""
        echo "No runner found for filetype: " . l:ft
        return
    endif

    if len(a:000) == 0
        let l:run_command_name = "vertical"
    else
        let l:run_command_name = a:1 " a:0 is len(a:000), not the first arg
    endif
    if l:run_command_name == "horizontal"
        let l:run_command = 'term ' . l:runner
    elseif l:run_command_name == "full"
        let l:run_command = 'term ++rows=100 ' . l:runner
    elseif l:run_command_name == "vertical"
        let l:run_command = 'vert term ' . l:runner
    else
        echo printf("Invalid run command name: %s", l:run_command_name)
        return
    endif
    call append("$", printf("# run.vim: %s", l:run_command))
    normal! G
endfunction

function! s:ReplacePercentWithFilename(input, filename) 
    " Escape the filename to avoid issues with special characters
    let l:filename = escape(a:filename, '\%')
    " Use substitute to replace % that are not preceded by \
    let l:result = substitute(a:input, '\\\@<!%', l:filename, 'g')
    return l:result
endfunction

function! s:RunLineToExecuteCommand(line, filename)
    let l:line = a:line
    let l:filename = a:filename
    let l:needle =  'run.vim:'
    let l:index = stridx(l:line, l:needle)
    let l:line = trim(strpart(l:line, l:index + len(l:needle)))
    " replace all '%' with filename unless it is escaped with '\'
    let l:line = s:ReplacePercentWithFilename(l:line, l:filename)
    return l:line
endfunction

function! s:Run3()
    " case 1: g:custom_runner, multi-file [non-vim]
    if g:custom_runner != "" && &ft != "vim"
        let l:command = s:ReplacePercentWithFilename(g:custom_runner, expand('%'))
        call execute(l:command)
        setlocal nonumber
        return
    " case 2: g:custom_runner, multi-file [vim]
    elseif g:custom_runner != "" && &ft == "vim"
        let l:command = s:ReplacePercentWithFilename(g:custom_runner, expand('%'))
        execute l:command
        return
    endif

    " case 3: run.vim:, single-file [non-vim]
    if stridx(getline("$"), "run.vim:") != -1
        let l:command = s:RunLineToExecuteCommand(getline("$"), expand('%'))
        call execute(l:command)
        setlocal nonumber
        return
    endif

    " case 4: default runner, single-file[ vim]
    if &ft == "vim"
        source %
        return
    endif

    " case 5: default runner, single-file [non-vim]
    let l:ft = &filetype
    let l:runners = s:GetRunners()
    let l:runner = get(l:runners, l:ft, "")
    if l:runner == ""
        echo "No runner found for filetype: " . l:ft
        return
    endif
    let l:command = 'vert term ' . s:ReplacePercentWithFilename(l:runner, expand('%'))
    call execute(l:command)
    setlocal nonumber

endfunction

nnoremap <Plug>Run3 :call <SID>Run3()<CR>
command! -complete=customlist,s:RunCreateCommandCompletion -nargs=? RunCreateCommand call s:RunCreateCommand(<f-args>)

" if v:vim_did_enter
"     Capture call s:RunLineToExecuteCommand('# run.vim: term \% python %', "test.py")
" endif

