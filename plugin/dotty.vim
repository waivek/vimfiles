" BUG: change word. gcc. press DOT.
"
" IDEA: allow current DOT transformation to be a substitute and have hotkeys
"       for doing a global substitute, mapped to <SPACE><DOT>
"
" IDEA: give DOT operator same treatment as PASTE operator
"       HISTORY of deleted text to replaced text transformations,
"       accessed by ‘q.’
"
" IDEA: if replacement ends with the deleted text, do a check of
"       that in RepeatChange and do an additional ‘n’ if so
"
" BEHAVIOUR: w.r.t. '?' and ‘/’
" If you do a '?' and then a change, pressing dot unintuitively changes the
" NEXT match i.e., works like `cgn` instead of `cgN`
" BUG: RepeatChange map unmap cycle bug takes place on multiline replacememnts
" [solution] Pattern matching problem, replaced let condition_1 = @/ =~ @"
" with pattern_matches_entire_deleted_text logic
"
" BUG: GetMatchByteOffsets was returning Matches even after we were done
" replacing. [solution] This was because we had a :silent in a try catch block
" which disabled error handling. We removed the :silent.
"
" BUG:
" fixed: this was intended behaviour, just unintuitive
" </span> </span>
" Select first '/', change it to '\/', press DOT. Goes into doesn’t repeat the
" change on the next match
" BUG: 
" function | function | function | function
" Press cgn on first 'function'. Press DOT. Undo twice. Press 0. 
" Highlighting should be disabled, but stays enabled.
" 
" [fixed, see below] RepeatChange: Pressing DOT triggers repeat change.
" >  [problem] Pressing it again does normal DOT command. Pressing it again
"              triggers repeat change. This alternates. Ideal behaviour would be
"              always being on RepeatChange unitl a cursor move that is not
"              triggered by DOT.
" > [solution] We create a new function CheckIfCursorMoveWasCausedByDotOperator.
"              This checks for two conditions as a sort of heurisitc and if it
"              evaluates to true, we hold off on the DOT unmapping in the
"              RemoveAllOverrides function
" [fixed, see below] When you do RepeatChange via DOT, 'set hls' get’s
" displayed instead of number of matches. This is useless information and very
" annoying to the user.
" fix: We created two new functions: GetMatchByteOffsets and
" MatchByteOffsetsToString. These are used to tell the user how many
" occurences of the replaced string are still in the buffer after a
" replacement has been made.
"
" [fixed, see below] BUG: search for 'C', then change first 'TextChangedI', then DOT
" au TextChangedI * call CustomLogger("TextChangedI")
" fix: in the first line of RepeatChange, we were doing @" =~ @/. Instead we
" should do @/ =~ @" for the regexp match to work.
"
" WHOLEKEYWORD:
" some, something, somebody
" some, something, somebody
"
" CASE:
" color | Color | coloR
" color | Color | coloR
" 
" BUG: Use VisualStar in a macro and try to repeat the macro
" BUG: (first) , (second) : ds( on first, go to second pair and do ds( again
" 
"
" FUNCTIONALITY OR FEATURES:
" 1:   Visual selections can use *, #, gd
" 2:   If you change one string to another, pressing dot searches for
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
" /quality/                                                      | /quality/
" /quality/                                                      | /quality/
" /quality/                                                      | /substitute/
" /substitute/                                                      | /substitute/
" /substitute/                                                      | /substitute/
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

let g:dot_modifications_enabled = v:true

let s:underline_highlight_group = 'VisualNOS'
let s:search_highlight_group = s:underline_highlight_group
let s:search_highlight_group = 'Search'

function! s:ToggleDotModifications()
    let g:dot_modifications_enabled = !g:dot_modifications_enabled
    if g:dot_modifications_enabled
        echo "Dot Modifications enabled"
    else
        echo 'Dot Modifications disabled'
    endif
endfunction
command! ToggleDotModifications call s:ToggleDotModifications()

function! String2Pattern(string)
    let highlighted_string = a:string
    let magic_escape_chars =  '[]\$^*~."/'
    let search_string = escape(highlighted_string, magic_escape_chars)
    let search_string = substitute(search_string, "\\n", '\\n', "g")
    return search_string
