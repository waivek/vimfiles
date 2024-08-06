
function! s:rfind(table, fn)
    " takes a list and a function and returns the index of the last element
    " that satisfies the function
    let l:idx = -1
    for l:idx in range(len(a:table) - 1, 0, -1)
        if call(a:fn, [l:idx, a:table[l:idx]]) == 1
            return l:idx
        endif
    endfor
endfunction

function! s:LocalSymbols()
    let l:table = CocAction('documentSymbols')
    let l:current_line_number = line('.')
    " do a filter to get only the symbols that are in the same scope
    call filter(l:table, {idx, val -> val.lnum <= l:current_line_number})
    " find the last row where they kind is 'Function' or 'Method' and remove everything
    " before that
    let l:idx = s:rfind(l:table, {idx, val -> val.kind == 'Function' || val.kind == 'Method'})
    if l:idx == -1
        echo "No last function found"
        return
    endif
    let l:table = l:table[l:idx:]



    let l:tuple_table = []
    for l:row in l:table
        " level, kind, text, lnum, col
        " echo printf("%d:%d (level=%d) (type=%s) %s", l:row.lnum, l:row.col, l:row.level, l:row.kind, l:row.text)
        call add(l:tuple_table, [l:row.lnum.':'.l:row.col, l:row.level, l:row.kind, l:row.text])
    endfor
    call utils#print_tuple_table(l:tuple_table)

endfunction

command! -nargs=0 LocalSymbols call s:LocalSymbols()
