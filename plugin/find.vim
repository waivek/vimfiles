
" Fields:
"
"     abspath: The absolute path to the file (:p)
"     basename: The basename of the file (:t)
"     relpath: The relative path to the file (:.)
"     modified: The modified time of the file getftime(v:val)
"     is_duped: Whether the file is duplicated
"     repr: The string representation of the file
" 
" Operations:
"
"    uniq: Remove duplicates

function! s:DoGlob()
    let nosuf = v:true
    let aslist = v:true
    let paths = globpath(&path, "*", nosuf, aslist)
    let isfile = 'filereadable(v:val) && !isdirectory(v:val)'
    call filter(paths, isfile)
    call map(paths, 'fnamemodify(v:val, ":p")')
    call uniq(sort(paths)) " We remove the ./item.txt and /home/user/item.txt duplicates where `pwd` is /home/user
    let basenames = mapnew(paths, 'fnamemodify(v:val, ":t")')
    let relpaths = mapnew(paths, 'fnamemodify(v:val, ":.")')
    let modifieds = mapnew(paths, 'getftime(v:val)')
    let basenames_counts = {}
    for b in basenames
        let basenames_counts[b] = get(basenames_counts, b, 0) + 1
    endfor
    let is_duped = mapnew(basenames, 'basenames_counts[v:val] > 1')
    let results = []
    for i in range(len(paths))
        let result = {}
        let result.abspath = paths[i]
        let result.basename = basenames[i]
        let result.relpath = relpaths[i]
        let result.modified = modifieds[i]
        let result.is_duped = is_duped[i]
        if is_duped[i]
            let result.repr = s:ContainsSep(result.relpath) ? result.relpath : "./" . result.relpath " `find` command with duplicates takes 'item.txt' as a glob instead of a path
        else
            let result.repr = result.basename
        endif
        call add(results, result)
    endfor
    call sort(results, 'a:1.modified < a:2.modified')
    return results
endfunction

function! s:GlobBasenames(abspaths)
    let regex = substitute(a:glob, '\.', '\\.', "g")
    " f*x -> f.*x
    let regex = substitute(regex, "*", ".*", "g")
    let pattern_string = '\<' . regex
    let match_basename_in_abspath_fn = 'fnamemodify(v:val, ":t") =~# pattern_string'
    let filtered_abspaths = filter(copy(a:abspaths), match_basename_in_abspath_fn)
    return filtered_abspaths

endfunction

function! s:FindFilesSource(glob)
    let nosuf = v:true
    let aslist = v:true
    let paths = globpath(&path, "*", nosuf, aslist)
    let isfile = 'filereadable(v:val) && !isdirectory(v:val)'
    call filter(paths, isfile)
    call map(paths, 'fnamemodify(v:val, ":p")')
    call uniq(sort(paths)) " We remove the ./item.txt and /home/user/item.txt duplicates where `pwd` is /home/user

    let basenames = mapnew(paths, 'fnamemodify(v:val, ":t")')

    " file.c -> file\.c
    let regex = substitute(a:glob, '\.', '\\.', "g")
    " f*x -> f.*x
    let regex = substitute(regex, "*", ".*", "g")
    let pattern_string = '\<' . regex
    let isk_save=&iskeyword
    set isk-=_
    set isk-=-
    let basenames = filter(basenames, 'v:val =~# pattern_string')
    let sorted_basenames = sort(copy(basenames))
    let basename_counts = {}
    for b in sorted_basenames
        let basename_counts[b] = get(basename_counts, b, 0) + 1
    endfor
    let duplicates = filter(copy(sorted_basenames), 'basename_counts[v:val] > 1')

    let basenames_without_duplicates = filter(sorted_basenames, 'index(duplicates, v:val) == -1')

    " `filtered_paths` - Thos `paths` that have a baseanme in `duplicates`
    let filtered_paths = filter(copy(paths), 'index(duplicates, fnamemodify(v:val, ":t")) != -1')
    call map(filtered_paths, 'fnamemodify(v:val, ":.")')
    call map(filtered_paths, 's:ContainsSep(v:val) ? v:val : "./" . v:val')

    let results = basenames_without_duplicates + filtered_paths

    let &iskeyword=isk_save
    return results
endfunction


function! FindCompletion(ArgLead, CmdLine, CursorPos)
    let results = s:FindFilesSource(a:ArgLead)
    if len(results) == 1
        call s:ClosePopup(v:true)
        return results
    else
        call feedkeys("\<Tab>")
        return results
    endif
endfunction

function! s:ContainsSep(path)
    let sep = has('win32') ? '\' : '/'
    let contains_sep = stridx(a:path, sep) != -1
    return contains_sep
endfunction

function! Find(filename)
    call s:ClosePopup(v:true)
    if s:ContainsSep(a:filename)
        execute "find " . a:filename
        return
    endif
    let results = s:FindFilesSource(a:filename)
    let result = results[0]
    execute "find " . result
endfunction

let s:popup_id = -1

function! s:ClosePopup(redraw=v:false)
    if s:popup_id != -1
        call popup_close(s:popup_id)
        let s:popup_id = -1
    endif
    if a:redraw
        redraw
    endif
endfunction

function! s:OpenPopup(string="a single line of text", redraw=v:true)
    let l:popup_id = popup_create(a:string, {"borderhighlight": ["StatusLineNC"], "line" : &lines, "col": 1, "zindex": 1 })
    let s:popup_id = l:popup_id
    call setwinvar(l:popup_id, '&wincolor', 'String')
    if a:redraw
        redraw
    endif
endfunction

function! s:GuiIfCommand(command)

    let cmd = a:command
    let length = len(cmd)
    let cmdline = getcmdline()

    if s:popup_id == -1 && strpart(cmdline, 0, length) !=# cmd
        return
    endif
    if s:popup_id == -1 && cmdline ==# cmd
        call s:OpenPopup("a single line of text", v:false)
    endif
    if len(cmdline) < length
        call s:ClosePopup(v:true)
    endif
    if s:popup_id != -1 && wildmenumode()
        call s:ClosePopup(v:true)
    endif

    if s:popup_id != -1
        call popup_move(s:popup_id, { "col": length + 1 + len(cmdline) })
        let cmdline_glob = trim(strpart(cmdline, length))
        let results = s:FindFilesSource(cmdline_glob)
        if !empty(results)
            call popup_settext(s:popup_id, results[0])
            call setwinvar(s:popup_id, '&wincolor', 'String')
        else
            call popup_settext(s:popup_id, "No results")
            call setwinvar(s:popup_id, '&wincolor', 'WarningMsg')
        endif
    endif

    if s:popup_id != -1
        if has("gui_running")
            redraws
        else
            redraw
        endif
    endif

endfunction

" command! FIND call Find()

" Add FindCompletion to the list of completion functions

command! -nargs=1 -complete=customlist,FindCompletion FIND call Find(<q-args>)

augroup FindPopup
    au!
    au CmdlineChanged : call s:GuiIfCommand("FIND")
    au CmdLineLeave   : call s:ClosePopup()
    au CmdlineChanged : call timer_start(0, {_-> _})
augroup END


