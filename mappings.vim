


nnoremap gf gF

" ide mappings
nnoremap <silent>        <leader>d  :call CocAction('jumpDefinition')<CR>
nnoremap <silent>        <leader>u  :call CocAction('jumpUsed')<CR>
nmap                     <leader>f <Plug>(coc-codeaction-cursor)
nnoremap <silent>        <leader>r  :call CocActionAsync('rename')<CR>
nmap                     <leader>i <Plug>Inline

" copilot mappings
imap                     <C-L>     <Plug>(copilot-accept-word)