endfunction
function! s:Visual2Search()
    let reg_save = @"
    normal! gvy
    let search_string = String2Pattern(@")
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
" breakadd func 1 Visual_gd 
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
    call feedkeys("\<C-r>=" . substitute_command . "\<Esc>", "n")

    " IMPLEMENTATION_2:
    " Not repeatable, this is the vanilla behaviour of cgn if you enter normal mode via CTRL-O
    " Not affected by text-width or editor settings
    " call feedkeys("cgnp", "n")

    " IMPLEMENTATION_3:
    " Doesn’t work on terminal keycodes ex: , 
    " call feedkeys("cgn\"", "n")

endfunction
vnoremap <expr> A mode() ==? "\<C-V>" ?  'A'  :  ':<c-u>call <SID>VisualA()<CR>' 

" Returns the byte positions of occurences of @/. 
function! dotty#GetMatchByteOffsets()
    let view_save = winsaveview()
    let pos_save  = getpos(".")
    let fold_save = &foldenable
    let wrapscan_option_save = &wrapscan
    let shortmess_save = &shortmess

    let match_positions = []

    " If there are no matches in the file, return []
    set wrapscan
    set shortmess+=s " So that we don’t pollute :messages
    set nofoldenable
    try
        keepjumps normal! n
    catch /^Vim[^)]\+):E486\D/
        let &wrapscan = wrapscan_option_save
        let &shortmess = shortmess_save
        call winrestview(view_save)
        return []
    endtry

    " return []

    " Keep pressing 'n' and storing positions. Once latest position matchei
    " first stored position, we have cycled through the file. Exit.
    " let COUNT_LIMIT = 1500
    let COUNT_LIMIT = 10000 " For performance reasons
    while v:true
        " keepjumps normal! n
        call search(@/)
        let byte_int = line2byte(".") + col(".") - 1
        if len(match_positions) > 0 && byte_int == match_positions[0]
            break
        endif
        if len(match_positions) == COUNT_LIMIT
            break
        endif
        " let match_positions = match_positions + [ byte_int ]
        call add(match_positions, byte_int)
    endwhile

    let &wrapscan = wrapscan_option_save
    let &shortmess = shortmess_save
    let &foldenable = fold_save
    call winrestview(view_save)

    call sort(match_positions, 'n')
    return match_positions

endfunction

" Three return possibilties:
"   1. STRING not found: when you do DOT and keep changing until no more PATTERNS remain
"   1. STRING MATCH a of b: when you press 'n'
"   1. STRING -x +y: when you do DOT and more occurences remain
function! MatchByteOffsetsToString(match_positions)
    " return [@/, a:match_positions ]
    if len(a:match_positions) == 0
        " return ""
        return [ @/, "not found" ]
    endif
    let cursor_position = line2byte(".") + col(".") - 1
    let cursor_on_match = index(a:match_positions, cursor_position) > -1
    if cursor_on_match
        let x_match_of_n_matches = index(a:match_positions, cursor_position) + 1
        let total_matches = len(a:match_positions)
        " return printf("/%s MATCH %d of %d; (getmatchbytoffset_1)", @/, x_match_of_n_matches, total_matches)
        " return printf("/%s MATCH %d of %d", @/, x_match_of_n_matches, total_matches)
        return [
                    \ printf("/%s",  @/),
                    \ printf("%d of %d", x_match_of_n_matches, total_matches)
                    \ ]
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
        let left_info_string = ''
        let right_info_string = ''
        let separator = ''
        if matches_before_cursor > 0
            let left_info_string = '-' . matches_before_cursor
        endif
        if matches_after_cursor > 0
            let right_info_string = '+' . matches_after_cursor
        endif
        if matches_before_cursor > 0 && matches_after_cursor > 0
            let separator = ' | '
        endif
        " return printf("/%s %s%s%s (getmatchbytoffset_2)", @/, left_info_string, separator, right_info_string)
        return [
                    \ printf("/%s", @/), 
                    \ printf("%s%s%s", left_info_string, separator, right_info_string)
                    \ ]
    endif
endfunction
function! SplitMatchPositions(match_positions)
    let match_positions = a:match_positions
    let l:cursor_position = line2byte(".") + col(".") - 1


    " 0.0019
    let positions_before_match = filter(copy(match_positions), { _, value -> value < l:cursor_position })
    let positions_after_match = filter(copy(match_positions), { _, value -> value > l:cursor_position })
    " let before_count = len(positions_before_match)
    " let after_count = len(positions_after_match)
    " echo "before_count: ".before_count.", after_count: ".after_count

    return match_positions
