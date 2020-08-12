" syn match AnchorStart /<a[^>]*>/ conceal cchar=[
" syn match AnchorEnd  /<\/a>/ conceal cchar=]

set conceallevel=3
set concealcursor=nv
hi! CustomVivekStart gui=NONE
hi! CustomVivekEnd gui=NONE
call matchadd('CustomVivekStart', '<a[^>]*>', 4, -1, { 'conceal' : '['})
call matchadd('CustomVivekEnd', '<\/a>', 4, -1, { 'conceal' : ']' })
