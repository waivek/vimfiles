
" check if function: `utils#path_to_sid` is defined
" check if command: `Capture` is defined

function! s:Ensure()
    if !exists('*utils#path_to_sid') || !exists(':Capture')
        let s:script_basename = expand('<sfile>:t')
        let s:missing_messages = []
        if !exists('*utils#path_to_sid')
            call add(s:missing_messages, printf('[%s] Missing (function): utils#path_to_sid', s:script_basename))
        endif
        if !exists(':Capture')
            call add(s:missing_messages, printf('[%s] Missing (command) : Capture', s:script_basename))
        endif
        echo join(s:missing_messages, "\n")
    endif
endfunction


let s:script_directory = expand('<sfile>:p:h')
let s:script_basename = expand('<sfile>:t')

function! s:GetErrorFilePath()
    if has('win32') || has('win64')
        let l:separator = '\\'
    else
        let l:separator = '/'
    endif
    let l:filename = 'print-personal-commands-errors.txt'
    let l:file_path = s:script_directory . l:separator . l:filename
    return l:file_path
endfunction

function! s:WriteLinesToFileInSameDirectoryAsScript(lines, filename)
    let l:file_path = s:GetErrorFilePath()
    call writefile(a:lines, l:file_path)
endfunction

function! s:PrintPersonalCommandsSorted()
    let l:stdout = execute('verbose command')
    let l:lines = split(l:stdout, '\n')
    let l:lines = l:lines[1:]
    " assert assumptions {{{
    let l:line_1_pattern = '^[!| ]\{4\}[A-Z][a-zA-Z0-9]*\s*[01*?+]'
    let l:line2_prefix = 'Last set from'
    let l:errors = []
    for l:i in range(0, len(l:lines) - 1, 2)
        let l:line1 = l:lines[l:i]
        let l:line2 = l:lines[l:i + 1]
        if match(l:line1, l:line_1_pattern) == -1
            let l:error_message = printf('Line 1 does not match pattern: /%s/. Line 1: %s', l:line_1_pattern, l:line1)
            call add(l:errors, l:error_message)
        endif
        if stridx(l:line2, l:line2_prefix) == -1
            let l:error_message = printf('Line 2 does not start with: %s. Line 2: %s', l:line2_prefix, l:line2)
            call add(l:errors, l:error_message)
        endif
    endfor
    if len(l:errors) > 0
        " let l:error_string = join(l:errors, "\n")
        " echo l:error_string
        call s:WriteLinesToFileInSameDirectoryAsScript(l:errors, 'print-personal-commands-errors.txt')
        echoerr printf("[%s] Errors found. See %s for details.", s:script_basename, s:GetErrorFilePath())
        return
    endif
    " }}}


    let l:table = []
    for l:i in range(0, len(l:lines) - 1, 2)
        let l:line1 = l:lines[l:i]
        let l:line2 = l:lines[l:i + 1]
        let l:path = substitute(l:line2, '.*Last set from ', '', '')
        let [l:path, l:lnum] = split(l:path, ' line ')
        let l:path = expand(l:path)
        let l:sid = utils#path_to_sid(l:path)
        let l:command_name = matchstr(l:line1, '^[!| ]\{4\}\zs\w\+')
        " echo printf('%s: %s:%s %s', l:sid, l:path, l:lnum, l:command_name)
        let l:row = { 'sid': l:sid, 'path': l:path, 'lnum': l:lnum, 'command_name': l:command_name }
        call add(l:table, l:row)
    endfor

    call sort(l:table, { a, b -> a.sid == b.sid ? a.lnum > b.lnum : a.sid > b.sid }) " sort on sid then sort on lnum 
    let l:max_sid_length = max(mapnew(l:table, { idx, val -> len(val.sid) }))
    let l:max_path_lnum_length = max(mapnew(l:table, { idx, val -> len(printf('%s:%s', val.path, val.lnum)) }))

    for l:row in l:table
        let l:sid_with_padding = printf('%+*s', l:max_sid_length, l:row.sid)
        let l:path_lnum_with_padding = printf('%-*s', l:max_path_lnum_length, printf('%s:%s', l:row.path, l:row.lnum))
        echo printf('%s: %s %s', l:sid_with_padding, l:path_lnum_with_padding, l:row.command_name)
    endfor

    echo "Finished Iteration"

endfunction


if v:vim_did_enter
    " script names are not available until after vim has entered
    Capture call s:PrintPersonalCommandsSorted()
endif