endfunction
let s:print_count = 0
function! s:PrintRepeatInfo()
    function! s:MyPrint(...)
        let s:print_count = s:print_count + 1
        echo "MyPrint: " . s:print_count
    endfunction
    call timer_start(1, function("s:MyPrint"))
    " call s:MyPrint()
endfunction
function! s:Time()
    return reltimefloat(reltime())
endfunction
" let match_positions = dotty#GetMatchByteOffsets()
" let start_time = s:Time()
" call SplitMatchPositions(match_positions)
" call Profile()
" let time_taken = string(s:Time() - start_time)
" echo time_taken

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

function! AendswithB(a, b)
    let b_length = len(a:b)
    let a_length = len(a:a)
    let a_substring = strpart(a:a, a_length - b_length, a_length)
    return a_substring ==# a:b
endfunction

" NOTE strpart(s, 0, 5) != s[0:5]
function! AstartswithB(a, b)
    let b_length = len(a:b)
    let a_substring = a:a[0:b_length-1]
    if a_substring ==# a:b
        return v:true
    endif
    return v:false
endfunction
" nmap . values: <Plug>






" function! OldEcho()
"     call feedkeys(":set hls\<CR>")
"     " set hls
"     let match_positions = dotty#GetMatchByteOffsets()
"     let match_info_string = MatchByteOffsetsToString(match_positions)
"     let feedkeys_command = printf(":echo '%s'\<CR>", match_info_string)
"     call feedkeys(feedkeys_command)
" endfunction


let g:cached_positions = []
let g:pattern = ""
let g:changedtick = -1

" We don’t use "%s" and instead inline the command in the feedkeys to avoid
" all sorts of printing errors related to singlequotes and terminal characters
function! s:EchoSearchInfo()

    if g:pattern !=# @/
        let g:pattern = @/
        let g:cached_positions = dotty#GetMatchByteOffsets()
    elseif g:changedtick != b:changedtick
        let g:changedtick = b:changedtick
        let g:cached_positions = dotty#GetMatchByteOffsets()
    endif
    let match_positions = g:cached_positions



    if empty(match_positions)
        return
    endif
    let [ match_redundant, info ] = MatchByteOffsetsToString(match_positions)
    " let match = strtrans(@/)
    " let match = common#Truncate(match, v:echospace-20)
    let match_macro = 'common#Truncate(strtrans(@/),v:echospace-20)'
    let feedkeys_command = printf(":set hls | echon '/' . %s | echohl String | echon \" %s\" | echohl Normal\<CR>", match_macro, info)

    " Implementation 1: Need this for highlighting to show up when you press DOT
    call feedkeys(feedkeys_command)
    " echon '/' . Truncate(strtrans(@/),v:echospace-20) . ' '

    " call feedkeys(":set hls\<CR>")
    " set hls

    " Implementation 2
    " echon '/' . strtrans(@/). ' '
    " echohl String 
    " echon info 
    " echohl Normal

endfunction

let g:repeating = v:false
let g:n_required = v:false

" Tests - 
"     red, red, red, red, red
"     1, 1, 1, 1, 1
"     lime, lime, lime, lime
"     
function! s:UpdatePositionCache(...)
    let g:repeat_position_cache = dotty#GetMatchByteOffsets()
endfunction

noremap <silent> <Plug>(StartHL) :<C-U>set hlsearch<cr>
function! s:SetHls(timer_id)
    " silent call feedkeys(":silent set hls\<CR>")
    silent call feedkeys("\<Plug>(StartHL)", 'm')
endfunction

function! s:ShowHighlight(timer_id)
    set hls
endfunction
function! s:AsyncShowHighlight()
    call timer_start(1000, function("s:ShowHighlight"))
endfunction

function! s:PrintDebugInfo()
    " let g:repeat_position_cache = dotty#GetMatchByteOffsets()

    let l:cursor_position = line2byte(".") + col(".") - 1

    " 0.0019
    let positions_before_match = filter(copy(g:repeat_position_cache), { _, value -> value < l:cursor_position })
    let positions_after_match = filter(copy(g:repeat_position_cache), { _, value -> value > l:cursor_position })
    let before_count = string(len(positions_before_match))
    let after_count = string(len(positions_after_match))

    " let cache_integrity = g:repeat_position_cache == dotty#GetMatchByteOffsets()
    " let l:message = "Before: ".before_count.", After: ".after_count.", cache_integrity: ".cache_integrity
    let l:message = "Before: ".before_count.", After: ".after_count
    " call  timer_start(1, function('dotty#Callback', [l:message]))

    call common#AsyncPrint(l:message, 1)

