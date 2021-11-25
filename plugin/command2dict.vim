" s:ListCursorAutocommands() {{{
" [au_group] | Cool  CursorMoved
" [au_cmd]   |    *         call <SID>StartHL()
function! s:ListCursorAutocommands()
    let l:messages = ""
    redir => l:messages
    " silent au CursorMoved
    " silent au CursorMovedI
    " silent au TextChanged
    " silent au TextChangedI
    " silent au InsertChange
    " silent au InsertCharPre
    silent verbose au
    redir END
    " echo split(l:messages, "\n")[0] ==# "--- Autocommands ---"
    let l:lines = split(l:messages, "\n")
    let @" = join(l:lines, "\n")
    return
    call filter(l:lines, 'v:val !=# "--- Autocommands ---"')
    " let @a = join(l:lines, "\n")
    let l:key = ""
    let l:stack = []
    for l:line in l:lines
        if l:line[0] !=# " "
            if count(l:line, " ") > 0
                let [custom_name, au_group] = split(l:line, '\s\+')
            else
                let [custom_name, au_group] = [ "", l:line ]
            endif
            call add(l:stack, {"au_group": au_group, "custom_name": custom_name, "au_commands": []})
            echo {"au_group": au_group, "custom_name": custom_name, "au_commands": []}
        endif
    endfor
endfunction
" let s:hack = []
" call add(s:hack, {"name": "Vivek"})
" let s:hack[-1]["surname"] = "Bose"
" call add(s:hack, {"name": "Rian"})
" let s:hack[-1]["surname"] = "Neogi"
" }}}

function! s:GetFiletype(path)
    let path = a:path
    let VIMRUNTIME = 'C:\Program Files (x86)\Vim\vim82'
    let PACKPATH = '~\vimfiles\pack'
    let VIMRC = '~\vimfiles\vimrc'
    let PERSONAL = '~\vimfiles\plugin'
    if stridx(path, VIMRUNTIME) > -1
        let filetype = "runtime"
    elseif stridx(path, PACKPATH) > -1
        let filetype = "external"
    elseif stridx(path, VIMRC) > -1
        let filetype = "personal"
    elseif stridx(path, PERSONAL) > -1
        let filetype = "personal"
    else
        let filetype = "unhandled"
    endif
    return filetype
endfunction

function! s:ProcessLastSetFromLine(line)
    let line = trim(a:line)
    let match_1 = substitute(line, '^\s*Last set from \(.*\) line \d\+$', '\=submatch(1)', "")
    let match_2 = substitute(line, '^\s*Last set from \(.*\) line \(\d\+\)$', '\=submatch(2)', "")
    return [ match_1, str2nr(match_2) ]
endfunction

function! s:SortOnPathThenLineNumber(lhs, rhs)
    if a:lhs["path"] > a:rhs["path"]
        return 1
    elseif a:lhs["path"] < a:rhs["path"]
        return -1
    endif

    if a:lhs["line_number"] > a:rhs["line_number"]
        return 1
    elseif a:lhs["line_number"] < a:rhs["line_number"]
        return -1
    endif

    return 0
endfunction
" s:GetFunctionDictionaries() {{{
function! s:GetFunctionDictionaries()
    let l:messages = ""
    redir => l:messages
    silent verbose function
    redir END
    let lines = split(l:messages, "\n")
    let total_lines = len(lines)
    let line_pairs = []
    for i in range(total_lines)
        let line = lines[i]
        if i % 2 == 0
            call add(line_pairs, [line])
        else
            call add(line_pairs[-1], line)
        endif
    endfor
    let dictionaries = []
    for pair in line_pairs
        let [fn_line, verbose_line] = pair

        let [ path, line_number ] = s:ProcessLastSetFromLine(verbose_line)
        let filetype = s:GetFiletype(path)
        let function_type = stridx(fn_line, "<SNR>") > -1 ? "script-only" : "global"

        call add(dictionaries, { "fn_line": fn_line, "path": path, "line_number": line_number, "filetype": filetype, "function_type": function_type})
    endfor
    return dictionaries
endfunction

let g:qf_dicts = []
function! s:FindPersonalFunctions(key)
    let key = a:key
    let dictionaries = s:GetFunctionDictionaries()
    call filter(dictionaries, { index, D -> D["filetype"] ==# "personal" })
    call sort(dictionaries, function("s:SortOnPathThenLineNumber"))

    let qf_dictionaries = []
    for D in dictionaries
        " if D["filetype"] ==# "personal" && D["function_type"] ==# "global"
        "     call add(print_lines, D["path"]." | ".D["fn_line"])
        " endif
        if stridx(D["fn_line"], key) > -1
            " let qf_D = {'lnum': D["line_number"], 'col': 1, 'pattern': key, 'module': D["path"], 'text': D["fn_line"], 'filename': glob(D["path"]) }
            let qf_D = {'lnum': D["line_number"], 'col': 1, 'module': D["path"], 'text': D["fn_line"], 'filename': glob(D["path"]) }
            call add(qf_dictionaries, qf_D)
        endif
    endfor
    let g:qf_dicts = qf_dictionaries
    call setqflist(qf_dictionaries)
    copen
endfunction
command! -nargs=1 FindPersonalFunctions call <SID>FindPersonalFunctions(<q-args>)

" echo s:SID()
" let verbose_line = '	Last set from ~\vimfiles\pack\plugins\start\vim-lsp\autoload\lsp.vim line 899'
" call s:ProcessLastSetFromLine(verbose_line)
" }}}

if !exists("s:script_D") || len(s:script_D) == 0
    let s:script_D = {} 
endif
function! s:PopulateScriptnamesDictionary()
    let l:messages = ""
    redir => l:messages
    silent scriptnames
    redir END
    let lines = split(l:messages, "\n")
    let total_lines = len(lines)
    let lines = lines
    for line in lines
        let first_colon_index = stridx(line, ":")
        let sid = trim(strpart(line, 0, first_colon_index))
        let path = trim(strpart(line, first_colon_index+1))
        let key = glob(path)
        let s:script_D[key] = sid
    endfor
endfunction


function! GetSid(path)
    if !exists("s:script_D") || len(s:script_D) == 0
        call s:PopulateScriptnamesDictionary()
    endif
    let path = a:path
    let path = glob(path)
    if has_key(s:script_D, path)
        return str2nr(s:script_D[path])
    else
        return  -1
    endif
endfunction
" let s:test_path = '~\vimfiles\plugin\dotty.vim'
" call GetSid(s:test_path)
