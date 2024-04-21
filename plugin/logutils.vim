function! s:LogPrettyPrintLine()
    let l:line = getline(".")
    let l:tokens = split(l:line)
    let epoch = l:tokens[0]
    let date = strftime("%c", epoch)
    let l:substituted_line = date . " " . join(l:tokens[1:], " ")
    echo l:substituted_line
endfunction

function! s:LogPrettifyFile()
    " substitute command that takes the first word of the line, assumes it is
    " an epoch timestamp, and converts it to a human readable date
    %s/^\(\d\+\)/\=strftime("%c", submatch(1))/e
endfunction

command! LogPrettyPrintLine call s:LogPrettyPrintLine()
command! LogPrettifyFile call s:LogPrettifyFile()
