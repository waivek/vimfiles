" unique_1
" BUG: 
" function | function | function | function
" Press cgn on first 'function'. Press DOT. Undo twice. Press 0. 
" Highlighting should be disabled, but stays enabled.
" 
" BUG: RepeatChange: Pressing DOT triggers repeat change. Pressing it again
" does normal DOT command. Pressing it again triggers repeat change. This
" alternates. Ideal behaviour would be always being on RepeatChange unitl a
" cursor move that is not triggered by DOT.
"
" BUG_HIGH_PRIORITY: When you do RepeatChange via DOT, 'set hls' get’s
" displayed instead of number of matches. This is useless information and very
" annoying to the user.
"
" IDEA: give DOT operator same treatment as PASTE operator
"       HISTORY of deleted text and replaced text
"*d
" BUG: search for 'C', then change first 'TextChangedI', then DOT
" au TextChangedI * call CustomLogger("TextChangedI")
"
" CASE:
" color      | Color | coloR
" 
" BUG: Use VisualStar in a macro and try to repeat the macro
" BUG: (first) , (second) : ds( on first, go to second pair and do ds( again
" 
"
" FUNCTIONALITY:
" 1:   Visual selections can use *, #, gd
" 2:   If you replace a string with a new string, pressing dot searches for
"      the next instance of the string and repeats the replacement on that
"      string (similar to cgn). If you move the cursor, the dot command reverts
"      to it’s original behaviour.
"
" Works on multi-line and multi-width characters ☻
" Can repeat changes with digraphs in them ☻
" Can handle terminal keycodes ☻
" gs Works on 'c', DotOverride, RepeatChange, VisualA
" TODO: [cause: VIM-PEEKABOO](https://github.com/junegunn/vim-peekaboo/issues/30#ref-commit-809c853) 
"       replacing visually selected text with contents in a register via CTRL-V, Paste
" TODO: RepeatChange should not be called for successively making the same
"       replacement. Bad performance because of the use of 
" TODO: Make VisualA remain unaffected by textwidth
" array_index[12]                                                   | array_index[12]
" $1                                                                | $1
" ^.^                                                               | ^.^
" a*cd                                                              | a*cd
" ab*cd                                                             | ab*cd
" ma~da                                                             | ma~da
" "quotes"                                                          | "quotes"
" /substitute/                                                      | /substitute/
" 'singlequotes'                                                    | 'singlequotes' 
" 📁📁                                                              | 📁📁
"                                                               | 
" —                                                                 | —
" 日本語                                                            | 日本語
" array_index[12]$1^.^ab*cdma~da"quotes"/sub/'singq'📁📁—日本語 | array_index[12]$1^.^ab*cdma~da"quotes"/sub/'singq'📁📁—日本語
" multi line search
" array_index[12]$1^.^ab*cdma~da"quotes"/sub/'singq'📁📁—日本語 | array_index[12]$1^.^ab*cdma~da"quotes"/sub/'singq'📁📁—日本語
" multi line search
" 

" EXPLANATION: failed attempt at getting visual selection without using normal mode
" let highlighted_string = line[start_col-1:end_col-1]
" works on multi-byte strings: https://www.reddit.com/r/vim/comments/5t08uo/vimscript_unicode/
" let highlighted_string = strcharpart(getline("'<"), col("'<")-1, col("'>") - col("'<")+1)

function! s:String2Pattern(string)
    let highlighted_string = a:string
    let magic_escape_chars =  '[]\$^*~."/'
    let search_string = escape(highlighted_string, magic_escape_chars)
    let search_string = substitute(search_string, "\\n", '\\n', "g")
    return search_string
endfunction
function! s:Visual2Search()
    let reg_save = @"
    normal! gvy
    let search_string = s:String2Pattern(@")
    let @" = reg_save
    return search_string
endfunction

function! s:VisualStar() 
    let search_string = s:Visual2Search()
    let @/ = search_string
    call feedkeys("/\<CR>")
endfunction
function! s:VisualHash()
    let search_string = s:Visual2Search()
    let @/ = search_string
    call feedkeys("?\<CR>")
endfunction
function! s:Visual_gd()
    let search_string = s:Visual2Search()
    let cmd = ":0/" . search_string "/"
    execute cmd
    call search(search_string, 'c')
    let @/ = search_string
    call feedkeys(":set hls\<CR>")
endfunction
function! s:VisualReplace()
    let search_string = s:Visual2Search()
    let @/ = search_string
    " only to play well with vim-cool
    call feedkeys(":set hls\<CR>")
    call feedkeys("cgn")
endfunction


" No VisualI, because it is not repeatable. After first replacement, cursor is
" before the match, not after. So subsequent DOT commands operate on the same
" match.
" GET’S AFFECTED BY TEXTWIDTH

" Terminal Keycodes work in RepeatChange() because we are using the @.
" register which has the  escape sequence as that is what we type to be able
" to enter terminal keycodes
" @. = \         // feedkeys friendly
" @" = \           // feedkeys unfriendly
" a\           | a\
" array_index[12] | array_index[12]

function! s:VisualA()

    let search_string = s:Visual2Search()
    let @/ = search_string
    " IMPLEMENTATION_1: 
    " TODO: Affected by indent settings: inserts newline in mutliline replace
    " TODO: Affected by text-width
    let substitute_command = 'substitute(@", "[]", "\\0", "g")'
    call feedkeys("cgn")
    call feedkeys('=' . substitute_command . '', "n")

    " IMPLEMENTATION_2:
    " Not repeatable, this is the vanilla behaviour of cgn if you enter normal mode via CTRL-O
    " Not affected by text-width or editor settings
    " call feedkeys("cgnp", "n")

    " IMPLEMENTATION_3:
    " Doesn’t work on terminal keycodes ex: , 
    " call feedkeys("cgn\"", "n")

