
function! StatuslineEntry()
    call s:RunJob()
endfunction


function! s:CloseCB(channel)
    try
        let lines = []
        while ch_canread(a:channel)
            let lines = lines + [ ch_read(a:channel) ]
        endwhile
        let msg = lines
    catch
        let msg = 'no message'
    endtry
    try
        let err = ch_readraw(a:channel, #{part: 'err'})
    catch
        let err = 'no error'
    endtry
    if stridx(err, "not a git repository") != -1
        " echo 'Not A Git Repo.'
        let b:stl_git = 'notagitrepo'
        return
    endif
    if empty(lines)
        " echo 'Unmodified.'
        let b:stl_git = 'unmodified'
        return
    endif
    if slice(lines[0], 0, 2) ==# '??'
        " echo 'Untracked.'
        let b:stl_git = 'untracked'
        return
    endif
    " echo string(lines)
    " echoerr "msg: " . string(msg) . ", err: " . err

endfunction

function! s:RunJob()
    let path = expand("%:p")
    let directory = fnamemodify(path, ":h")
    let command = printf('cd %s && git status -s %s', directory, path)
    let job = job_start(["cmd.exe", "/c", command], { 
                \"exit_cb": function('s:ExitCB'),
                \"close_cb": function('s:CloseCB') })
endfunction

augroup GitStatusLine
    au!
    au BufRead  * call s:RunJob()
    au BufWrite * call s:RunJob()
augroup END

function! GetGitStl()
    if !exists('b:stl_git')
        return ''
    endif
    if b:stl_git !=# 'untracked'
        return ''
    endif
    let change_count = getchangelist()[1]
    if change_count < 20
        return ''
    endif
    return 'UNTRACKED'
endfunction

" Status Line {{{
" 

function! s:LinterStatus() abort
    if ale#engine#IsCheckingBuffer(bufnr(''))
        return "Linting..."
    endif

    let l:counts = ale#statusline#Count(bufnr(''))

    let l:all_errors = l:counts.error + l:counts.style_error
    let l:all_non_errors = l:counts.total - l:all_errors

    return l:counts.total == 0 ? 'OK' : printf(
    \   '%dW %dE',
    \   all_non_errors,
    \   all_errors
    \)
endfunction

function! s:Debug()
    echo "1"
    let filename = expand("%:p")
    let cwd = getcwd()

    let index = 0
    let length = len(cwd)

    while index < length
        if filename[index] != cwd[index]
            break
        endif
        let index = index + 1
    endwhile

    let file_not_in_cd = index < length
    echo "file_not_in_cd: " . file_not_in_cd
    echo "index: " . index
    echo "length: " . length
    return expand("%")
endfunction

function! s:PathSplit()
    let path = 'C:\Users\vivek\Desktop\blender.lnk'
    let folders = split(path, '\')
    echo folders
endfunction

function! s:NormPath(path)
    let separator = "\\"
    let norm_path = substitute(a:path, '/', separator, "g")
    return norm_path
endfunction

function! s:GetRelpath_2()
    if &filetype ==#  "help" || &filetype ==#  "man.cpp"
        let b:relpath = expand("%:t")
        return b:relpath
    endif


    let file_drive = expand("%:p")[0]
    let dir_drive = getcwd()[0]

    if file_drive != dir_drive
        return expand("%") 
    endif

    let filepath = expand("%:p")
    let cwd = getcwd()
    let last_char_is_slash = cwd[len(cwd)-1] ==# '\'
    if last_char_is_slash
        let cwd = slice(cwd, 0, len(cwd)-1)
    endif


    let file_in_cwd = stridx(filepath, cwd) == 0
    if file_in_cwd
        let path = strpart(filepath, len(cwd.'\'))
        return s:NormPath(path)
    else
        let cwd_parts = split(cwd, '\')
        let filepath_parts = split(filepath, '\')

        let for_end = min([len(cwd_parts), len(filepath_parts)])
        let common_count = -1
        for idx in range(for_end)
            " echo "cwd_parts[idx]: " . string(cwd_parts[idx])
            " echo "filepath_parts[idx]: " . string(filepath_parts[idx])
            if cwd_parts[idx] !=# filepath_parts[idx]
                let common_count = idx
                break
            endif
            let idx = idx + 1
        endfor


        " echo "--- x ---"
        " echo "cwd: " . cwd
        " echo "filepath: " . filepath
        let common_parts = slice(cwd_parts, 0, common_count)
        let common_path = join(common_parts, '\')
        " echo "common_path: " . common_path
        let dot_count = len(cwd_parts) - common_count
        " echo "dot_count: " . dot_count
        let path = strpart(filepath, len(common_path.'\'))
        let dot_path = repeat('..\', dot_count) . path
        return s:NormPath(dot_path)
    endif
    " C:\Users\vivek\Desktop\Twitch\chats\
    "               x
    " C:\Users\vivek\Documents\Python\ic.py
    " ----- 3 ----- y




endfunction
" echo s:GetRelpath_2()


" set statusline=%{s:LinterStatus()}
function! s:GetRelpath()
    cd . " Required to update `expand('%')`
    if &filetype ==#  "help" || &filetype ==#  "man.cpp"
        let b:relpath = expand("%:t")
        return b:relpath
    endif


    let file_drive = expand("%:p")[0]
    let dir_drive = getcwd()[0]

    if file_drive != dir_drive
        return expand("%") 
    endif

    let filename = expand("%:p")
    let cwd = getcwd()

    let index = 0
    let length = len(cwd)

    while index < length
        if filename[index] != cwd[index]
            break
        endif
        let index = index + 1
    endwhile

    let file_not_in_cd = index < length
    if file_not_in_cd
        let dir_count = count(cwd[index:], '\') + 1
        let ret_val = repeat('..\', dir_count) . filename[index-1:]
        let ret_val = substitute(ret_val, '\\\\', '\\', 'g')
        return ret_val
    else
        return expand("%")
    endif
endfunction

function! Relpath()
    if !exists('b:relpath_cache')
        let b:relpath_cache = s:GetRelpath_2()
    endif
    return b:relpath_cache
endfunction

function! s:DeleteCacheInAllBuffers(call_au_group)
    if a:call_au_group ==# "DirChanged"
        let x = 1
    elseif a:call_au_group ==# "BufEnter"
        let x = 2
    elseif a:call_au_group ==# "BufNew"
        let x = 3
    elseif a:call_au_group ==# "BufCreate"
        let x = 4
    elseif a:call_au_group ==# "BufFilePost"
        let x = 5
    endif
    " echoerr "DeleteRelpathCache called"
    " https://vim-use.narkive.com/AjYpj0zx/unlet-ing-variables-in-buffers
    for D in getwininfo()
        let buf_D = getbufvar(D['bufnr'], '')
        call filter(buf_D, "v:key !=# 'relpath_cache'")
        " echo getbufvar(D['bufnr'], 'relpath_cache')
    endfor
endfunction
" call s:DeleteCacheInAllBuffers()

" function! DeleteRelpathCache()
"     if exists("b:relpath_cache")
"         unlet b:relpath_cache
"     endif
" endfunction

augroup StatusLineUpdateRelpathCache
    au!
    au DirChanged  * call s:DeleteCacheInAllBuffers("DirChanged")
    au BufEnter    * call s:DeleteCacheInAllBuffers("BufEnter")
    au BufNew      * call s:DeleteCacheInAllBuffers("BufNew")
    au BufCreate   * call s:DeleteCacheInAllBuffers("BufCreate")
    au BufFilePost * call s:DeleteCacheInAllBuffers("BufFilePost")
augroup END

let s:dotty_script_id = -1
function! DotMap()
    let dotty_path = '~/vimfiles/plugin/dotty.vim'
    if s:dotty_script_id == -1
        let s:dotty_script_id = introspect#GetSid(dotty_path)
    endif

    let dot_map = printf(':call <SNR>%d_RepeatChange()<CR>', s:dotty_script_id)
    let gs_1_map = printf(':call <SNR>%d_ToggleWholeKeywordOverride()<CR>', s:dotty_script_id)
    let gs_2_map = printf(':call <SNR>%d_ToggleWholeKeyword()<CR>', s:dotty_script_id)
    let n_map = printf(':call <SNR>%d_NextPatternOverride()<CR>', s:dotty_script_id)

    if dot_map == maparg(".", "n")
        let dot_status = "DOT"
    else
        let dot_status = ""
    endif
	
    if gs_1_map == maparg("gs", "n")
        let gs_status = "GSO"
    elseif gs_2_map == maparg("gs", "n")
        let gs_status = "GS"
    else
        let gs_status = ""
    endif

    if n_map == maparg("n", "n")
        let n_status = "N"
    else
        let n_status = ""
    endif

    if &wrapscan
        let ws_status = "WS"
    else
        let ws_status = ""
    endif

    let dotty_status = join([dot_status, gs_status, n_status, ws_status], " ")
    let dotty_status = trim(dotty_status)
    return "[" . dotty_status . "]"
endfunction
set statusline=%<%{Relpath()}
" options.txt[-][RO][help]
"   options.txt - Relpath()
"           [-] - %m (modfiied flag)
"          [RO] - %r (read-only flag)
"        [help] - %y (type of file)
"     [Preview] - %w (preview window flag, not present in example)
"                  = (separation point b/w left & right aligned fields)
"
set statusline+=%m%r%y%w%{DotMap()}%#Error#%{GetGitStl()}%0*%=\ %l/%-6L\ %3c 
" }}}
" Error Lines {{{
let g:last_command = ""
let g:error_buffers = []
let g:error_lines = []
let g:messages = []
sign define piet text=>> texthl=MatchParen linehl=Normal
function! s:ParseQuickfix()
    let last_cmd = histget("cmd", histnr("cmd"))
    if last_cmd[:4] !=# "make"
        return
    endif
    sign unplace *
    let g:error_lines = []
    let g:messages = []
    let index = 0
    let Q = getqflist()
    let len = len(Q)
    while index < len
        call add(g:error_lines, Q[index]["lnum"])
        call add(g:messages, Q[index]["text"])
        call add(g:error_buffers, Q[index]["bufnr"])
        exe ":sign place 2 line=" . Q[index]["lnum"] . " name=piet buffer=". Q[index]["bufnr"]
        let index = index + 1
    endwhile
    if len == 0
        cclose
        redraw | echohl ModeMsg | echo "Build succeeded" | echohl Normal
    else
        copen
    endif
endfunction

function! s:PrintErrorMsg()
    let lnum = line(".")
    let bufnum = bufnr("%")
    let len = len(g:error_lines)
    let index = 0
    let on_error_line = v:false
    let echo_message = ""
    while index < len
        if g:error_lines[index] == lnum && g:error_buffers[index] == bufnum
            let echo_message =  g:messages[index]
        endif
        let index = index + 1
    endwhile
    if echo_message != ""
        redraw | echohl ErrorMsg | echo  echo_message | echohl Normal
    endif
endfunction

augroup StatusLineEnhanced
    au!
    au QuickFixCmdPost * call s:ParseQuickfix()
    " au CursorMoved * call s:PrintErrorMsg()
augroup END
" }}}
" Traverse Indent {{{

" }}}

