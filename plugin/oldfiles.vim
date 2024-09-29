
" deprecated {{{
function! s:BufferPathsPwd()
    let l:buffer_paths = []
    let l:pwd = getcwd()

    for l:buffer in range(1, bufnr('$'))
        let l:bufname = bufname(l:buffer)
        if empty(l:bufname)
            continue
        endif
        if getbufvar(l:buffer, '&buflisted') == 0
            continue
        endif
        let l:buffer_path = fnamemodify(bufname, ':p')
        if stridx(l:buffer_path, l:pwd) == 0 && filereadable(l:buffer_path)
            call add(l:buffer_paths, l:buffer_path)
        endif
    endfor
    return l:buffer_paths
endfunction

function! s:PwdFiles()
    let l:buffer_paths = s:BufferPathsPwd()
    let l:oldfiles = s:PwdOldfiles()
    let l:oldfiles_not_in_buffer_paths = []
    for l:oldfile in l:oldfiles
        if index(l:buffer_paths, l:oldfile) == -1
            call add(l:oldfiles_not_in_buffer_paths, l:oldfile)
        endif
    endfor
    return l:buffer_paths + l:oldfiles_not_in_buffer_paths
endfunction
" }}}

function! s:PwdOldfiles()
    let l:binary = '~/golang/viminfo_utils/bin/oldfiles'
    let l:pwd = getcwd()
    let l:cmd = printf('%s --path-prefix %s', l:binary, l:pwd)
    let l:oldfiles = systemlist(l:cmd)
    return l:oldfiles
endfunction

function! s:Oldfiles()
    let l:binary = '~/golang/viminfo_utils/bin/oldfiles'
    let l:cmd = l:binary
    let l:oldfiles = systemlist(l:cmd)
    return l:oldfiles
endfunction

function! s:RemoveCurrentPathFromList(paths)
    let l:current_path_index = index(a:paths, expand('%:p'))
    if l:current_path_index != -1
        call remove(a:paths, l:current_path_index)
    endif
endfunction

function! s:Fzf(source)
    let l:options = '--multi --delimiter=/ --nth 4.. --no-sort --preview "bat --color=always --style=plain {}"'
    call fzf#run({
        \ 'source': a:source,
        \ 'sink': 'e',
        \ 'options': l:options,
        \ })
endfunction

function! s:ShowPwdOldfiles()
    let l:pwd_files = s:PwdOldfiles()
    call s:RemoveCurrentPathFromList(l:pwd_files)
    call s:Fzf(l:pwd_files)
endfunction

function! s:ShowOldfiles()
    let l:files = s:Oldfiles()
    call s:RemoveCurrentPathFromList(l:files)
    call s:Fzf(l:files)
endfunction

if v:vim_did_enter
    call s:ShowOldfiles()
endif

nmap <Plug>PwdOldfiles :call <SID>ShowPwdOldfiles()<CR>
nmap <Plug>Oldfiles    :call <SID>ShowOldfiles()<CR>
