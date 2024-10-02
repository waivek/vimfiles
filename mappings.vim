
nnoremap gf gF

" ide mappings
nnoremap <silent>        <leader>d  :call CocAction('jumpDefinition')<CR>
nnoremap <silent>        <leader>u  :call CocAction('jumpUsed')<CR>
nmap                     <leader>f  <Plug>(coc-codeaction-cursor)
nnoremap <silent>        <leader>r  :call CocActionAsync('rename')<CR>
nnoremap <silent>        <leader>e  :CocDiagnostics<CR>

nmap                     <leader>i  <Plug>Inline
nmap                     <leader>q  :MergeEmptyLines<CR>
" (above)merge multiple adjacent empty lines into one

nmap                     h          :Buffers<CR>
nmap                     <space>o   <Plug>Oldfiles
nmap                     <space>e   <Plug>PwdOldfiles
nmap     <silent>        <space>;   <Plug>Run3

" copilot mappings
imap                     <C-L>     <Plug>(copilot-accept-word)

" conditional command line expansions
cnoreabbrev <expr> Rename len(getcmdline()) == 6 && getcmdtype() == ":" ? "Rename ".expand("%:t")."\<C-f>" : "Rename"

