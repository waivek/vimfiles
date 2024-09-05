
function! s:FunctionSyntaxGroups()
    if index([ 'text', 'markdown', 'todo' ], &filetype) != -1
        return
    endif
    syntax match Function /[a-zA-Z0-9_]\+\s*\ze(/
    " syntax match FunctionWithPeriods /[a-zA-Z.0-9_]\+\s*\ze(/ contains=Function

    " syntax match FunctionLeaf /\<[^ ,()]*\>([^,()]*)/

    syntax match CustomMode /\s\+vim:.*/
endfunction
function! s:AddHighlightGroups()
    " hi! link FunctionLeaf Identifier
    " `if !exists("g:colors_name")
    " `    return
    " `endif
    if g:colors_name ==# "codedark"
        hi FunctionWithPeriods guifg=#a7a765
    elseif g:colors_name ==# "apprentice"
        hi FunctionWithPeriods guifg=#d8afaf
    endif
    hi link CustomMode Comment
endfunction
augroup AddFunctionHighlightGroups
    au!
    au Syntax * call s:FunctionSyntaxGroups()
    au Syntax * call s:AddHighlightGroups()
augroup END

function! s:PathSyntax()
    syntax clear PathVariable
    syntax clear PathBasename
    syntax clear PathLinuxDirectory

    syntax match PathVariable /\$[a-z_A-Z0-9]\+/
    syntax match PathVariable /\~/

    syntax match PathBasename /[^\/\\]\+\(["']\|$\)/
    syntax match PathLinuxDirectory /\/.*\// contains=ALL

    hi link PathVariable Identifier
    hi link PathBasename Function
    hi link PathLinuxDirectory String
endfunction
augroup AddPathHighlightGroups
    au!
    " au Syntax * call s:PathSyntax()
augroup END
