" Programming Takeaways:
" 1/    FUNCTIONS WITH PREDICTABLE RESULTS ARE POWERFUL ABSTRACTIONS
"       ============================================================
"       To navigate to the number and mark it, I used search() instead of
"       precise logic. This abstraction helped avoid lot of bugs and
"       conditions and also made iteration faster. The search() building block
"       was a general tool that led to predictable results.
"
" 2/    SIMPLIFIED CASES HELP ERROR REASONING
"       =====================================
"       Having the cases for `1` be specific and the `1.00` be generalized was
"       enligthening. We can easily merge `1` with `1.00` and calculate the
"       precision and step for all numbers. However, this provides us with a
"       subsetted test case that is easy to debug. We don’t have to understand
"       the logic of the precision portion for a lot of bug handling and can
"       reason about the simplified case of step=1 itself.

" TEST CASES:
" 0.05
" 1
" 1.0
" 0.01
" inset 10px hello 9px
" inset -10.3px hello 9px
" uppercase

" 8.30 / 139
nmap <silent> <Plug>IncrementNumber :<c-u>call IncrementNumber(v:count1)<CR>
nmap <silent> <C-a> <Plug>IncrementNumber
nmap <silent> <Plug>DecrementNumber :<c-u>call DecrementNumber(v:count1)<CR>
nmap <silent> <C-x> <Plug>DecrementNumber

" <c-c> cycle:
" uppercase, lowercase
" left, right, center, justify
" relative, absolute
" opened, closed
" start, end

function! MarkNumber()
    " while character under cursor not in [0-9.], move back by 1 byte
    call search('-\?[0-9]\+\(\.\?[0-9]\+\)\?', "ce", line(".")) " we want to search forward first

    call search('-\?[0-9]\+\(\.\?[0-9]\+\)\?', "bc", line("."))
    call search('-\?[0-9]\+\(\.\?[0-9]\+\)\?',  "c", line("."))
    normal! ma
    call search('-\?[0-9]\+\(\.\?[0-9]\+\)\?', "ce", line("."))
    normal! mb
    normal! `av`by
endfunction

function! LeadingZeroes(number_str)
    let int_str = split(a:number_str, '[\.-]')[0] " -012.34 -> 012
    return len(int_str) - len(str2nr(int_str))
endfunction

function! cacx#PadIfReqd(from, to)

    " Without this check, 1000 decrement will go to 0999. Automatically inserts padding.
    let has_leading_zeroes = LeadingZeroes(a:from) 
    if !has_leading_zeroes
        return a:to
    endif
    

    let numbers_before_dot = split(a:from, '[\.-]')[0]
    let min_int_width = len(numbers_before_dot)
    let format = '%0' . string(min_int_width) . 'd'

    " 002.7
    "  340
    let minus_str      = a:to[0] == "-" ? "-" : ""
    let before_dot_str = printf(format, abs(str2nr(a:to)))
    let dot_str        = stridx(a:to, ".") == -1 ? "" : "."
    let after_dot_str  = stridx(a:to, ".") == -1 ? "" : split(a:to, '[\.]')[1]

    return minus_str.before_dot_str.dot_str.after_dot_str
endfunction
function! IncrementNumber(count1)

    if exists("*repeat#set")
        call repeat#set("\<Plug>IncrementNumber", a:count1)
    endif

    " @a, @b, @"
    call MarkNumber()
    let number_str = @"
    let number_float = str2float(number_str)

    if stridx(number_str, ".") == -1
        let inc_number = float2nr(number_float) + 1 * a:count1
        let inc_number_str = string(inc_number)
        let @" = cacx#PadIfReqd(number_str, inc_number_str)
        normal! `av`bp
        return
    endif

    " verified: we are handling numbers with precision
    let [ before_dot, after_dot ] = split(number_str, '\.')
    let precision = len(after_dot)
    let leading_zeroes = precision - 1
    let step = str2float("0." . repeat("0", leading_zeroes) . "1")
    let inc_number = number_float + step * a:count1
    let printf_template = '%.' . precision . 'f' " to get something like %.2f
    let inc_number_str = printf(printf_template, inc_number)
    let @" = cacx#PadIfReqd(number_str, inc_number_str)
    normal! `av`bp
    " until we figure out how to stop undo from changing cursor positoin
    " normal! `[
endfunction

function! DecrementNumber(count1)
    if exists("*repeat#set")
        call repeat#set("\<Plug>DecrementNumber", a:count1)
    endif
    " @a, @b, @"
    call MarkNumber()
    let number_str = @"
    let number_float = str2float(number_str)
    if stridx(number_str, ".") == -1
        let inc_number = float2nr(number_float) - 1 * a:count1
        let inc_number_str = string(inc_number)
        let @" = cacx#PadIfReqd(number_str, inc_number_str)
        normal! `av`bp
        return
    endif

    " verified: we are handling numbers with precision
    let [ before_dot, after_dot ] = split(number_str, '\.')
    let precision = len(after_dot)
    let leading_zeroes = precision - 1
    let step = str2float("0." . repeat("0", leading_zeroes) . "1")
    let inc_number = number_float - step * a:count1
    let printf_template = '%.' . precision . 'f' " to get something like %.2f
    let inc_number_str = printf(printf_template, inc_number)
    let @" = cacx#PadIfReqd(number_str, inc_number_str)
    normal! `av`bp
    " until we figure out how to stop undo from changing cursor positoin
    " normal! `[ 
endfunction
