" TODO:
" 1 - Study error handling and failure method call stack
" 2 - Find next and previous method call
" Index_List:
" moveForward.setSpeed(normalSpeed);
" 0-----------1------2------------3
" 0 - [AI]m_start  - large_start
" 1 - [ia]m_start  - small_start
" 2 - [iI]m_finish - inside_finish
" 3 - [aA]m_finish - around_finish
" names   = [large_start , small_start , inside_finish , around_finish ]
"
" Two Important Functions:
" 1 - ParseLine 
" 2 - GetIndexListRelativeToCursor
"
" ParseLine:
" This function takes a line and parses it for methods and nested methods. The
" result in a list of the above defined data structure i.e, 
" ParseList -> line -> [Index_List]
" The size of the returned list is the same as the number of method calls in the
" line. 
" As can be seen above, each index_list has 4 numbers, which indicate the
" array index of the line which is significant for text object manipulation.
"
" ParseLine maintains two stacks - parse_stack and a return_stack
" The function keeps track of 3 variables:
" 1. The start of the last valid function name - small_start/fname_begin_index
" 2. The end of the last valid function name - inside_finish/fname_end_index 3.
" The start of the last big function call - large_start/callname_begin_index
"
" When it encounters an opening parenthesis '(', it pushes these 3 onto
" parse_stack. Nested function calls are handled this way. When it encounters a
" closing parenthesis ')', it pops the most recent indices, creates and
" index_list data structure by using the position of the current ')' as the
" value for around_finish and pushes this into the return data structure
" 
" GetIndexListRelativeToCursor:
" If the cursor is in a method-textobject(s), it get's the innermost text-object
" index_list which contains the cursor
" If the cursor is outside a textobject, it scans right for the first
" text-object and returns it's index_list
" If the right scan fails, it scans left
" }}}

" ParseLine {{{
function! s:ParseLine(line)
    let current_line = a:line
    let length = len(current_line)
    let index = 0
    
    let on_valid_fname = v:false
    let on_valid_callname = v:false
    
    let fname_begin_index = -1
    let fname_end_index = -1
    let callname_begin_index = -1
    
    let parse_stack = []
    let return_stack = []
    
    while index < length
        let c = current_line[index]
        
        if !on_valid_fname
            if c =~ '\w\|[-]'
                let on_valid_fname = v:true
                let fname_begin_index = index
            endif
        elseif on_valid_fname
            if c !~ '\w\|[-]'
                let on_valid_fname = v:false
                let fname_end_index = index - 1
            endif
        endif
        
        if !on_valid_callname
            if c =~ '\w\|[\.#:]'
                let on_valid_callname = v:true
                let callname_begin_index = index
            endif
        elseif on_valid_callname
            if c !~ '\w\|[\.#:]'
                let on_valid_callname = v:false
            endif
        endif
        
        if c == '('
            call add(parse_stack, [fname_begin_index, fname_end_index, callname_begin_index])
        elseif c == ')'
            if !empty(parse_stack)
                let [small_start, inside_finish, large_start] = remove(parse_stack, -1)
                let around_finish = index
                let index_list = [large_start , small_start , inside_finish , around_finish ]
                call add(return_stack, index_list)
            endif
        endif
        
        let index = index + 1
    endwhile
    
    return return_stack
endfunction
" }}}

" Method Call Text Object {{{
" Test Cases
" Examples:
" Fine:
"*long.name.functio(horizontal)
" g()
" vanilla_func(one_arg)
" 2 * 3 * long_name_number_2 (nice_stuff)
" outer_function( inner_function_one    ( ok ), inner_function_two() )
" let character_under_cursor = strpart(current|_line, col(".")-1, 1)
" no_args()
" elseif c == ')'
" elseif c == '('
" Not Fine For AM:
" outer_function((ok), inner_function_two() )
" call search('[()]', 'c')
" Not Fine For Both:
" Does not work for GetComponent<Something>();

function! s:SortByNthItem(lhs, rhs, n)
    let LEFT_BEFORE_RIGHT = -1
    let RIGHT_BEFORE_LEFT = 1
    if a:lhs[a:n] < a:rhs[a:n]
        return LEFT_BEFORE_RIGHT
    else
        return RIGHT_BEFORE_LEFT
    endif
endfunction

function! s:SortByFirstItem(lhs, rhs)
    return s:SortByNthItem(a:lhs, a:rhs,0)
endfunction

function! s:SortByFourthItem(lhs, rhs)
    return s:SortByNthItem(a:lhs, a:rhs,3)
endfunction

function! s:GetSortedIndexLists(line)
    let index_lists = s:ParseLine(a:line)
    return sort(index_lists, function('s:SortByFirstItem'))
endfunction

function! s:GetIndexListRelativeToCursor()
    let current_line = getline('.')
    let index_lists = s:GetSortedIndexLists(current_line)
    
    if empty(index_lists)
        return [-1, -1, -1, -1]
    endif
    
    " Check if cursor is in methodtextobj
    let cursor_index = col('.') - 1
    let index_list = [-1, -1, -1, -1]
    for [beg, a, b, end] in index_lists
        if cursor_index >= beg && cursor_index <= end
            if index_list[0] < beg
                let index_list = [beg, a, b, end]
            endif
        endif
    endfor
    
    " Search for closest method to the right
    if index_list[0] == -1
        for L in index_lists
            " Assumes index_lists is sorted
            " Get first index_list to right of cursor
            if L[0] > cursor_index
                let index_list = L
                break
            endif
        endfor
    endif
    
    " Cursor is to the right of the last method call
    if index_list[0] == -1
        call sort(index_lists, function('s:SortByFourthItem'))
        let index_list = index_lists[-1]
    endif
    
    return index_list
