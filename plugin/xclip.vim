
let is_linux = has("linux")
let xclip_installed = executable("xclip")

if !is_linux || !xclip_installed
  finish
endif


function! LinuxCopy()
    let reg_save = getreg('a')
    silent normal! gv"ay
    let selection = getreg('a')
    call setreg('a', reg_save)

    if len(selection) < 2000
        call system('printf '.shellescape(selection).' | xclip -selection clipboard')
    else
        let path = tempname()
        call writefile(split(selection, '\n'), path)
        call system('xclip -selection clipboard '.shellescape(path))
        call delete(path)
    endif
endfunction

vnoremap <silent> gy :call LinuxCopy()<cr>
" vnoremap <silent> <C-c> :call LinuxCopy()<cr>

