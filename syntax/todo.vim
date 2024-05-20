" Syntax highlighting for TODO files

" Define the keywords for TODO items
syntax match todoComment "^#.*$" contains=todoComment
syntax match todoDone "^✓.*$" contains=todoDone

" Define highlight groups
highlight link todoComment Comment
" highlight todoDone term=strikethrough cterm=strikethrough gui=strikethrough
highlight link todoDone Comment

