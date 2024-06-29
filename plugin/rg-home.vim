
function! s:RgHome(pattern_without_quotes)
    let pattern = a:pattern_without_quotes
    let format_string = 'rg --vimgrep "%s" ~/'
    let command = printf(format_string, pattern)
    echo command
    cexpr system(command)
endfunction

command! -nargs=1 RgHome call s:RgHome(<f-args>)
