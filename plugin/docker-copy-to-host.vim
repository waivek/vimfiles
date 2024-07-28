
let s:target_folder = 'C:\Users\vivek\claude\'

function! s:CopyToHost()
  let l:hostname = trim(system('hostname'))
  let l:path = expand("%:p")
  let l:command = printf('docker cp %s:%s %s', l:hostname, l:path, s:target_folder)

  let l:path = tempname()
  let l:lines = [ l:command ]
  call writefile(l:lines, l:path)
  let l:copy_command = 'xclip -selection clipboard '.shellescape(l:path)
  call system(l:copy_command)
  call delete(l:path)

  echo l:command
  echo "Copied to Clipboard"
endfunction

command! CopyToHost call s:CopyToHost()
