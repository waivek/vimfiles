syn match AnchorStart /<a[^>]*>/ conceal cchar=[
syn match AnchorEnd /<\/a>/ conceal cchar=]

hi! AnchorStart guifg=red guibg=black
hi! AnchorEnd guifg=blue guibg=black
