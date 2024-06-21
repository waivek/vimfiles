
function! s:GetRecentBufNrs()
    let first_window_nr = 1
    let last_window_nr = winnr("$")
    let max_bufs = 5
    let recent_bufs = []
    for win_nr in range(first_window_nr, last_window_nr)
        let old_jumps_to_new_jumps = getjumplist(win_nr)[0]
        let new_jumps_to_old_jumps = reverse(old_jumps_to_new_jumps)
        let new_bufs_to_old_bufs = map(new_jumps_to_old_jumps, {_, D -> D["bufnr"]})
        for i in range(len(new_bufs_to_old_bufs))

            let limit_reached = len(recent_bufs) > max_bufs
            if limit_reached
                break
            endif

            let buf = new_bufs_to_old_bufs[i]

            let buf_in_recent_bufs = index(recent_bufs, buf) > -1
            if buf_in_recent_bufs
                continue
            endif

            call add(recent_bufs, buf)
        endfor
    endfor
    return recent_bufs
endfunction
function! s:DeleteNonRecentBuffers()
    let recent_buf_nrs = s:GetRecentBufNrs()
    let all_buf_nrs = map(getbufinfo({'buflisted': 1}), {_, buf -> buf.bufnr})
    let non_recent_buf_nrs = filter(all_buf_nrs, {_, bufnr -> index(recent_buf_nrs, bufnr) == -1})

    if empty(non_recent_buf_nrs)
        return
    endif
    let command = printf("bd %s", join(non_recent_buf_nrs, " "))
    execute command
endfunction
augroup VimrcDeleteNonRecentBuffers
    au!
    au VimLeavePre * call <SID>DeleteNonRecentBuffers()
augroup END
