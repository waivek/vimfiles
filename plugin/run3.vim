
if !exists('g:custom_runner')
    let g:custom_runner = ""
endif

function! s:GetRunners()
    let l:ft_to_runner = {
                \ "python"     : "vert term python %",
                \ "javascript" : "vert term node %",
                \ "go"         : "vert term go run %",
                \ "sh"         : "vert term bash -c 'source %'",
                \ }
    return l:ft_to_runner
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
    let l:command = s:ReplacePercentWithFilename(l:runner, expand('%'))
    call execute(l:command)
    setlocal nonumber

endfunction

nnoremap <Plug>Run3 :call <SID>Run3()<CR>

" if v:vim_did_enter
"     Capture call s:RunLineToExecuteCommand('# run.vim: term \% python %', "test.py")
" endif

