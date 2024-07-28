function! s:Scriptnames()
    let string = execute('scriptnames')
    let lines = split(string, '\n')
    let dicts = []
    for line in lines
        let parts = split(line, ':')
        let script_id = str2nr(trim(parts[0]))

        " assert that script_id is an integer
        let remaining_parts = parts[1:]
        let path = expand(trim(join(remaining_parts, ':')))

        if type(script_id) != v:t_number
            echo printf('script_id is not a number: `%s`', script_id)
        endif
        if type(path) != v:t_string
            echo printf('path is not a string: %s', path)
        endif

        let path_dict = {'sid': script_id, 'path': path}
        call add(dicts, path_dict)
    endfor
    return dicts
endfunction

function! s:CallerSID()
    let l:scriptnames = s:Scriptnames()
    let full_path = expand('%:p')

    for dict in l:scriptnames
        let path = dict['path']
        let sid = dict['sid']
        if stridx(path, full_path) != -1
            return sid
            break
        endif
    endfor
    return -1
endfunction

function! s:Capture(command)
    let l:sid = s:CallerSID()
    " call s:PrintMappings() -> call <SNR>55_PrintMappings()
    let l:command = substitute(a:command, "call s:", printf("call <SNR>%d_", l:sid), "")
    let command_results = execute(l:command)
    new
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal nobuflisted

    call append(0, split(command_results, "\n"))
    setlocal nomodifiable
    1
endfunction

command! -nargs=1 Capture call s:Capture(<q-args>)