endfunction
vnoremap <expr> A mode() ==? "\<C-V>" ?  'A'  :  ':<c-u>call <SID>VisualA()<CR>' 

" breakadd func 22 GetMatchByteOffsets
function! GetMatchByteOffsets()
    let view_save = winsaveview()
    let pos_save  = getpos(".")

    let match_positions = []
    let wrapscan_option_save = &wrapscan
    let search_incomplete = v:true



    set wrapscan
    while search_incomplete
        keepjumps silent! normal! n
        let byte_int = line2byte(".") + col(".") - 1
        if len(match_positions) > 0 && byte_int == match_positions[0]
            let search_incomplete = v:false
        else
            let match_positions = match_positions + [ byte_int ]
        endif
    endwhile

    let &wrapscan = wrapscan_option_save
    call winrestview(view_save)

    call sort(match_positions, 'n')
    return match_positions

endfunction
function! MatchByteOffsetsToString(match_positions)
    let cursor_position = line2byte(".") + col(".") - 1
    let cursor_on_match = index(a:match_positions, cursor_position) > -1
    if cursor_on_match
        let x_match_of_n_matches = index(a:match_positions, cursor_position) + 1
        let total_matches = len(a:match_positions)
        return printf("/%s MATCH %d of %d", @/, x_match_of_n_matches, total_matches)
    else
        let matches_before_cursor = 0
        let matches_after_cursor = 0
        for match_position in a:match_positions
            if match_position < cursor_position
                let matches_before_cursor = matches_before_cursor + 1
            endif
            if match_position > cursor_position
                let matches_after_cursor = matches_after_cursor + 1
            endif
        endfor
        return printf("/%s -%d | +%d", @/, matches_before_cursor, matches_after_cursor)
    endif
endfunction
" ^V<e2><80><fe>X<94>
" —
" http://www.ltg.ed.ac.uk/~richard/utf-8.cgi?input=%E2%80%94&mode=char
" NOTE: Originally, feedkeys was happening by creating a string from the '@.'
" register. This wasn’t working for digraphs, where the keys pressed were
" being inserted insted of the digraph itself. So now we insert the contents
" of the dot register via <C-r>
"
" pos, rpos
" pos, rpos
" pos, rpos
" pos, rpos
"
" pos
" pis
" pes
" pos

