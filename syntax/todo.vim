" Syntax highlighting for TODO files

" Define the keywords for TODO items
syntax match todoComment "^#.*$" contains=todoComment
syntax match todoDone "^✓.*$" contains=todoDone

" syntax match the word inside square brackets as todoTag
syntax match todoTag /\[.\{-}\]/

" syntax match the word uppercase followed by colon as todoLabel, it is always
" inside a comment
syntax match todoLabel /\u\+:/ contained containedin=todoComment

" Define highlight groups
highlight link todoComment Comment
highlight link todoDone Comment
highlight link todoTag Identifier
" todo should have a background and be bold
highlight! link todoLabel Visual
