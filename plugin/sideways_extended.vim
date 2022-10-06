
"Insert this into ~/vimfiles/plugged/sideways.vim/autoload/sideways/parsing.vim function s:LocateValidDefinitions before the serach 
"
"   let stopline = line(".")

function! s:SidewaysLeft()
    " https://vim.fandom.com/wiki/Restore_the_cursor_position_after_undoing_text_change_made_by_a_script
    execute "normal! i "
    execute "normal! x"
    SidewaysLeft
endfunction
function! s:SidewaysRight()
    " https://vim.fandom.com/wiki/Restore_the_cursor_position_after_undoing_text_change_made_by_a_script
    execute "normal! i "
    execute "normal! x"
    SidewaysRight
endfunction
function! s:SidewaysJumpRight()
    let argument_dictionaries = sideways#Parse()[1]
    let start_columns = map(argument_dictionaries, {index, D -> D['start_col']})
    if len(start_columns) == 0
        return
    endif
    let left_most_start_column = start_columns[0]
    call filter(start_columns, {index, column -> col('.') < column})
    if len(start_columns) > 0
        let closest_right_column = start_columns[0]
        execute "normal! ".closest_right_column."|"
    else
        execute "normal! ".left_most_start_column."|"
    endif
endfunction
function! s:SidewaysJumpLeft()
    let argument_dictionaries = sideways#Parse()[1]
    let start_columns = map(argument_dictionaries, {index, D -> D['start_col']})
    if len(start_columns) == 0
        return
    endif
    let right_most_start_column = start_columns[-1]
    call filter(start_columns, {index, column -> col('.') > column})
    if len(start_columns) > 0
        let closest_left_column = start_columns[-1]
        execute "normal! ".closest_left_column."|"
    else
        execute "normal! ".right_most_start_column."|"
    endif
endfunction
function! s:DeleteArgumentUsingSideways()
    let col_save = col(".")
    execute "normal! i "
    execute "normal! x"
    execute "normal d\<Plug>SidewaysArgumentTextobjA"
    if len(getline(".") > col_save)
        execute "normal! ".col_save."|"
    endif
    " if exists("*repeat#set")
    "     call repeat#set("\<Plug>SidewaysArgumentTextobjA", -1)
    " endif
endfunction

nnoremap <Plug>SidewaysLeftExtended  :call <SID>SidewaysLeft()<CR>
nnoremap <Plug>SidewaysRightExtended :call <SID>SidewaysRight()<CR>
" nmap <silent> <Plug>SidewaysLeftExtended
" nmap <silent> <Plug>SidewaysRightExtended

" nnoremap <Plug>DeleteArgumentUsingSideways :call <SID>DeleteArgumentUsingSideways()<CR>
" nmap <silent> da, <Plug>DeleteArgumentUsingSideways
nnoremap <silent> da, :call <SID>DeleteArgumentUsingSideways()<CR>

nnoremap <silent> ], :call <SID>SidewaysJumpRight()<CR>
nnoremap <silent> [, :call <SID>SidewaysJumpLeft()<CR>

omap a, <Plug>SidewaysArgumentTextobjA
xmap a, <Plug>SidewaysArgumentTextobjA
omap i, <Plug>SidewaysArgumentTextobjI
xmap i, <Plug>SidewaysArgumentTextobjI

nmap <leader>si <Plug>SidewaysArgumentInsertBefore
nmap <leader>sa <Plug>SidewaysArgumentAppendAfter
nmap <leader>sI <Plug>SidewaysArgumentInsertFirst
nmap <leader>sA <Plug>SidewaysArgumentAppendLast
let g:sideways_search_timeout = 20
