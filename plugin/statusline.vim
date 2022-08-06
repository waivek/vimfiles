
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

function! Debug()
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

" set statusline=%{s:LinterStatus()}
function! GetRelpath()
    if &ft == "help" || &ft == "man.cpp"
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
        let b:relpath_cache = GetRelpath()
    endif
    return b:relpath_cache
endfunction

function! s:DeleteCacheInAllBuffers()
    " echoerr "DeleteRelpathCache called"
    " https://vim-use.narkive.com/AjYpj0zx/unlet-ing-variables-in-buffers
    for D in getwininfo()
        let buf_D = getbufvar(D['bufnr'], '')
        call filter(buf_D, "v:key != 'relpath_cache'")
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
    au DirChanged  * call s:DeleteCacheInAllBuffers()
    au BufEnter    * call s:DeleteCacheInAllBuffers()
    au BufNew      * call s:DeleteCacheInAllBuffers()
    au BufCreate   * call s:DeleteCacheInAllBuffers()
    au BufFilePost * call s:DeleteCacheInAllBuffers()
augroup END

let s:dotty_script_id = -1
function! DotMap()
    let dotty_path = '~/vimfiles/plugin/dotty.vim'
    if s:dotty_script_id == -1
        let s:dotty_script_id = GetSid(dotty_path)
    endif
    let dot_map = ':call RepeatChange()<CR>'
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

    if &ws
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
set statusline+=%m%r%y%w%{DotMap()}%=\ %l/%-6L\ %3c 
" }}}
" Error Lines {{{
let g:last_command = ""
let g:error_buffers = []
let g:error_lines = []
let g:messages = []
sign define piet text=>> texthl=MatchParen linehl=Normal
function! s:ParseQuickfix()
    let last_cmd = histget("cmd", histnr("cmd"))
    if last_cmd[:4] != "make"
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

