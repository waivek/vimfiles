
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





function! s:VintRefinedCallback(buffer, lines) abort
   " ~/vimfiles/plugged/ale/ale_linters/vim/vint.vim
   " ~/vimfiles/temp/220812.ale_vint_loclist.json
    let l:loclist = ale_linters#vim#vint#Handle(a:buffer, a:lines)
    let l:loclist_filtered = []
    for l:loclist_D in l:loclist
        let text = l:loclist_D['text']
        let should_continue = v:false
        for error_name in [ 'ProhibitMissingScriptEncoding', 'ProhibitUnnecessaryDoubleQuote', 'ProhibitCommandWithUnintendedSideEffect', 'ProhibitCommandRelyOnUser' ]
            if stridx(text, error_name) == 0
                let should_continue = v:true
                break
            endif
        endfor
        if should_continue
            continue
        endif
        call add(l:loclist_filtered, l:loclist_D)
    endfor
    " return l:loclist
    return l:loclist_filtered
endfunction

" }}}

" DefineCustomAleLinters() {{{
function! s:DefineCustomAleLinters()
    if exists("g:loaded_ale")
        call ale#linter#Define('python', {
        \   'name': 'pyflakes_refined',
        \   'executable': function('ale_linters#python#pyflakes#GetExecutable'),
        \   'command': function('ale_linters#python#pyflakes#GetCommand'),
        \   'callback': 'PyflakesRefinedCallback',
        \   'output_stream': 'both',
        \})


        call ale#linter#Define('vim', {
        \   'name': 'vint_refined',
        \   'executable': {buffer -> ale#Var(buffer, 'vim_vint_executable')},
        \   'command': {buffer -> ale#semver#RunWithVersionCheck(
        \       buffer,
        \       ale#Var(buffer, 'vim_vint_executable'),
        \       '%e --version',
        \       function('ale_linters#vim#vint#GetCommand'),
        \   )},
        \   'callback': 's:VintRefinedCallback',
        \})
    endif
endfunction
" }}}
" Ale au, g: {{{
augroup VimrcAle
    au!
    au VimEnter * call s:DefineCustomAleLinters()
augroup END
let g:ale_linters = { 
            \ 'python' : [ 'pyflakes_refined' ],
            \ 'javascript' : ['xo'],
            \ 'php' : ["php"],
            \ 'vim': ['vint_refined' ],
            \ 'go' : [ 'gobuild' ]
            \ }

            " \ 'python' : [ 'autoimport' ]
let g:ale_fixers = {
            \ 'go' : [ 'gofmt', 'goimports' ]
            \}

" let g:ale_lint_on_enter = 0
" let g:ale_fix_on_save = 1
let g:ale_lint_on_enter = 1 " Default: 1
let g:ale_lint_on_save = 1 " Default: 1
let g:ale_lint_on_filetype_changed = 0 " Default: 1
let g:ale_lint_on_insert_leave = 0 " Default: 1
let g:ale_lint_on_text_changed = 0 " Default: 'normal'
let g:ale_lint_delay = 0 " Default: 200


let g:ale_html_tidy_options = '-q -e -language en --escape-scripts 0'
" }}}

" Jedi g:{{{
let g:jedi#popup_on_dot = 0
let g:jedi#added_sys_path = [ '/Users/vivek/Documents/Python' ]

let g:jedi#completions_enabled    = 0
let g:jedi#show_call_signatures   = 1
let g:jedi#auto_vim_configuration = 0 " to prevent jedi from overriding 'completeopt'
" }}}

" Disable file with size > 1MB

function! s:ConfigureCoc()
    let ONE_KB = 1024
    if getfsize(expand('<afile>')) > 100*ONE_KB
        let b:coc_suggest_disable = 1
    endif
endfunction
augroup CocJediChooser
    au!
    autocmd BufReadPre * call s:ConfigureCoc()
augroup END

" TODO: Integrate UltiSnips expansion + jumping
" TODO: Make SHIFT-TAB invert behaviour
function! s:Nothing_before_cursor()
    let line_part = strcharpart(getline("."), 0, col('.')-1)
    if len(trim(line_part)) == 0
        return v:true
    else
        return v:false
    endif
endfunction
function! s:Space_before_cursor()
    let line_part = strcharpart(getline("."), 0, col('.')-1)
    if match(line_part, ' $') == -1
        return v:false
    else
        return v:true
    endif
endfunction
function! s:Period_before_cursor()
    let line_part = strcharpart(getline("."), 0, col('.')-1)
    if match(line_part, '\.\w*$') == -1
        return v:false
    else
        return v:true
    endif
endfunction
function! s:TabCompletion()

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


    let message = printf("pumvisible: %s, mode: %s", string(pumvisible()), string(complete_info()["mode"]))
    if pumvisible() && complete_info()["mode"] !=# "keyword"
        return "\<C-n>"
    endif
    if pumvisible() && complete_info()["mode"] ==# "keyword"
        return "\<C-p>"
    endif

    " Not available on 'coc v0.0.81'
    " if coc#pum#visible()
    "     return coc#pum#next(1)
    " endif
    if s:Nothing_before_cursor()
        return "\<TAB>"
    endif
    if s:Space_before_cursor()
        return "\<TAB>"
    endif

    if exists('b:coc_suggest_disable') && b:coc_suggest_disable == 1
        if s:Period_before_cursor()
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


function! s:ShowDocumentation()
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
nnoremap <silent> <expr> K          <SID>ShowDocumentation()
inoremap <silent> <expr> <TAB>      <SID>TabCompletion()
inoremap <silent> <expr> <S-Tab> pumvisible() ? '<C-p>' : '<Tab>'
