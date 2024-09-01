" echo printf("[%s] Line 1", expand("<sfile>:t"))

" utils#sid_to_path {{{
let s:sid_to_path = {}
let s:path_to_sid = {}
function! s:InitializeScriptDicts()
    let string = execute('scriptnames')
    let lines = split(string, '\n')
    let dicts = []
    let l:sid_to_path = {}
    let l:path_to_sid = {}
    for line in lines
        let parts = split(line, ':')
        let script_id = str2nr(trim(parts[0]))
        " assert that script_id is an integer
        let remaining_parts = parts[1:]
        let path = expand(trim(join(remaining_parts, ':')))

        " assertions {{{
        if type(script_id) != v:t_number
            echo printf('script_id is not a number: `%s`', script_id)
        endif
        if type(path) != v:t_string
            echo printf('path is not a string: %s', path)
        endif
        " }}}

        let path_dict = {'sid': script_id, 'path': path}
        call add(dicts, path_dict)
        let l:sid_to_path[script_id] = path
        let l:path_to_sid[path] = script_id
    endfor
    let s:sid_to_path = l:sid_to_path
    let s:path_to_sid = l:path_to_sid
endfunction

function! utils#sid_to_path(sid)
    if empty(s:sid_to_path)
        call s:InitializeScriptDicts()
    endif
    return s:sid_to_path[a:sid]
endfunction

function! utils#path_to_sid(path)
    if empty(s:path_to_sid)
        call s:InitializeScriptDicts()
    endif
    return s:path_to_sid[a:path]
endfunction
" }}}

function! utils#print_tuple_table(tuples)
    let max_lengths = {}
    for tuple in a:tuples
        for i in range(len(tuple))
            let value = tuple[i]
            let length = strlen(string(value))
            if !has_key(max_lengths, i) || max_lengths[i] < length
                let max_lengths[i] = length
            endif
        endfor
    endfor

    for tuple in a:tuples
        let line = ''
        for i in range(len(tuple))
            let value = tuple[i]
            let length = max_lengths[i]
            let padding = repeat(' ', length - strlen(string(value)))
            if type(value) == v:t_string
                let line .= value . padding . '  '
            else
                let line .= string(value) . padding . '  '
            endif
        endfor
        echo line
    endfor
endfunction

function! utils#FindRoot()
    let l:root = finddir('.git/..', expand('%:p:h') . ';')
    if l:root == ''
        return ''
    endif
    return fnamemodify(l:root, ':p')
endfunction