endfunction
function! s:UpdatePositionCacheAndPrintDebugInfo(...)
    call  s:UpdatePositionCache()
    call  s:PrintDebugInfo()
endfunction
let g:repeat_position_cache = []
let g:match_identifier = -1
let g:match_window = -1

function! s:SliceList(L, start, end=-1)
    if a:start == a:end
        return []
    endif
    if a:end == -1
        return a:L[a:start:]
    endif
    return a:L[a:start:a:end-1]
endfunction


function! ResetRepeatMaps()
    " nnoremap . :norm! .<CR>
    nunmap .
    nunmap n
endfunction
function! s:RepeatChange()

    " When we want to rename ‘keyword’ to ‘my_keyword’
    " Simple heuristic check. 
    " Logical idea is to check via match() if the end of the inserted string,
    " @., matches the search pattern @/
    " Logging {{{
    let n_old = g:n_required
    let r_old = g:repeating
    let repeat_msg = "n_req,repeating:(".n_old.",".r_old.")->(".g:n_required.",".g:repeating.")"
    call s:NewCell(repeat_msg, "RepeatChange")
    " }}}

    " call s:NewCell(repeat_msg, "RepeatChange")
    if !g:n_required
        let pos_save = getpos(".")
        let col_save = col(".")
        call search(@/, "ce", line("."))
        let cursor_on_match_end = col_save ==# col(".")
        if cursor_on_match_end
            let g:n_required = v:true
            " normal! n
        endif
        call setpos(".", pos_save)
    endif

    " if g:n_required
    "     normal! n
    " endif
    let index_to_remove = -1
    if g:repeating
        silent! normal! n
        let cursor_position = line2byte(".") + col(".") - 1
        let index_to_remove = index(g:repeat_position_cache, cursor_position)
        if index_to_remove == -1
            echohl Error | echo "No more matches" | echohl Normal
            return
            let cache_size = len(g:repeat_position_cache)
            echoerr "len(g:repeat_position_cache) = " . cache_size
            echoerr "index_to_remove == -1; byte offset: ".cursor_position." not found"
        endif

        let positions_before_match = s:SliceList(g:repeat_position_cache, 0, index_to_remove)
        let positions_after_match = s:SliceList(g:repeat_position_cache, index_to_remove+1)

        call remove(g:repeat_position_cache, index_to_remove)

        normal! .

        let difference = strlen(@.) - strlen(@")
        call map(g:repeat_position_cache, { _, position -> position > cursor_position ? position + difference : position })

        call s:PrintDebugInfo()
        " call timer_start(1, function("s:PrintDebugInfo"))
    else
        let pattern_matches_entire_deleted_text = matchstr(@", @/) ==# @"
        let pattern_does_not_match_entire_deleted_text = !pattern_matches_entire_deleted_text
        if pattern_does_not_match_entire_deleted_text
            let search_string = String2Pattern(@")
            let @/ = search_string
        endif

        call feedkeys("cgn\<C-r>.\<Esc>")
        let g:repeating = v:true
        " call  timer_start(1, function('s:UpdatePositionCache'))
        " call  timer_start(50, function('s:PrintDebugInfo'))
        call  timer_start(1, function('s:UpdatePositionCacheAndPrintDebugInfo'))
        " call s:SetHls(1)
        let g:match_identifier = matchadd(s:search_highlight_group, @/)
        let g:match_window = win_getid()

    endif




endfunction
function! s:PrintByteOffset()
    let byte_offset = line2byte(".") + col(".") - 1
    echo "Byte Offset: " . byte_offset
endfunction
nnoremap <silent> go :call <SID>PrintByteOffset()<CR>



" TEST CASE MINI:
" function | function | function | function
" let soccer | let soccer
let g:override_pos = []
if !exists("g:mappings")
    let g:mappings = {}
endif
" https://vi.stackexchange.com/questions/7734/how-to-save-and-restore-a-mapping
function! s:SaveMappings(keys, mode, global) abort
    let mappings = {}

    if a:global
        for l:key in a:keys
            let buf_local_map = maparg(l:key, a:mode, 0, 1)

            sil! exe a:mode.'unmap <buffer> '.l:key

            let map_info        = maparg(l:key, a:mode, 0, 1)
            let mappings[l:key] = !empty(map_info)
                        \     ? map_info
                        \     : {
                        \ 'unmapped' : 1,
                        \ 'buffer'   : 0,
                        \ 'lhs'      : l:key,
                        \ 'mode'     : a:mode,
                        \ }

            call s:RestoreMappings({l:key : buf_local_map})
        endfor

    else
        for l:key in a:keys
            let map_info        = maparg(l:key, a:mode, 0, 1)
            let mappings[l:key] = !empty(map_info)
                        \     ? map_info
                        \     : {
                        \ 'unmapped' : 1,
                        \ 'buffer'   : 1,
                        \ 'lhs'      : l:key,
                        \ 'mode'     : a:mode,
                        \ }
        endfor
    endif

    return mappings
endfunction
function! s:RestoreMappings(mappings) abort

    for mapping in values(a:mappings)
        if !has_key(mapping, 'unmapped') && !empty(mapping)
            exe     mapping.mode
               \ . (mapping.noremap ? 'noremap   ' : 'map ')
               \ . (mapping.buffer  ? ' <buffer> ' : '')
               \ . (mapping.expr    ? ' <expr>   ' : '')
               \ . (mapping.nowait  ? ' <nowait> ' : '')
               \ . (mapping.silent  ? ' <silent> ' : '')
               \ .  mapping.lhs
               \ . ' '
               \ . substitute(mapping.rhs, '<SID>', '<SNR>'.mapping.sid.'_', 'g')

        elseif has_key(mapping, 'unmapped')
            sil! exe mapping.mode.'unmap '
                                \ .(mapping.buffer ? ' <buffer> ' : '')
                                \ . mapping.lhs
        endif
    endfor

endfu


" Bug: ma~da | ma~da
function! s:CheckIfCursorMoveWasCausedByDotOperator()
    " ASSUMPTION: Only works if the last CursorMove was triggered by a change.
    " If you do a change -> ESCAPE -> Go somewhere else then comeback manually,
    " this fn returns v:true which is incorrect. This function is only accurate
    " if we have already established the most recent cursor move was from a
    " change.
    "
    " After a dot operator takes place, we end up in normal mode. The impetus
    " for putting this if-condition was interference with UltiSnips. In
    " UltiSnips, pressing <Tab> to jump to the next placeholder was triggering
    " this check as it was counted as a CursorMove. This function being
    " executed in VisualMode was causing buggy behaviour.
    if mode() == "v" || mode() == "s"
        return v:false
    endif
    " previous attempts {{{
    " let condition_1 = @/ =~ @"
    " let condition_1 = @/ =~ String2Pattern(@")
    " let condition_1 = match(@", @/) > -1
    " }}}
    let pattern_matches_entire_deleted_text = matchstr(@", @/) ==# @"
    let condition_1 = pattern_matches_entire_deleted_text
    " echoerr "condition_1: " . string(condition_1)

    let view_save = winsaveview()
    let visual_start_save     = getpos("'<")
    let visual_end_save       = getpos("'>")
    let yank_start_save       = getpos("'[")
    let yank_end_save         = getpos("']")
    let quote_reg_save        = @"

    silent! normal! v`[y
    let string_between_yank_start_and_cursor = @"

    call winrestview(view_save)
    call setpos("'<", visual_start_save)
    call setpos("'>", visual_end_save)
    call setpos("'[", yank_start_save)
    call setpos("']", yank_end_save)
    let @" = quote_reg_save

    let condition_2 = string_between_yank_start_and_cursor ==# @.
    return condition_1 && condition_2

endfunction

function! s:CursorOnMatch()
    let [search_line, search_pos] = searchpos(@/, "cn")
    let [_, cursor_line, cursor_pos, _] = getpos(".")
    return search_line == cursor_line && search_pos == cursor_pos
endfunction

function! s:CursorOnMatchEnd()
    let [search_line, search_pos] = searchpos(@/, "cn")
    let [_, cursor_line, cursor_pos, _] = getpos(".")
    return search_line == cursor_line && search_pos == cursor_pos
endfunction


function! s:RemoveAllOverrides()
    call s:NewCell("fail", "RemoveAllOverrides")
    let pass_message = "pass: mappings, globals & au’s reset"
    let fail_message = "fail: cursor moved by dot operator"
    " Ignores the first CursorMoved fired immediately after leaving InsertMode
    if g:override_pos == getpos(".")
        return
    endif

    let cursor_move_was_caused_by_dot_operator = s:CheckIfCursorMoveWasCausedByDotOperator()
    " echoerr "cursor_move_was_caused_by_dot_operator: " . cursor_move_was_caused_by_dot_operator
    if cursor_move_was_caused_by_dot_operator
        call s:UpdateCell("fail: cursor moved by dot operator")
        return
    endif

    let cursor_on_match = s:CursorOnMatch()
    if cursor_on_match
        " Offload StopHl() responsibility to cool.vim
        " If dotty is only concerned about HL DURING Repeat, it removes a lof
        " of complexity from RepeatChange, InitializeDotOverride and
        " RemoveAllOverrides

        call s:SetHls(1) 
    endif


    if g:repeating
        call matchdelete(g:match_identifier, g:match_window)
        let g:match_identifier = -1
        let g:match_window = -1
    endif

    let g:override_pos = []
    let g:repeating = v:false
    let g:n_required = v:false
    au! DotOverride CursorMoved
    au! DotOverride InsertLeave
    call s:RestoreMappings(g:mappings)
    call s:UpdateCell("pass")
endfunction

" [knowledge] RepeatChange chaining, n override edge case {{{
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
    let pattern_matches_entire_deleted_text = matchstr(@", @/) ==# @"
    let pattern_does_not_match_entire_deleted_text = !pattern_matches_entire_deleted_text
    if pattern_does_not_match_entire_deleted_text
        let search_string = String2Pattern(@")
        let @/ = search_string
    endif
    " let no_more_matches = search()
    let no_more_matches = search(@/, 'n') == 0
    if no_more_matches
        " echo 'no more matches'
        call s:UpdatePositionCacheAndPrintDebugInfo()
    else
        call feedkeys("n", "n")
    endif
endfunction

function! s:ToggleWholeKeywordOverride()
    " Duplicate 1, Original: RepeatChange
    let pattern_matches_entire_deleted_text = matchstr(@", @/) ==# @"
    let pattern_does_not_match_entire_deleted_text = !pattern_matches_entire_deleted_text
    if pattern_does_not_match_entire_deleted_text
        let search_string = String2Pattern(@")
        let @/ = search_string
    endif
    set hls
    call s:ToggleWholeKeyword()
    call s:ModifyDotOverride()
    nnoremap <silent> gs :call <SID>ToggleWholeKeyword()<CR>
endfunction

function! s:InitializeDotOverride()

    call s:NewRow("fail", "InitializeDotOverride")
    " Prevents Overrides from overlapping
    if g:override_pos != []
        return
    endif
    let g:override_pos = getpos(".")
    let g:mappings = s:SaveMappings([".", "n", "gs"], "n", v:true)
    nnoremap <silent> . :call <SID>RepeatChange()<CR>
    nnoremap <silent> n :call <SID>NextPatternOverride()<CR>
    nnoremap <silent> gs :call <SID>ToggleWholeKeywordOverride()<CR>


    let should_check_cursor_move = v:true
    let cursor_move_was_caused_by_dot_operator = s:CheckIfCursorMoveWasCausedByDotOperator()
    if should_check_cursor_move && cursor_move_was_caused_by_dot_operator && v:hlsearch
        " v:hlsearch solves Problem 2 and Problem 4
        call s:UpdatePositionCache()
        let g:repeating = v:true
        let g:match_identifier = matchadd(s:search_highlight_group, @/)
        let g:match_window = win_getid()

    endif

    au DotOverride CursorMoved * call s:RemoveAllOverrides()
    call s:UpdateCell("pass")


endfunction

function! s:YankPost()
    if v:event["operator"] ==# "y" || v:event["operator"] ==# "d"
        return
    endif
    if !g:dot_modifications_enabled
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
function! s:ModifyDotOverride()
    let normal_dot_map = mapcheck(".", "n")
    let dot_mapped_to_repeat_change = stridx(normal_dot_map, "RepeatChange")
    if dot_mapped_to_repeat_change
        " v:false means don’t update the search register with the deleted text
        nnoremap <silent> . :call <SID>RepeatChange()<CR>
    endif
endfunction

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
    set hls
    redraw|echo "/" . search_pattern
endfunction

vnoremap <silent> *  :<c-u>call <SID>VisualStar()<CR>
vnoremap <silent> #  :<c-u>call <SID>VisualHash()<CR>
vnoremap <silent> gd :<c-u>call <SID>Visual_gd()<CR>
vnoremap <silent> s  :<c-u>call <SID>VisualReplace()<CR>

nnoremap <silent> gs :call <SID>ToggleWholeKeyword()<CR>

cabbrev vv v/<C-r>=@/<CR>
cabbrev gg g/<C-r>=@/<CR>
cabbrev ss s/<C-r>=@/<CR>
cabbrev <expr> tt getcmdtype() ==# ":" ? 'Tab/<C-r>=@/<CR>' : 'tt'

" [1] Initial State
" ... let two = 1
"         ^
" ... let one = 2
"
" [2] Change 'two to 'one'
"
" [3] Changed State-
" ... let one = 1
"           ^
" ... let one = 2
"
" [4] Registers before function call
"  @. = 'one', @" = 'two' 


let g:time_counter = 0
let g:loglines = []
function! s:ResetLogs()
    let g:time_counter = 0
    let g:loglines = []
endfunction
function! s:NewRow(message, fname)
    " let g:time_counter = 0
    call insert(g:loglines, [], 0) " Create a new entry
    call s:NewCell(a:message, a:fname)
endfunction
function! s:NewCell(message, fname)
    call insert(g:loglines[0], [a:fname, a:message, g:time_counter], 0)
    let g:time_counter = g:time_counter + 1
endfunction
function! s:UpdateCell(message)
    let row = g:loglines[0]
    let cell = row[0]
    let g:loglines[0][0] = [ cell[0], a:message, cell[2] ]
endfunction
function! s:PrintLogs()
    for row in g:loglines
        for cell in row
            let [func, msg, order] = cell
            echo order.":".func.": ".msg
        endfor
        echo "----------------------------------"
    endfor
endfunction

" call s:NewRow("pass", "InitializeDotOverride")
" call s:NewCell("fail", "RemoveAllOverrides")
" call s:UpdateCell("pass")

" call s:NewRow("pass", "CursorMoved")
" call s:NewCell("fail", "String2Pattern")
" call s:NewCell("fail", "NewRow")
" call s:PrintLogs()


function! s:Exchange()
    let search_string = String2Pattern(@.)
    let @/ = search_string
    " nunmap n
    call search(@/)
    call feedkeys("cgn\<C-r>0\<Esc>")
endfunction

" let two = 1
" let one = 2
" -----------
" let two = 1
" let one = 2
nnoremap  cx :call <SID>Exchange()<CR>


if !exists("g:permanent_mappings")
    const g:permanent_mappings = s:SaveMappings([".", "n", "gs"], "n", v:true)
endif
function! s:HardRestoreMappings()
    call s:RestoreMappings(g:permanent_mappings)
endfunction

" let search_key = "for"
function! s:MatchCount(search_key)
    let buffer_contents = join(getline(1, '$'), "\n")
    let search_key = a:search_key
    let match_count = 1
    let indices = []
    while v:true
        let match_index = match(buffer_contents, search_key, 0, match_count)
        if match_index == -1 || match_count > 10000
            break
        endif
        call add(indices, match_index)
        let match_count = match_count + 1
    endwhile
    let total_matches = len(indices)
    echo "total_matches: ".total_matches
endfunction
command! -nargs=1  MatchCount call  s:MatchCount(<q-args>)


" let total_matches = count(buffer_contents, search_key)




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

" let s:buffer_contents = ""
let s:popup_id = -1
function! s:InitializeCountInfo()
    " let s:buffer_contents = join(getline(1, '$'), "\n")
    let s:popup_id = s:DrawPopupOnCmdline("Sample Text")
endfunction


" Debug {{{
function! s:ReproduceSearchError()
    let search_string = '/^\s*function!\?\s\+\('
    call search(search_string, 'wn')
    return search_string
endfunction
nnoremap <expr> ga <SID>ReproduceSearchError()
let s:log_call_count = 0
let s:log_cache = ''
function! s:Log(symbol)
    let symbol = a:symbol
    let s:log_call_count = s:log_call_count + 1
    if symbol !=# "LEAVE"
        let s:log_cache = getcmdline()
    endif
    if symbol ==# "LEAVE"
        " echoerr "s:log_call_count: ".s:log_call_count.'; s:log_cache: '.s:log_cache
        " let s:log_call_count = 0
        " let s:log_cache = ''
        let search_value = search(s:log_cache, 'wn')
        echoerr 'search_value: '.search_value
    endif
    
endfunction
augroup LogCmdlineEvents
    au!
    " au CmdlineEnter   /,\? call s:Log("ENTER")
    " au CmdlineChanged /,\? call s:Log("CHANGE")
    " au CmdlineLeave   /,\? call s:Log("LEAVE")
augroup END

function! s:CompareBufferFetchMethods()
    let reg_save = @"
    silent 1,$y
    let buf1 = @"[:-2]
    let @" = reg_save
    let buf2 = join(getline(1, '$'), "\n")
    echo "buf1: ".len(buf1)
    echo "buf2: ".len(buf2)
    let is_equal = buf1 ==# buf2
    echo "is_equal: ".is_equal

endfunction

function! s:Count_Implementation_2()
    let start_time = common#Time()
    " 0.001
    " let buffer_contents = join(getline(1, '$'), "\n")
    " let pattern_count = count(buffer_contents, @/)

    " 0.02
    " let offsets = dotty#GetMatchByteOffsets()
    " let pattern_count = len(offsets)

    let search_result = search(@/, 'wn')
    if search_result == 0
        let pattern_count = 0
    else
        let msg = ""
        redir => msg
        silent %s///gn
        redir END
        let pattern_count = str2nr(trim(msg))
    endif


    let time_taken = common#Time() - start_time
    echo "time_taken: ".printf("%f", time_taken).", count: ".pattern_count
    " echo "time_taken: ".printf("%f", time_taken)

    
endfunction
" }}}

function! s:HandleBackslash(s)
    let s = a:s
    let index = match(s, '\\\+$')
    if count(s[index:], '\') % 2 == 1
        let s = strpart(s, 0, len(s)-1)
    endif
    return s
endfunction
" echo s:HandleBackslash('^abcd\\\\efgh\\\\')


function! s:GetErrorMessage()
    try
        call search('\z', 'wn')
    catch
        let @" = v:exception
        echo 'let @" = '''.v:exception.''''
    endtry
endfunction

" BUG: As you type a group, there is a chance of an unmatched group being
" searched. Example: '/function\(s:\)'. While typing, a search(@/) is being
" executed on every keystroke. This throws an E54 unmatched \( error. If you
" type '/function\(' and then press ENTER, you will also see an E54 error.
"
" SOLUTION: Catch errors in serach() call and return on error
function! s:PrintCountInfo()
    if getcmdline() == ""
        call popup_move(s:popup_id, {"col" : 4 })
        call popup_settext(s:popup_id, "")
        return
    endif

    " let search_result = search(cmdline, 'wn') {{{
    let cmdline = getcmdline()
    " Implementation 1 (doesn’t work for regular expressions)
    " " let pattern_count = count(s:buffer_contents, cmdline)
    " Implementation 2
    " let search_result = search(cmdline, 'wn')
    let cmdline = s:HandleBackslash(cmdline)
    let search_result = search(cmdline, 'wn')
    try
        let search_result = search(cmdline, 'wn')
    catch /^Vim(let):E54/
        " PATTERN = /\(/
        return
    catch /^Vim(call):E867/
        " PATTERN = /\z/
        return
    catch /^Vim(let):E385/
        " WRAPPED AROUND
        return
    endtry
    " }}}

    if search_result == 0
        let pattern_count = 0
    else
        let msg = ""
        redir => msg
        silent execute '%s/'.cmdline.'//gn'
        redir END
        let g:t = cmdline
        let pattern_count = str2nr(trim(msg))
    endif
    if !exists("pattern_count")
        let pattern_count = -1
    endif

    let message_color = pattern_count > 0 ? 'String' : 'WarningMsg'
    let occurence_string = pattern_count == 1 ? 'occurence' : 'occurences'
    let text = pattern_count.' '.occurence_string
    call popup_move(s:popup_id, {"col" : 4 + len(cmdline)})
    call popup_settext(s:popup_id, text)
    call setwinvar(s:popup_id, '&wincolor', message_color)
endfunction



augroup ShowCountWhileTyping
    au!
    au CmdlineEnter   / call s:InitializeCountInfo()
    au CmdlineChanged / call s:PrintCountInfo()
    au CmdlineLeave   / call s:ClosePopup()
augroup END

