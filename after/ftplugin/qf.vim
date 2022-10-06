" Original
function! QuickfixTitle()
    if exists('w:quickfix_title')
        return ' '.w:quickfix_title 
    else
        return ' '
    endif
endfunction
setlocal statusline=%t%{exists('w:quickfix_title')?\ '\ '.w:quickfix_title\ :\ ''}\ %=%-15(%l,%c%V%)
setlocal statusline=%{QuickfixTitle()}
setlocal statusline+=%=\ %l/%-6L\ %3c 
