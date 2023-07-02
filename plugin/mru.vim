" For debugging:
"
"   map gt to UI()
"   map ga, gr to Reset()
"   set global_glob in the vim file itself, above UI() function

" :e   - Edit file in current directory or relative path
" :fi  - Find file 'path'
" :b   - Go to loaded buffer
" :MRU - Filter v:oldfiles
" Log access count via :e :b :MRU len(undolist)

function! s:GetStrBeforeColon(str)
    let colon_pos = match(a:str, ":")
    let fname = a:str[:colon_pos-1]
    return fname
endfunction
" For empty string open's first file
function! s:MruFunction(args)
    " They entered a full file name like `cs.vim`
    let fname = ''
    if match(a:args, ":") == -1
        let filenames = s:MruCompletion(a:args, 0, 0)
        " There is at least one result
        if !empty(filenames)
            let fname = filenames[0]
        endif
    else
        let fname = a:args
    endif
    if !empty(fname)
        let pos_plus_one = s:GetStrBeforeColon(fname)
        call s:CloseUI2Popup(v:true)

        let path = v:oldfiles[pos_plus_one-1]
        if bufexists(expand(path))
            execute "b " . path
        else
            execute "edit " . v:oldfiles[pos_plus_one-1]
        endif
    else
        echo "Invalid Input"
    endif
endfunction