nnoremap <silent> ga :echo MatchByteOffsetsToString(GetMatchByteOffsets())<CR>
" blaugrana | blaugrana | blaugrana | blaugrana
function! RepeatChange()
    let whole_keyword_enabled = @/ ==# '\<' . @" . '\>'
    let whole_keyword_disabled = !whole_keyword_enabled

    " works on 1. gs, 2. cgn on regex
    let pattern_matches_deleted_text = @" =~ @/
    let pattern_does_not_match_deleted_text = !pattern_matches_deleted_text
    if !pattern_matches_deleted_text
        let search_string = s:String2Pattern(@")
        let @/ = search_string
    endif

    call feedkeys("cgn.")
    call feedkeys(":set hls\<CR>")

    " function! PrintMatchInfoAndDeleteAugroup()
    "     let match_positions = GetMatchByteOffsets()
    "     let match_info_string = MatchByteOffsetsToString(match_positions)
    "     let feedkeys_command = printf(":echo '%s'\<CR>", match_info_string)
    "     call feedkeys(feedkeys_command)
    "     au! PostChange 
    " endfunction
    " augroup PostChange
    "     au!
    "     au InsertLeave * call PrintMatchInfoAndDeleteAugroup()
    " augroup END

endfunction

" TEST CASE MINI:
" let soccer | let soccer
let g:override_pos = []
function! CheckIfCursorMoveWasCausedByDotOperator()
    let condition_1 = @/ =~ @"

    let current_position_save = getpos(".")
    let visual_start_save     = getpos("'<")
    let visual_end_save       = getpos("'>")
    "unique_2
    let yank_start_save       = getpos("'[")
    let yank_end_save         = getpos("']")
    let quote_reg_save        = @"

    silent! normal! v`[y
    let string_between_yank_start_and_cursor = @"

    call setpos(".", current_position_save)
    call setpos("'<", visual_start_save)
    call setpos("'>", visual_end_save)
    call setpos("'[", yank_start_save)
    call setpos("']", yank_end_save)
    let @" = quote_reg_save

    let condition_2 = string_between_yank_start_and_cursor ==# @.
    return condition_1 && condition_2

endfunction

" unique_4
" unique_5
" unique_6
" unique_7

function! RemovedAllOverrides()
    " Ignores the first CursorMoved fired immediately after leaving InsertMode
    if g:override_pos == getpos(".")
        return
    endif
    let cursor_move_was_caused_by_dot_operator = CheckIfCursorMoveWasCausedByDotOperator()
    if cursor_move_was_caused_by_dot_operator
        return
    endif
    let g:override_pos = []
    au! DotOverride CursorMoved
    nunmap .

    au! DotOverride InsertLeave

    nunmap n

    nunmap gs
    nnoremap <silent> gs :call <SID>ToggleWholeKeyword()<CR>
endfunction

" RepeatChange chaining, n overried edge case {{{
" When we enter normal after making a change, `n` is overriden. The new
" behaviour updated the `@/` register to `@"` and then searches for the next
" match of `@"`. Because it searches for the next match, the CursorMoved gets
" fired, which unmaps `.` and `n`. We can use `n` normally till we find the
" match we want to change. Pressing `.` over here does a normal (non cgn)
" replacement, but `.` gets mapped to RepeatChange. If we press dot again, it
" does a `cgn` replacement and goes into a well-known state.
"
" Pressing `n` after immediately making a change removes the old value of
" `@/`, whatever it was. This is different from the expected behaviour in
" vanilla in a small conditional case 
" →   condition_1: some text replacement has taken place via `c`
" →   condition_2: cursor has not moved after replacement
" }}}

function! s:NextPatternOverride()
    let search_string = s:String2Pattern(@")
    let @/ = search_string
    call feedkeys("n", "n")
endfunction
function! s:ToggleWholeKeywordOverride()
    let search_string = s:String2Pattern(@")
    let @/ = search_string
    call feedkeys(":set hls\<CR>")
    call s:ToggleWholeKeyword()
endfunction
function! s:InitializeDotOverride()
    " Prevents Overrides from overlapping
    if g:override_pos != []
        return
    endif
    let g:override_pos = getpos(".")
    nnoremap <silent> . :call RepeatChange()<CR>
    nnoremap <silent> n :call <SID>NextPatternOverride()<CR>
    nnoremap <silent> gs :call <SID>ToggleWholeKeywordOverride()<CR>

    au DotOverride CursorMoved * call RemovedAllOverrides()
endfunction
function! s:YankPost()
    if v:event["operator"] ==# "y" || v:event["operator"] ==# "d"
        return
    endif
    au DotOverride InsertLeave * call s:InitializeDotOverride()
endfunction
" Yank Post Reasoning {{{
" Initially, we were using InsertLeave as the entry point. However, this was
" breaking the dot operator on changes where only text is inserted, without
" replacing any text. If we do `Anew_text` in NORMAL mode, this was not
" repeatable as dot was being overriden. We also don’t want dot to ever be
" overriden if text is only being inserted. We now use the TextYankPost event
" to set up the InsertLeave event. In YankPost, we check if it was triggered
" by the 'c' operator and then set up the InsertEnter auto command.
" }}}
augroup DotOverride
    au! 
    au TextYankPost * call s:YankPost()
augroup END


" last_search_pattern
" pos, rpos
" pos, rpos
" pos, rpos
"
" hls, nohls
" hls, nohls
" hls, nohls
" last_search_pattern
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
    redraw|echo "/" . search_pattern
endfunction

vnoremap *  :<c-u>call <SID>VisualStar()<CR>
vnoremap #  :<c-u>call <SID>VisualHash()<CR>
vnoremap gd :<c-u>call <SID>Visual_gd()<CR>
vnoremap s  :<c-u>call <SID>VisualReplace()<CR>

nnoremap <silent> gs :call <SID>ToggleWholeKeyword()<CR>

cabbrev vv v/<C-r>=@/<CR>
cabbrev gg g/<C-r>=@/<CR>
cabbrev ss s/<C-r>=@/<CR>

" Search in selection if in VISUAL LINE mode
vnoremap <expr> / mode() !=# 'V' ? '/' : ':<c-u>call feedkeys(''/\%>'' . (line("''<") - 1) . ''l\%<'' . (line("''>") + 1) . "l")<CR>'

" unique_3
