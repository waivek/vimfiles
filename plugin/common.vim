function! common#AendswithB(a, b)
    let b_length = len(a:b)
    let a_length = len(a:a)
    let a_substring = strpart(a:a, a_length - b_length, a_length)
    return a_substring ==# a:b
endfunction
" NOTE strpart(s, 0, 5) != s[0:5]
function! common#AstartswithB(a, b)
    let b_length = len(a:b)
    let a_substring = a:a[0:b_length-1]
    if a_substring ==# a:b
        return v:true
    endif
    return v:false
endfunction

function! common#Time()
    return reltimefloat(reltime())
endfunction
function! s:Callback(message, timer_id)
    let message = a:message
    echo message
endfunction

function! common#AsyncPrint(message, duration=1)
    let duration = a:duration
    let message = a:message
    call  timer_start(duration, function('s:Callback', [message]))
endfunction

" function! common#FindMatches(expr, pat)
"     let expr = a:expr
"     let pat = a:pat
"     let match_count = count(pat, '\(')
"     if match_count == 0
"         return [ expr ]
"     endif
"     let match_groups = []
"     for i in range(match_count+1)
"         let submatch_expression = printf('\=submatch(%d)', i)
"         let match_group = substitute(expr, pat, submatch_expression, "")
"         echo match_group
"         call add(match_groups, match_group)
"     endfor
"     return match_groups
" endfunction
" echo common#FindMatches("abcdef", 'a\(.\)cd')

function! common#Truncate(s, l)
    let string = a:s
    let length = a:l
    if len(string) < length
        return string
    endif
    let middle_string = "..."
    let slice_size = (length - len(middle_string)) / 2
    " 80, 38, 38, 3 SUM = 79/80 ONE SPACE AVAILABLE
    " 81, 39, 39, 3 SUM = 81/81 ZERO SPACES AVAILABLE
    let even_string_length = length % 2 == 0
    let left_end = slice_size
    if even_string_length
        let right_start = slice_size + 1
    else
        let right_start = slice_size
    endif
    let left_slice = string[0:left_end-1] " Python [start:end), Vim [start:end]
    let right_slice = string[-right_start:]
    let trunc_string = printf("%s%s%s", left_slice, middle_string, right_slice)
    if len(trunc_string) != length
        echoerr "ERROR: Could not return a truncated string"
        let fmt = printf("trunc_string: %s (%d characters)", trunc_string, len(trunc_string))
        echoerr fmt
    else
        return trunc_string
    endif
endfunction

function! common#PrintDict(D)
    for [key, value] in items(a:D)
        let fmt = printf("%s : %s", key, common#Truncate(value, 40))
        echo fmt
    endfor
endfunction

let D = { 
            \ "red" : "blue", 
            \ "colors" : [ "green", "yellow" ] , 
            \ "nests" : { "pink" : "magenta", "turquoise" : "cyan" }
            \ }
" call s:PrintDict(undotree())
" echo common#Truncate("a new way to hide this", 8)

