
function! s:ParseRunLine(line)
    " run.vim: | horizontal    # Default command, horizontal split
    " run.vim: go main.go | vertical  # Command with vertical split
    " run.vim: arbitrary echo 'hello' | horizontal  # Arbitrary command with horizontal split
    let l:line = a:line
    if count(l:line, '|') == 0
        let l:line = l:line . ' | vertical'
    endif
    let l:run_index = stridx(l:line, 'run.vim:')
    let l:line = trim(strpart(l:line, l:run_index + len('run.vim:')))
    echo l:line
    let l:tokens = split(l:line, '|', v:true)
    call map(l:tokens, 'trim(v:val)')
    if l:tokens[0] == ''
        let l:tokens[0] = 'default'
    endif
    if len(l:tokens) != 2
        let l:error_message = printf('Invalid run.vim line: %s', a:line)
        call utils#LogError(l:error_message, line("."), col("."), 's:ParseRunLine', 'run.vim')
        return
    endif
    echo string(l:tokens)
endfunction

function! s:DemonstrateParseRunLine()
    let l:lines = [ 'run.vim: | horizontal', 'run.vim: go main.go', 'run.vim: go main.go | vertical', 'run.vim: arbitrary echo "hello" | horizontal']
    for l:line in l:lines
        call s:ParseRunLine(l:line)
    endfor
endfunction

function! s:GetRunners()
    let l:ft_to_runner = {
                \ "python"     : "python %s",
                \ "javascript" : "node %s",
                \ "go"         : "go run %s",
                \ "sh"         : "bash -c 'source %s'"
                \ }
    return l:ft_to_runner
endfunction

function! s:ErrorDict(filename, funcname, line, col, message)
    return { 'filename': a:filename, 'funcname': a:funcname, 'line': a:line, 'col': a:col, 'message': a:message }
endfunction

function! s:TokensToCommandStringTemplate(tokens, filetype)
    let l:tokens = a:tokens
    let l:command = l:tokens[0]
    let l:split = l:tokens[1]
    let l:filetype = a:filetype
    if l:split == 'horizontal'
        let l:split = ''
    else
        let l:split = 'vertical'
    endif
    if l:command == 'default'
        let l:runners = s:GetRunners()
        if has_key(l:runners, l:filetype)
            let l:command = l:runners[l:filetype]
        else
            let l:available_runners = join(keys(l:runners), ', ')
            return [ '', printf("[run2.vim] (func=%s) No runner found for filetype: %s\nAvailable runners: %s" , 's:TokensToCommandStringTemplate', l:filetype, l:available_runners) ]
        endif
    endif
    let l:command_string = printf('%s term %s', l:split, l:command)
    return [ l:command_string, v:null ]
endfunction

function! s:RunVim()
    execute "source %"
endfunction

function! s:LineToCommand(line, filetype)
    let l:line = a:line
    let l:filetype = a:filetype
    if stridx(l:line, 'run.vim:') == -1
        let l:tokens = [ 'default', 'vertical' ]
    else
        let l:tokens = s:ParseRunLine(l:line)
    endif
    let [ l:command_string_template, l:err ] = s:TokensToCommandStringTemplate(l:tokens, l:filetype)
    if l:err != v:null
        echo l:err
        return
    endif
    let l:command_string = printf(l:command_string_template, expand('%'))
    return l:command_string
endfunction

function! s:Run2()
    if &ft == "vim"
        call s:RunVim()
        return
    endif
    let l:command_string = s:LineToCommand(getline("$"))
    execute l:command_string
endfunction

function! s:Tests()
    let l:lines = [ 
                \ '',
                \ 'run.vim: | horizontal', 
                \ 'run.vim: go main.go', 
                \ 'run.vim: go main.go | vertical', 
                \ 'run.vim: arbitrary echo "hello" | horizontal'
                \ ]
    for l:line in l:lines
        let l:command_string = s:LineToCommand(l:line)
        echo printf("Line = `%s`\nCommand = `%s`\n", l:line, l:command_string)
    endfor
endfunction

nmap <Plug>Run2 :call <SID>Run2()<CR>
if v:vim_did_enter
    call s:Tests()
endif

" command! TmpMain call s:Run2()

