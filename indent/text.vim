function! s:GetTextIndent(lnum)

    let lnum = a:lnum
    let pline = getline(lnum-1)

    " If the previous line ended with a colon, indent this line
    if pline =~ ':\s*\w\+$'
        " return plindent + shiftwidth()
        let lhs_with_space = matchstr(pline, '[^:]\+:\s*')
        return len(lhs_with_space)
    endif
    let pindent = indent(lnum-1)
    let nindent = indent(lnum+1)
endfunction

" set debug=msg
" setlocal indentexpr=s:GetTextIndent(v:lnum)
