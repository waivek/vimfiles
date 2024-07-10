let is_linux = has("linux")
let xclip_installed = executable("xclip")

if !is_linux || !xclip_installed
    finish
endif

function! s:LinuxCopy()

    let reg_save = getreg('a')
    silent normal! gv"ay
    let selection = getreg('a')
    call setreg('a', reg_save)

    let path = tempname()
    let lines = split(selection, '\n')
    call writefile(lines, path)
    let command ='xclip -selection clipboard '.shellescape(path) 
    call system(command)
    call delete(path)

endfunction

" vnoremap <silent> gy :call LinuxCopy()<cr>
vnoremap <silent> <C-c> :<c-u>call <SID>LinuxCopy()<cr>
