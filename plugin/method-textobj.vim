" Documentation {{{
" TODO:
" 1 - Study error handling and failure method call stack
" 2 - Formally define the delimiters for toggling on_valid_callname
" 3 - Find next and previous method call
" Index_List:
" moveForward.setSpeed(normalSpeed);
" 0-----------1------2------------3
" 0 - [AI]m_start  - large_start
" 1 - [ia]m_start  - small_start
" 2 - [iI]m_finish - inside_finish
" 3 - [aA]m_finish - around_finish
" names   = [large_start , small_start , inside_finish , around_finish ]
"
" Two Important Functions - ParseLine and GetIndexListRelativeToCursor
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
            if c =~ '\w'
                let on_valid_fname = v:true
                let fname_begin_index = index
            endif
        elseif on_valid_fname
            if c !~ '\w'
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
"*long.name.function(horizontal)
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

" call textobj#user#plugin('fname', {
" \    'code': {
" \        '*sfile*': expand('<sfile>:p'),
" \        'select-a-function' : 's:CurrentFnameA',
" \        'select-a' : 'am',
" \        'select-i-function' : 's:CurrentFnameI',
" \        'select-i' : 'im',
" \    }
" \})
" 
" call textobj#user#plugin('fnamebig', {
" \    'code': {
" \        '*sfile*': expand('<sfile>:p'),
" \        'select-a-function' : 's:CurrentFnameBigA',
" \        'select-a' : 'aM',
" \        'select-i-function' : 's:CurrentFnameBigI',
" \        'select-i' : 'iM',
" \    }
" \})

" }}}

let g:surround_109 = "\1fname: \1(\r)"

function! s:dosurround() " {{{1
  let cb_save = &clipboard
  set clipboard-=unnamed clipboard-=unnamedplus
  let original = getreg('"')
  let otype = getregtype('"')

  call setreg('"',"")
  exe 'norm! di('
  let keeper = getreg('"')
  " One character backwards
  call search('\m.', 'bW')
  exe "norm! da("
  let keeper = substitute(keeper,'^\s\+','','')
  let keeper = substitute(keeper,'\s\+$','','')
  if col("']") == col("$") && col('.') + 1 == col('$')
    let pcmd = "p"
  else
    let pcmd = "P"
  endif
  call setreg('"',keeper,"v")
  silent exe 'norm! ""'.pcmd.'`['

  call setreg('"',original,otype)
  let &clipboard = cb_save
endfunction " }}}1

" nnoremap <silent> <Plug>Dsurround :<C-U>call <SID>dosurround()<CR>
function! DeleteSurroundingMethod ()
    normal dim
    call search('(', 'c', line('.'))
    call s:dosurround()
endfunction

function! DeleteSurroundingBigMethod ()
    normal diM
    call search('(', 'c', line('.'))
    call s:dosurround()
endfunction

function! s:DebugMethodTextobject(line)
    " if a:line == v:null
    "     let a:line = "moveForward.setSpeed(long_function_name(some_arg(g()))) + another_function#textobj(argument)"
    " endif
    
    let L = s:ParseLine(a:line)
    let sep = '_'
    
    for [large_start , small_start , inside_finish , around_finish ] in L
        echo 'FUNCTION: ' a:line[large_start:around_finish]
        let aM_sep = repeat(sep, around_finish - large_start + 1 - 2)
        
        let aM_padding = repeat(' ', large_start)
        let aM_str = aM_padding . 'A' . aM_sep . 'm'
        echo aM_str
        
        echo a:line
        
        let im_sep = repeat(sep, inside_finish - small_start + 1 - 2)
        let im_padding = repeat(' ', small_start)
        let im_str = im_padding . 'i' . im_sep . 'm'
        echo im_str
        
        " echo "aM:" a:line[large_start:around_finish] "|"
        " echo "iM:" a:line[large_start:inside_finish] "|"
        " echo "im:" a:line[small_start:inside_finish] "|"
        " echo "am:" a:line[small_start:around_finish] "|"
        echo repeat('_', 160)
    endfor
endfunction

function! s:NextMethodExistsOnLine(index_lists, cursor_index)
    let last_index_list = a:index_list[-1]
    let [large_start, _, _, _] = last_index_list
    if a:cursor_index < large_start
        return v:true
    else
        return v:false
    endif
endfunction


function! GoToNextMethod()
    let cursor_index = col('.') - 1
    let current_line = getline('.')
    let index_lists = s:GetSortedIndexLists(current_line)
    
    if !empty(index_lists)
        if s:NextMethodExistsOnLine(index_lists, cursor_index)
            
            let index_list = []
            for L in index_lists
                " Assumes index_lists is sorted
                " Get first index_list to right of cursor
                if L[0] > cursor_index
                    let index_list = L
                    break
                endif
            endfor
            
        endif
    endif
    
endfunction

nnoremap <silent> <Plug>DeleteSurroundingBigMethod :call DeleteSurroundingBigMethod()<CR>:silent! call repeat#set("\<Plug>DeleteSurroundingBigMethod", v:count)<CR>
nnoremap <silent> <Plug>DeleteSurroundingMethod :call DeleteSurroundingMethod()<CR>:silent! call repeat#set("\<Plug>DeleteSurroundingMethod", v:count)<CR>
nnoremap <silent> <Plug>Dsurround :<C-U>call <SID>dosurround()<CR>
nmap db <Plug>Dsurround
nmap dsm <Plug>DeleteSurroundingMethod

" call s:DebugMethodTextobject(getline("."))

" call s:DebugMethodTextobject()

" echo s:GetSortedIndexLists(line)

" let line = 2*3*4*long.name.function(horizontal)

" echo s:ParseLine(getline("."))

" g()
" vanilla_func(one_arg)
" 2 * 3 * long_name_number_2 (nice_stuff)
" outer_function( inner_function_one    ( ok ), inner_function_two() )
" let character_under_cursor = strpart(current|_line, col(".")-1, 1)
" no_args()
" elseif c == ')'
" elseif c == '('
