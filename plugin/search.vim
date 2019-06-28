" Works on multi-line and multi-width characters :)
" TEST CASES:
" array_index[12]                                                      | array_index[12]
" $1                                                                   | $1
" ^.^                                                                  | ^.^
" a*cd                                                                 | a*cd
" ab*cd                                                                | ab*cd
" ma~da                                                                | ma~da
" "quotes"                                                             | "quotes"
" /substitute/                                                         | /substitute/
" 'singlequotes'                                                       | 'singlequotes'
" 📁📁                                                                 | 📁📁
" array_index[12]$1^.^ab*cdma~da"quotes"/substitute/'singlequotes'📁📁 | array_index[12]$1^.^ab*cdma~da"quotes"/substitute/'singlequotes'📁📁
"
" array_index[12]$1^.^ab*cdma~da"quotes"/substitute/'singlequotes'📁📁 | array_index[12]$1^.^ab*cdma~da"quotes"/substitute/'singlequotes'📁📁


" EXPLANATION: failed attempt at getting visual selection without usigng normal mode
" " doesn’t work on mult-byte strings
" let highlighted_string = line[start_col-1:end_col-1]
" works on multi-byte strings: https://www.reddit.com/r/vim/comments/5t08uo/vimscript_unicode/
" let highlighted_string = strcharpart(getline("'<"), col("'<")-1, col("'>") - col("'<")+1)
function! s:Visual2Search()
    let magic_escape_chars =  '[]\$^*~."/'
    " let magic_escape_chars =  '\$^/'
    let no_magic_escape_chars = '\$^/'
    if &magic
        let escape_chars = magic_escape_chars
    else
        let escape_chars = no_magic_escape_chars
    endif

    let reg_save = @a
    normal! gv"ay
    let highlighted_string = @a
    let @a = reg_save

    let search_string = escape(highlighted_string, escape_chars)
    let search_string = substitute(search_string, "\\n", '\\n', "g")

    if &magic == 0
        let search_string = "\\M" . search_string
    endif

    return search_string
endfunction

function! s:VisualHash()
    let search_string = s:Visual2Search()
    let search_string =  substitute(search_string, "'", "''", "g")
    let cmd =  'call feedkeys(''?' . search_string . ''')'
    execute cmd
    call feedkeys("")
endfunction

function! s:VisualStar() 
    let search_string = s:Visual2Search()
    let search_string =  substitute(search_string, "'", "''", "g")
    let cmd =  'call feedkeys(''/' . search_string . ''')'
    execute cmd
    call feedkeys("")
endfunction

function! s:Visual_gd()
    let search_string = s:Visual2Search()

    let cmd = ":0/" . search_string "/"
    execute cmd
    call search(search_string, 'c')

    let @/ = search_string
    call feedkeys(":set hls")
endfunction

vnoremap * :<c-u>call <sid>VisualStar()<CR>
vnoremap # :<c-u>call <sid>VisualHash()<CR>
vnoremap gd :<c-u>call <sid>Visual_gd()<CR>

function! s:VisualReplace()
    let search_string = s:Visual2Search()
    let @/ = search_string

    " only to play well with vim-cool
    call feedkeys(":set hls")

    call feedkeys("cgn")
endfunction

vnoremap s :<c-u>call <sid>VisualReplace()<CR>

function! SearchToRegex()
    let search_register = @/
    let search_length = len(search_register)
endfunction

" doesn’t work for 'nomagic'
function! s:ToggleWholeKeyword()
    let search_pattern = @/
    let length = len(search_pattern)
    let is_whole_keyword_wise = search_pattern[0:1] == "\\<" && search_pattern[length-2:length-1] == "\\>"
    if is_whole_keyword_wise
        let search_pattern = search_pattern[2:length-3]
    else
        let search_pattern = "\\<" . search_pattern . "\\>"
    endif
    let @/ = search_pattern
    echo "/" . search_pattern
endfunction

nnoremap <silent> gs :call <sid>ToggleWholeKeyword()<CR>

cabbrev vv v/<C-r>=@/<CR>
cabbrev gg g/<C-r>=@/<CR>
