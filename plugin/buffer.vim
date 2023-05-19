" Buffer Idea’s
" :b should be smart-case sensitive
" Unlisted / hidden buffers?
"

finish

function! s:DrawPopupOnCmdline(string)
    let popup_id = popup_create(a:string, {"borderhighlight": ["StatusLineNC"], "line" : winheight(0)+2, "col": 1, "zindex": 1 })
    call setwinvar(popup_id, '&wincolor', 'String')
    return popup_id
endfunction
function! s:ClosePopup()
    call popup_close(s:popup_id)
    let s:popup_id = -1
endfunction

let s:popup_id = -1
function! s:PopupIfBuffer()
    let cmdline = getcmdline()
    if s:popup_id == -1 && strpart(cmdline, 0, 2) !=# "b " " CHECK 1: cmdline does not start with 'b' so we aren’t interested
        return
    endif
    if s:popup_id == -1 && cmdline ==# "b " " CHECK 2: cmdline is 'b' so we need to create the popup
        let s:popup_id = s:DrawPopupOnCmdline("Sample Text")
    endif
    if s:popup_id != -1 && len(cmdline) == 0 " CHECK 3: User has pressed BACKSPACE on the 'b' so we need to cloe the popup that was drawn
        call s:ClosePopup()
        redraws
    endif
    if s:popup_id != -1 && wildmenumode() " CHECK 4: User has pressed <TAB> after typing 'b' so we need to close the popup that was drawn
        call s:ClosePopup()
        call feedkeys(nr2char(&wildchar))
        redraws
    endif

    if s:popup_id != -1
        let cmdline_glob = trim(strpart(cmdline, 1))
        let buffers = getcompletion(cmdline_glob, "buffer")
        let buffer_count = len(buffers)
        if buffer_count == 1
            let text = fnamemodify(buffers[0], ":t")
        elseif buffer_count == 0
            let text = "No Matches"
        elseif buffer_count > 1
            let text = buffer_count." matches"
        endif
        let message_color = buffer_count > 0 ? 'String' : 'WarningMsg'
        call popup_move(s:popup_id, {"col" : 4 + len(cmdline)})
        call popup_settext(s:popup_id, text)
        call setwinvar(s:popup_id, '&wincolor', message_color)
        redraws
    endif

endfunction

augroup BufferPreview
    au!
    au CmdlineChanged : call s:PopupIfBuffer()
    au CmdlineLeave   : call s:ClosePopup() | redraws
augroup END

