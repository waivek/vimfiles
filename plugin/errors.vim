
function! s:UseListAsString()
    let y = '1' . []
endfunction

function! s:LineNumber()
    return substitute(v:throwpoint, '.*\D\(\d\+\).*', '\1', "")
endfunction

function! GlobalFunction(x)
    echo x
    call s:UseListAsString()
endfunction

function! s:PrintList(list, name)
    let l:list = a:list
    let l:name = a:name
    let l:strings = []
    call add(l:strings, printf("%s:\n", l:name))
    for l:index in range(len(l:list))
        call add(l:strings, printf("  [%d]: %s", l:index, l:list[l:index]))
    endfor
    call add(l:strings, "")
    let l:string = join(l:strings, "\n")
    echo l:string

endfunction

function! s:ListToPrintableString(list)
    let l:list = a:list
    let l:printable_string = ""
    for l:index in range(len(l:list))
        let l:printable_string .= printf("\n  [%d]: %s", l:index, l:list[l:index])
    endfor
    return l:printable_string
endfunction

function! s:BodyLineToDict(body_line)
    let l:body_line = a:body_line
    let l:pattern = '\s*\(\d\+\)\s\+\(.*\)'
    let l:matches = matchlist(l:body_line, l:pattern)
    let l:lnum_relative = str2nr(l:matches[1])
    let l:line = l:matches[2]
    return { 'lnum_relative': l:lnum_relative, 'line': l:line }
endfunction

function! s:FucntionLineToErrorDict(line)
    let l:line = a:line
    let l:pattern = '\(.*\)\[\(.*\)\]'
    let l:matches = matchlist(l:line, l:pattern)
    let l:function_name = l:matches[1]
    let l:lnum_relative = str2nr(l:matches[2])
    let l:verbose_function_string = trim(execute('verbose function ' . l:function_name))
    let l:lines = split(l:verbose_function_string, '\n')
    let l:signature = l:lines[0]
    let l:signature = trim(substitute(l:signature, '^\s*\(function\|lambda\)\s\+', '', ''))
    let l:filepath_temp = substitute(l:lines[1], '^\s*Last set from ', '', '')
    let [ l:filepath, l:lnum_function_signature ] = split(l:filepath_temp, ' line ')
    let l:lnum_function_signature = str2nr(l:lnum_function_signature)
    let l:filepath = expand(l:filepath)
    let l:lnum_file = l:lnum_relative + l:lnum_function_signature

    " filter for lines that start with a number
    let l:body = filter(l:lines, {_, v -> match(v, '^\d') != -1})
    call map(l:body, {_, v -> s:BodyLineToDict(v)})
    " find the entry in l:body which matches l:lnum_relative
    let l:list_of_one = filter(copy(l:body), {_, v -> v['lnum_relative'] == l:lnum_relative})
    let l:line = l:list_of_one[0]['line']
    let l:error_line_main = trim(printf("%s:%d ... %s", l:filepath, l:lnum_file, l:line))



    " echo printf("signature: `%s`", l:signature)
    return { 'path': printf("%s:%d", l:filepath, l:lnum_file), 'line': l:line, 'signature': l:signature }
endfunction

function! s:PrintStackTrace(throwpoint)
    let l:error_string = a:throwpoint
    " echo printf("error_string: `%s`", l:error_string)
    let l:lines = split(l:error_string, '\.\.')
    let l:lines[-1] = substitute(l:lines[-1], ', line \(\d\+\)', '[\1]', '')
    call map(l:lines, {_, v -> substitute(v, '^function ', '', '')})
    call filter(l:lines, {_, v -> stridx(v, '/') == -1 && stridx(v, '\') == -1})
    let l:error_dicts = []
    for l:line in l:lines
        let l:error_dict = s:FucntionLineToErrorDict(l:line)
        call add(l:error_dicts, l:error_dict)
    endfor

    let l:pwd = getcwd()
    if has('win32')
        let l:separator = '\'
    else
        let l:separator = '/'
    endif
    call map(l:error_dicts, {_, v -> extend(v, {'path': substitute(v['path'], l:pwd . l:separator, '', '')})})

    let l:max_length_path = max(map(copy(l:error_dicts), {_, v -> strlen(v['path'])}))
    let l:max_length_line = max(map(copy(l:error_dicts), {_, v -> strlen(v['line'])}))
    let l:max_length_signature = max(map(copy(l:error_dicts), {_, v -> strlen(v['signature'])}))

    let l:index = 0
    for l:error_dict in l:error_dicts
        let l:path = l:error_dict['path']
        let l:line = l:error_dict['line']
        let l:signature = l:error_dict['signature']
        let l:padding_path = repeat(' ', l:max_length_path - strlen(l:path))
        let l:padding_line = repeat(' ', l:max_length_line - strlen(l:line))
        let l:padding_signature = repeat(' ', l:max_length_signature - strlen(l:signature))
        " echo printf("    %s%s ... %s%s", l:path, l:padding_path, l:line, l:padding_line)
        echohl Comment
        let l:first_character = l:index == len(l:error_dicts) - 1 ? '└' : '├'
        let l:leading_characters = repeat(' ', 1) . l:first_character . repeat('─', 1) . repeat(' ', 1)
        echo printf(l:leading_characters . "%s%s", l:path, l:padding_path)
        echohl None
        echon " ... "
        echohl None
        echon printf("%s%s", l:line, l:padding_line)
        echohl None
        echon " "
        echohl Type
        echon l:signature
        echohl None
        let l:index = l:index + 1
    endfor

    " echo printf("\nl:lines:\n %s", s:ListToPrintableString(l:lines))
    " call s:PrintList(l:lines, "l:lines")
    " let l:function_lines = slice(l:lines, 1)
    " echo printf("function_lines: `%s`", string(l:function_lines))
endfunction

function! errors#pretty_traceback(exception, throwpoint)
    let l:exception = a:exception
    let l:throwpoint = a:throwpoint
    let l:first_space = stridx(l:exception, ' ')
    let l:exception_left = trim(strpart(l:exception, 0, l:first_space))
    let l:exception_right = trim(strpart(l:exception, l:first_space + 1))
    echohl Error | echon l:exception_left | echohl Type | echon ' ' . l:exception_right | echohl None
    call s:PrintStackTrace(l:throwpoint)
endfunction

function! s:Main()
    try
        call GlobalFunction(1)
    catch 
        echo printf("v:errors: `%s`\n", v:errors)
        call errors#pretty_traceback(v:exception, v:throwpoint)
    endtry
endfunction

if v:vim_did_enter
    call s:Main()
endif