function! s:Draw(list_or_string)
    return popup_create(a:list_or_string, #{ maxwidth: 60, minwidth: 60, padding : [3,4,2,4], title: "Recent Files", scrollbar: 0})
endfunction
function! s:Reset()
    call popup_clear()
endfunction


function! s:GetExistingOldFilesDictionaries()
    let start_time = reltimefloat(reltime())
    let is_windows = has('win32') || has('win64')
    let l:home = is_windows ? escape(expand("~"), '\') : expand("~")
    let l:pattern = "^\\~"
    let expanded_paths = map(copy(v:oldfiles), 'substitute(v:val, l:pattern, l:home, "")') " we use substitute instead of escape for faster but less accurate result
    let paths = filter(expanded_paths, 'filereadable(v:val)')
    let time_taken = reltimefloat(reltime()) - start_time


    let l:a1 = map(copy(v:oldfiles), '{"oldfiles_index": v:key+1, "uniquetail": fnamemodify(v:val, ":t"), "tail": fnamemodify(v:val, ":t"), "text": substitute(v:val, l:pattern, l:home, "")  }')
    let l:filtered_a3 = filter(copy(l:a1), 'filereadable(v:val["text"])')
    return l:filtered_a3
endfunction


" Introducing Latency for startup but worth it to remove the lag when typing MRU
let g:existing_oldfiles = v:null
augroup UpdateOldfilesOnStartup
    au!
    au VimEnter * let g:existing_oldfiles = s:GetExistingOldFilesDictionaries()
augroup END

let g:results_D = {}
function! s:OldFilesSource(glob="*", get_first_match=v:false)
    " We don’t want general regex. We want specific queries. 
    " Ideally, 
    "
    "   `uti` should match twitch_utilities
    "   `twi` should also match twitch_utilites
    "   *.txt should match all text files
    "   `uti` should NOT match lutils
    "
    " Primary use point is by wildcard for extensions and word boundaries
    let MinusOne = { s -> strpart(s, 0, len(s)-1) }
    if !exists("g:existing_oldfiles")
        let g:existing_oldfiles = s:GetExistingOldFilesDictionaries()
    endif

    " file.c -> file\.c
    let regex = substitute(a:glob, '\.', '\\.', "g")
    " f*x -> f.*x
    let regex = substitute(regex, "*", ".*", "g")

    let pattern_string = '\<' . regex

    " NOTE: We are using 1-indexing instead of ZERO for UI in wildcharm, so that we have 1:first_file.txt instead of 0:first_file.txt
    " Even though, we lose the ability to do v:oldfiles_index[index] as we are now off by one.
    let isk_save=&iskeyword
    set isk-=_

    " Implementation 2: Fast filter method
    " let filenames = filter(copy(g:existing_oldfiles), 'v:val["tail"] =~# pattern_string')

    " Implementation 3: Fast-er filtering with caching
    let previous_regex = MinusOne(regex)
    if has_key(g:results_D, previous_regex)
        let tails_copy = copy(g:results_D[previous_regex])
    else
        let tails_copy = copy(g:existing_oldfiles)
    endif
    let filenames = filter(tails_copy, 'v:val["tail"] =~# pattern_string')
    if !has_key(g:results_D, regex)
        let g:results_D[regex] = copy(filenames)
    endif

    let &iskeyword=isk_save
    return filenames 
endfunction
" let oldfiles = s:OldFilesSource()
" echo "oldfiles[0]: " . string(oldfiles[0])
" echo "len(oldfiles): " . string(len(oldfiles))

function! s:MruCompletion (ArgLead, CmdLine, CursorPos)
    let filename_dictionaries = s:OldFilesSource(a:ArgLead)
    if len(filename_dictionaries) < 100
        let filename_dictionaries = s:IncrementUntilUnique(filename_dictionaries)
    endif
    let filenames = []
    for filename_D in filename_dictionaries
        " {'oldfiles_index': 1, 'text': '~\vimfiles\plugin\mru.vim'}
        let filename = filename_D["oldfiles_index"].":".filename_D["uniquetail"]
        call add(filenames, filename)
    endfor
    call feedkeys("\<Tab>")
    " call feedkeys("\<S-Tab>")
    return filenames
endfunction

let global_glob = "*.txt"
let global_glob = "uti"
let global_glob = "failingquery"
let global_glob = "uti"
" let global_glob = "html.vim"

function! s:CloseUI2Popup(redraw=v:false)
    if g:ui2_popup_id != -1
        call popup_close(g:ui2_popup_id)
        let g:ui2_popup_id = -1
    endif
    if a:redraw
        redraw
    endif
endfunction
function! s:UI2(string="single line of text", redraw=v:true)
    " let popup_id = popup_create(a:string, {"borderhighlight": ["StatusLineNC"], "line" : winheight(0)+2, "col": 1, "zindex": 1 })
    let popup_id = popup_create(a:string, {"borderhighlight": ["StatusLineNC"], "line" : &lines, "col": 1, "zindex": 1 })
    let g:ui2_popup_id = popup_id
    call setwinvar(popup_id, '&wincolor', 'String')
    if a:redraw
        redraw
    endif
endfunction

function! s:GuiIfMru()
    if getcmdtype() !=# ":"
        return
    endif
    let cmdline = getcmdline()
    if g:ui2_popup_id == -1 && strpart(cmdline, 0, 3) !=# "MRU"
        return
    endif
    if g:ui2_popup_id == -1 && cmdline ==# "MRU"
        call s:UI2("a single line of text", v:false)
    endif
    if len(cmdline) < 3
        call s:CloseUI2Popup(v:true)
    endif
    let cmdline_glob = trim(strpart(cmdline, 3))
    if g:ui2_popup_id != -1 && match(cmdline_glob, '^\d\+:') > -1
        call s:CloseUI2Popup(v:true)
    endif

    let hl_groups = [ "WarningMsg", "VisualNOS" ]
    if g:ui2_popup_id != -1
        let filename_dictionaries = s:OldFilesSource(cmdline_glob, v:true) " OldFilesSource(glob, get_first_match)
        call popup_move(g:ui2_popup_id, {"col" : 4 + len(cmdline)})


        if !empty(filename_dictionaries)
            let filename_text = filename_dictionaries[0]["text"]
            let tail = fnamemodify(filename_text, ":t")
            call popup_settext(g:ui2_popup_id, tail)
            " echoerr "text: " . l:tail
            call setwinvar(g:ui2_popup_id, '&wincolor', 'String')
        else
            call popup_settext(g:ui2_popup_id, "No matches")
            call setwinvar(g:ui2_popup_id, '&wincolor', 'WarningMsg')
        endif
        if has("gui_running")
            redraws
        else
            redraw
        endif
    endif
endfunction

" Doesn’t work all the way till C:\
function! s:FastIncrementTailDepth(tail, absolute_path)
    let tail_length = len(a:tail)
    let nontail = a:absolute_path[0:-tail_length-1]
    return split(nontail, "\\")[-1]."\\".a:tail
endfunction
" Test FastIncrementTailDepth {{{
" let fullpath = 'C:\Program Files (x86)\Vim\vim82\doc\eval.txt'
" let tail1 = s:FastIncrementTailDepth("", fullpath)
" let tail2 = s:FastIncrementTailDepth(tail1, fullpath)
" let tail3 = s:FastIncrementTailDepth(tail2, fullpath)
" let tail4 = s:FastIncrementTailDepth(tail3, fullpath)
" let tail5 = s:FastIncrementTailDepth(tail4, fullpath)
" let tail6 = s:FastIncrementTailDepth(tail5, fullpath)
" let tail7 = s:FastIncrementTailDepth(tail6, fullpath)
" echo tail1
" echo tail2
" echo tail3
" echo tail4
" echo tail5
" echo tail6
" echo tail7
" }}}
" echo tail1
" for i in range(1)
"     let tail1 = s:FastIncrementTailDepth(tail1, fullpath)
"     echo tail1
" endfor




function! s:IncrementTailDepth(tail, absolute_path)
    if a:tail == ""
        return fnamemodify(a:absolute_path, ":t")
    endif
    if a:tail ==# a:absolute_path
        return a:tail
    endif
    let relative_parent = strpart(a:absolute_path, 0, len(a:absolute_path)-len(a:tail)-1)
    let new_tail = fnamemodify(relative_parent, ":t")
    if &shellslash
        return new_tail . '/' . a:tail
    else
        return new_tail . '\' . a:tail
    endif
endfunction
" Test IncrementTailDepth {{{
" let fullpath = 'C:\Program Files (x86)\Vim\vim82\doc\eval.txt'
" let tail1 = s:IncrementTailDepth("", fullpath)
" let tail2 = s:IncrementTailDepth(tail1, fullpath)
" let tail3 = s:IncrementTailDepth(tail2, fullpath)
" let tail4 = s:IncrementTailDepth(tail3, fullpath)
" let tail5 = s:IncrementTailDepth(tail4, fullpath)
" let tail6 = s:IncrementTailDepth(tail5, fullpath)
" let tail7 = s:IncrementTailDepth(tail6, fullpath)
" echo tail1
" echo tail2
" echo tail3
" echo tail4
" echo tail5
" echo tail6
" echo tail7
" }}}

function! s:IncrementTails(dicts)
    let filename_dictionaries = a:dicts
    let filename2_dictionaries = []
    for filename_D in filename_dictionaries
        let tail = filename_D["uniquetail"]
        let path = filename_D["text"]
        if tail == "" || tail ==# path || stridx(path, "\\") == -1
            call add(filename2_dictionaries, filename_D)
        else
            let filename_D["uniquetail"] = s:FastIncrementTailDepth(tail, path)
            call add(filename2_dictionaries, filename_D)
        endif
    endfor
    return filename2_dictionaries
endfunction
function! s:IncrementUntilUnique(dicts)
    let filename_dictionaries = a:dicts
    let oldtails = []

    let loop_counter = 0
    let max_loop = 10
    while v:true
        if loop_counter == max_loop
            echoerr "Error: Hit upper iteration limit"
            break
        endif

        let tails = map(copy(filename_dictionaries), {_, D -> D["uniquetail"]})
        if oldtails == tails
            break
        else
            let oldtails = tails
        endif

        let duplicates_exist = len(uniq(copy(sort(tails)))) != len(tails)
        if !duplicates_exist
            break
        endif

        let filename_dictionaries = s:IncrementTails(filename_dictionaries)
        let loop_counter = loop_counter + 1
    endwhile
    return filename_dictionaries
endfunction
" let filename_dictionaries = s:OldFilesSource("html.vim")
" let filename_dictionaries = s:OldFilesSource("*")
" let filename_dictionaries = s:IncrementUntilUnique(filename_dictionaries)
" echo map(filename_dictionaries, {_, D -> D["uniquetail"]})

function! s:PathExists(dicts)
    let filename_dictionaries = a:dicts
    let notexists = []
    for filename_D in filename_dictionaries
        let filereadable = filereadable(expand(filename_D["text"]))
        if filereadable == 0
            call add(notexists, filename_D)
        endif
    endfor
    return notexists
endfunction
" let filename_dictionaries = s:OldFilesSource("*")
" let filtered_dictionaries = s:PathExists(filename_dictionaries)
" let notexist_list = map(filtered_dictionaries, {_, D -> [D["oldfiles_index"], D["text"]]})


nnoremap <silent> gr :call <SID>Reset()<CR>
nnoremap g: :au! MruPreview<CR>


command! -complete=customlist,s:MruCompletion -nargs=? MRU call s:MruFunction("<args>")
let g:ui2_popup_id = -1

augroup MruPreview
    au!
    au CmdlineChanged : call s:GuiIfMru()
    au CmdlineLeave : call s:CloseUI2Popup()
    "
    au CmdlineChanged : call timer_start(0, {_-> _})
augroup END
