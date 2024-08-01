
function! s:GetSidToPath()
    let string = execute('scriptnames')
    let lines = split(string, '\n')
    let dicts = []
    let sid_to_path = {}
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
        let sid_to_path[script_id] = path
    endfor
    return sid_to_path
endfunction

function! s:Omit(dict, keys)
    let new_dict = copy(a:dict)
    for key in a:keys
        call remove(new_dict, key)
    endfor
    return new_dict
endfunction

function! s:GetPrintDictLines(d, indent)
    let l:print_lines = []
    let l:indent_str = repeat(' ', a:indent)
    let l:sorted_keys = sort(keys(a:d))
    for l:key in l:sorted_keys
        let l:val = a:d[l:key]
        if type(l:val) == v:t_dict
            call add(l:print_lines, l:indent_str . l:key . ':')
            call add(l:print_lines, s:GetPrintDictString(l:val, a:indent + 4))
        else
            call add(l:print_lines, l:indent_str . l:key . ': ' . l:val)
        endif
    endfor
    return l:print_lines
endfunction

function! s:PrintDict(d, indent)
    let l:print_lines = s:GetPrintDictLines(a:d, a:indent)
    for l:line in l:print_lines
        echo l:line
    endfor
endfunction

" constants:
"   abbr: always 0
"   scriptversion: always 1
" args: 
"   abbr: always 0
"   buffer: 0 | 1
"   expr: 0 | 1
"   noremap: 0 | 1
"   nowait: 0 | 1
"   script: 0 | 1
"   silent: 0 | 1
"   mode: combination of [nvsoict! ]
"
"
function! s:MapArgsToMapCommandString(abbr, buffer, expr, noremap, nowait, script, silent, mode, lhs, rhs)

    " mode: combination of [nvsoict! ]
    " if ! in mode, then suffix with '!'
    " if mode is space then no prefix
    " if mode has comb
    let l:mode_chars = split(a:mode, '\zs')
    let l:suffix_required = index(l:mode_chars, '!') != -1
    let l:command_parts = []
    for l:mode_char in l:mode_chars
        let l:parts = []
        call add(l:parts, trim(l:mode_char))
        if a:noremap
            call add(l:parts, 'nore')
        endif
        if a:abbr
            call add(l:parts, 'abbrev')
        else
            call add(l:parts, 'map')
        endif
        if l:suffix_required
            call add(l:parts, '!')
        endif
        call add(l:command_parts, join(l:parts, ''))
    endfor

    " "<buffer>", "<nowait>", "<silent>", "<special>", "<script>", "<expr>" and
    " "<unique>" can be used in any order.  They must appear right after the
    " command, before any other arguments.
    if a:buffer
        call add(l:command_parts, '<buffer>')
    endif
    if a:expr
        call add(l:command_parts, '<expr>')
    endif
    if a:nowait
        call add(l:command_parts, '<nowait>')
    endif
    if a:script
        call add(l:command_parts, '<script>')
    endif
    if a:silent
        call add(l:command_parts, '<silent>')
    endif

    call add(l:command_parts, a:lhs)
    call add(l:command_parts, a:rhs)

    return join(l:command_parts, ' ')
endfunction

function! s:CategorizeMap(map_path)
    " categories: Personal, Plugin, System
    " plugin are if startswith ~/.vim/plugged
    " system are if startswith $VIMRUNTIME
    let plugin_path = expand('~/.vim/plugged')
    let system_path = $VIMRUNTIME
    if stridx(a:map_path, plugin_path) == 0
        return 'Plugin'
    elseif stridx(a:map_path, system_path) == 0
        return 'System'
    else
        return 'Personal'
    endif
endfunction


function! s:PrintPersonalMappingsSorted()

    let l:sid_to_path = s:GetSidToPath()
    let l:maplist = maplist(v:false)
    let l:abbrevlist = maplist(v:true)
    let l:list = l:maplist + l:abbrevlist
    call filter(l:list, {_, v -> v.sid != 0}) " filter out mappings that were set from the command line
    call sort(l:list, { a, b -> a.sid == b.sid ? a.lnum > b.lnum : a.sid > b.sid }) " sort on sid then sort on lnum
    call filter(l:list, {_, v -> s:CategorizeMap(l:sid_to_path[v.sid]) == 'Personal'}) " filter for personal mappings

    let max_path_length = max(mapnew(l:list, {_, v -> strlen(l:sid_to_path[v.sid])})) + len(":100")

    for l:map in l:list

        let l:parts = []

        call add(l:parts, printf("%3d:", l:map.sid))

        let l:path = l:sid_to_path[l:map.sid]
        let path_string = printf("%s:%d", l:path, l:map.lnum)
        let path_string_padded = printf("%-*s", max_path_length, path_string)
        call add(l:parts, path_string_padded)

        call add(l:parts, s:MapArgsToMapCommandString(l:map.abbr, l:map.buffer, l:map.expr, l:map.noremap, l:map.nowait, l:map.script, l:map.silent, l:map.mode, l:map.lhs, l:map.rhs))
        echo join(l:parts, ' ')

    endfor
endfunction

" GUI Filter: [ ] Personal [ ] Plugin [ ] System
" GUI Filter: [ ] Insert [ ] Normal [ ] Visual [ ] Select [ ] Operator-pending [ ] Command-line [ ] Terminal


command! PrintPersonalMappings call s:PrintPersonalMappingsSorted()

if v:vim_did_enter
    " script names are not available until after vim has entered
    Capture call s:PrintPersonalMappingsSorted()
endif
