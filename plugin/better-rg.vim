" Use `path`, `ext` and anything else if req to filter ripgrep results before
" loading into fzf. After load, use `nth` magic to display the files but
" for search and filter it happens via lines on the text.

function! s:Sink(selection)
    let l:selection = a:selection
    let l:tokens = split(l:selection, ':')
    let l:path = l:tokens[0]
    let l:lnum = l:tokens[1]
    let l:command = printf('edit +%d %s', l:lnum, l:path)
    execute l:command
endfunction

function! s:Grep(args)
    if len(a:args) == 0
        let l:args = "''"
    else
        let l:args = a:args
    endif
    let l:source = "rg --vimgrep --color=always " . l:args
    
    let l:fzf_options = ['--no-sort', '--delimiter=:', '--nth=4..', '--preview', '~/.vim/plugged/fzf.vim/bin/preview.sh {}', '--preview-window', '+{2}/2']
    call fzf#run({
                \ 'source': l:source,
                \ 'sink': function('s:Sink'),
                \ 'options': l:fzf_options,
                \ })
endfunction

" Grep path:string -> -g '**/*string*/**'
" Grep ext:py      -> rg -g '*.py'
" Grep ext:py,txt  -> rg -g '*.{py,txt}
" Grep -uu         -> rg -uu

command! -nargs=* Grep call s:Grep(<q-args>)

if v:vim_did_enter
    Grep -g '*.{vim,txt}' 'fun'
endif
