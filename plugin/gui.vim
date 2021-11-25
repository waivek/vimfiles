" let MAX_LINES = 10
" let fname = '~/vimfiles/mini.vimrc'
" let filepath = glob(fname)
" let file_preview = readfile(filepath, '', MAX_LINES)
" let window_id = popup_create(file_preview, #{
"     \ close : "click", title: fname, padding: [0, 1, 1, 1], 
"     \ borderhighlight: ["StatusLine"], border: [1, 0, 0, 0], borderchars: [' ']
" \ })
" call setbufvar( winbufnr( window_id ), '&syntax', 'vim' )
" nnoremap ga :call popup_close(window_id)<CR>
" Idea