endfunction

function! s:SelectIndexListItems(beg_list_index, end_list_index, index_list)
    let beg_index = a:index_list[a:beg_list_index]
    let end_index = a:index_list[a:end_list_index]
    if beg_index == -1
        return
    endif
    return [beg_index, end_index]
endfunction

function! s:IndexToPosList(beg_index, end_index)
    
    let head_pos = getpos('.')
    let head_pos[2]= a:beg_index + 1
    
    let tail_pos = getpos('.')
    let tail_pos[2] = a:end_index + 1
    
    return ['v', head_pos, tail_pos]
endfunction

function! s:GetPosList(beg_list_index, end_list_index)
    let index_list = s:GetIndexListRelativeToCursor()
    if index_list[0] == -1
        return 
    endif
    let [beg_index, end_index] = s:SelectIndexListItems(a:beg_list_index, a:end_list_index, index_list)
    return s:IndexToPosList(beg_index, end_index)
endfunction

function! s:CurrentFnameA()
    if col('$') > 1000
        redraw | echohl ErrorMsg | echo 'Line has more than 1000 characters. Faster to select manually.' | echohl None
        return
    endif
    return s:GetPosList(1, 3)
endfunction

function! s:CurrentFnameI()
    if col('$') > 1000
        redraw | echohl ErrorMsg | echo 'Line has more than 1000 characters. Faster to select manually.' | echohl None
        return
    endif
    return s:GetPosList(1, 2)
endfunction

function! s:CurrentFnameBigI()
    if col('$') > 1000
        redraw | echohl ErrorMsg | echo 'Line has more than 1000 characters. Faster to select manually.' | echohl None
        return
    endif
    return s:GetPosList(0, 2)
endfunction

function! s:CurrentFnameBigA()
    if col('$') > 1000
        redraw | echohl ErrorMsg | echo 'Line has more than 1000 characters. Faster to select manually.' | echohl None
        return
    endif
    return s:GetPosList(0, 3)
endfunction

function! s:VisualSelect(L)
    if type(a:L) != v:t_list
        return
    endif

    let [_, start_pos, end_pos] = a:L
    call setpos('.', start_pos)
    normal! v
    call setpos('.', end_pos)
endfunction

xnoremap  <silent> im :<c-u>call <sid>VisualSelect(<sid>CurrentFnameI())<CR>
xnoremap  <silent> am :<c-u>call <sid>VisualSelect(<sid>CurrentFnameA())<CR>
xnoremap  <silent> aM :<c-u>call <sid>VisualSelect(<sid>CurrentFnameBigA())<CR>
xnoremap  <silent> iM :<c-u>call <sid>VisualSelect(<sid>CurrentFnameBigI())<CR>

onoremap  <silent> im :<c-u>call <sid>VisualSelect(<sid>CurrentFnameI())<CR>
onoremap  <silent> am :<c-u>call <sid>VisualSelect(<sid>CurrentFnameA())<CR>
onoremap  <silent> aM :<c-u>call <sid>VisualSelect(<sid>CurrentFnameBigA())<CR>
onoremap  <silent> iM :<c-u>call <sid>VisualSelect(<sid>CurrentFnameBigI())<CR>

nmap csm cim

augroup MethodTextObj
    au!
    au BufRead * silent! nunmap <buffer> ]m
    au BufRead * silent! vunmap <buffer> ]m
    au BufRead * silent! nunmap <buffer> [m
    au BufRead * silent! vunmap <buffer> [m
augroup END
nnoremap <silent> ]m :call search('[a-zA-Z.0-9_]\+\s*\ze(')<CR>
vnoremap <silent> ]m :call search('[a-zA-Z.0-9_]\+\s*\ze(')<CR>

nnoremap <silent> [m :call search('[a-zA-Z.0-9_]\+\s*\ze(', 'b')<CR>
vnoremap <silent> [m :call search('[a-zA-Z.0-9_]\+\s*\ze(', 'b')<CR>

" console.log("hello");
" print("Hey")
" print("Hey")
" print("Hey")
" print("Hey")
" print("Hey")
function! s:DeleteSurroundingMethod()
    call repeat#set("\<Plug>DeleteSurroundingMethod")
    let pos_list = s:CurrentFnameBigA()
    let [_, _, end_pos] = pos_list
    let [_, _, around_finish_col, _] = end_pos
    exec 'call cursor(".", ' . around_finish_col . ')'

    let reg_save = @a
    normal! "ayi)
    call s:VisualSelect(pos_list)
    normal! "ap
    normal! `<

    let @a = reg_save
endfunction

nmap  <silent> <Plug>DeleteSurroundingMethod :<c-u>call <sid>DeleteSurroundingMethod()<CR>
nmap  <silent> dsm <Plug>DeleteSurroundingMethod
" }}}

function! Log(m, poslist)
    let mode = a:m
    call s:VisualSelect(s:CurrentFnameBigA())
    let lines = [ mode ]
    let log_filepath = expand('~\vimfiles\plugin\method_usecases.txt')
    call writefile(lines, log_filepath, "a")
endfunction


nmap <Space>m ysiWf
