if exists("g:mkdir_loaded")
  finish
endif

let g:mkdir_loaded = 1

function! s:Mkdir()
  let dir = expand('%:p:h')

  if !isdirectory(dir)
    call mkdir(dir, 'p')
    echo 'Created non-existing directory: '.dir
  endif
endfunction

augroup MakeDir
    au!
    au BufWritePre * call s:Mkdir()
augroup END
