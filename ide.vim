
" PyflakesRefinedCallback(buffer, lines) {{{
function! PyflakesRefinedCallback(buffer, lines) abort
    let l:pattern = '\v^[a-zA-Z]?:?[^:]+:(\d+):(\d+)?:? (.+)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        let g:ale_debug = l:match[3]

        " CUSTOMIZATION - Start
        if stridx(l:match[3], "assigned to but never used") > -1
            continue
        endif
        " CUSTOMIZATION - End

        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 0,
        \   'text': l:match[3],
        \})
    endfor

    return l:output
endfunction
" }}}

" DefineCustomAleLinters() {{{
function! DefineCustomAleLinters()
    if exists("g:loaded_ale")
        call ale#linter#Define('python', {
        \   'name': 'pyflakes_refined',
        \   'executable': function('ale_linters#python#pyflakes#GetExecutable'),
        \   'command': function('ale_linters#python#pyflakes#GetCommand'),
        \   'callback': 'PyflakesRefinedCallback',
        \   'output_stream': 'both',
        \})
    endif
endfunction
" }}}
" Ale au, g: {{{
augroup VimrcAle
    au!
    au VimEnter * call DefineCustomAleLinters()
augroup END
let g:ale_linters = { 
            \ 'python' : [ 'pyflakes_refined' ],
            \ }
let g:ale_lint_on_enter = 1 " Default: 1
let g:ale_lint_on_save = 1 " Default: 1
let g:ale_lint_on_filetype_changed = 0 " Default: 1
let g:ale_lint_on_insert_leave = 0 " Default: 1
let g:ale_lint_on_text_changed = 0 " Default: 'normal'
let g:ale_lint_delay = 0 " Default: 200
" }}}

" Jedi g:{{{
let g:jedi#popup_on_dot = 0
let g:jedi#added_sys_path = [ '/Users/vivek/Documents/Python' ]

let g:jedi#completions_enabled    = 0
let g:jedi#show_call_signatures   = 1
let g:jedi#auto_vim_configuration = 0 " to prevent jedi from overriding 'completeopt'
" }}}

" Disable file with size > 1MB

function! ConfigureCoc()
    let ONE_KB = 1024
    if getfsize(expand('<afile>')) > 100*ONE_KB
        let b:coc_suggest_disable = 1
    endif
endfunction
augroup CocJediChooser
    au!
    autocmd BufReadPre * call ConfigureCoc()
augroup END

" TODO: Integrate UltiSnips expansion + jumping
" TODO: Make SHIFT-TAB invert behaviour
function! Nothing_before_cursor()
    let line_part = strcharpart(getline("."), 0, col('.')-1)
    if len(trim(line_part)) == 0
        return v:true
    else
        return v:false
    endif
endfunction
function! Space_before_cursor()
    let line_part = strcharpart(getline("."), 0, col('.')-1)
    if match(line_part, ' $') == -1
        return v:false
    else
        return v:true
    endif
endfunction
function! Period_before_cursor()
    let line_part = strcharpart(getline("."), 0, col('.')-1)
    if match(line_part, '\.\w*$') == -1
        return v:false
    else
        return v:true
    endif
endfunction
function! TabCompletion()

    " Handle intelligent file completion here or offload to `coc`? 
    " ============================================================ 
    "
    " If you handle here, you'll need a File_separator_before_cursor() function
    "
    " You will also need to get directories in cwd to intelligently complete
    " directories and files that don’t start with a slash. This can be updated
    " via DirChanged and BufEnter autocommands.
    "
    " TODO: Make native keyword completion that naturally returns <C-p>
    " results for <C-n>. Simplify this switch b/w <C-n> and <C-p>


    if pumvisible() && complete_info()["mode"] !=# "keyword"
        return "\<C-n>"
    endif
    if pumvisible() && complete_info()["mode"] ==# "keyword"
        return "\<C-p>"
    endif
    if Nothing_before_cursor()
        return "\<TAB>"
    endif
    if Space_before_cursor()
        return "\<TAB>"
    endif

    if exists('b:coc_suggest_disable') && b:coc_suggest_disable == 1
        if Period_before_cursor()
            return "\<C-x>\<C-o>" " Start omni-completion
        else
            return "\<C-p>" " Start keyword completion
            " return "\<C-n>" 
        endif
    endif
    if !exists("*coc#refresh")
        return "\<C-p>" " Start keyword completion
        " return "\<C-n>" 
    endif
    call coc#refresh() " Start Coc Completion
endfunction


function! ShowDocumentation()
    if exists("*CocHasProvider") && CocHasProvider('hover')
        return ":call CocAction('doHover')\<CR>"
    else
        return "K"
    endif
endfunction

set completeopt=menuone,popup
set complete=.,w
inoremap <silent> <expr> <c-space>  coc#refresh()
nnoremap <silent>        <leader>d  :call CocAction('jumpDefinition')<CR>
nnoremap <silent> <expr> K          ShowDocumentation()
inoremap <silent> <expr> <TAB>      TabCompletion()
