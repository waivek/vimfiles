let g:coc_global_extensions = [ 'coc-json', 'coc-pyright', 'coc-vimlsp', '@yaegassy/coc-tailwindcss3', '@yaegassy/coc-volar', 'coc-css', 'coc-tsserver' ]

" For yaegassy/coc-tailwindcss3
au FileType html let b:coc_root_patterns = ['.git', '.env', 'tailwind.config.js', 'tailwind.config.cjs']

" [disabled] Insert Mode Completions {{{

" if (executable('pyls'))
"     augroup VimrcLsp
"         au!
"         au User lsp_setup call lsp#register_server({
"         \ 'name': 'pyls',
"         \ 'cmd': {server_info->['pyls']},
"         \ 'allowlist': ['python'],
"         \ 'config': { 'hover_coneal' : 1},
"         \ 'workspace_config': {'pyls': { 'plugins': {'pydocstyle': {'enabled': v:false} } } }
"         \ })
"     augroup END
" endif
" 
" 
" let g:lsp_log_file = expand('~/Desktop/neovim/lsp.log')
" 
" function! s:on_lsp_buffer_enabled() abort
"     setlocal omnifunc=lsp#complete
"     " nmap <buffer> gd <plug>(lsp-definition)
"     nmap <buffer> <f2> <plug>(lsp-rename)
" endfunction
" augroup lsp_install
"     au!
"     autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
" augroup END
" let g:lsp_diagnostics_enabled = 0
" let g:asyncomplete_auto_completeopt = 0
" let g:asyncomplete_popup_delay = 0
" let g:asyncomplete_enable_for_all = 0
" 
" 
" let g:SuperTabDefaultCompletionType="context"
" let g:SuperTabCrMapping=1
" let g:SuperTabCompleteCase="match"
" 
" 
" 
" let g:UltiSnipsExpandTrigger='<c-j>'
" let g:UltiSnipsJumpForwardTrigger='<c-j>'



" }}}

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

        if stridx(l:match[3], "imported but unused") > -1
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
            \ 'javascript' : ['quick-lint-js'],
            \ 'php' : ["php"],
            \ 'vim': ['vint_refined' ],
            \ 'go' : [ 'gobuild' ]
            \ }

let g:ale_fixers = {
            \ 'go' : [ 'gofmt', 'goimports' ],
            \ 'python' : [ 'autoimport' ]
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

" Put this in ~/.eslintrc.json
" {
"   "extends": [
"     "plugin:vue/base"
"   ]
" }
" let g:ale_javascript_eslint_options='--resolve-plugins-relative-to=C:\Users\vivek\AppData\Roaming\npm'
if has('win32')
    let g:ale_javascript_eslint_options='--config ~/vimfiles/lint/eslint_config.json --resolve-plugins-relative-to=C:\Users\vivek\AppData\Roaming\npm'
    " let g:ale_javascript_eslint_options=''
else
    let g:ale_javascript_eslint_options='--config ~/.vim/lint/eslint_config.json'
    " let g:ale_javascript_eslint_options=''
endif
" }}}

" Jedi g:{{{
let g:jedi#popup_on_dot = 0
let g:jedi#added_sys_path = [ '/Users/vivek/Documents/Python' ]

let g:jedi#completions_enabled    = 0
let g:jedi#show_call_signatures   = 1
let g:jedi#auto_vim_configuration = 0 " to prevent jedi from overriding 'completeopt'
" }}}

"  Disable file with size > 1MB

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


    " REMOVE 1:
    " let message = printf("pumvisible: %s, mode: %s", string(pumvisible()), string(complete_info()["mode"]))

    " REMOVE 2:
    " let pum_is_visible = pumvisible()
    " 
    " if pum_is_visible && complete_info()["mode"] !=# "keyword"
    "     return "\<C-n>"
    " endif
    " if pum_is_visible && complete_info()["mode"] ==# "keyword"
    "     return "\<C-p>"
    " endif

    " Not available on 'coc v0.0.81'

    if coc#pum#visible()
        return coc#pum#next(1)
    endif
    if pumvisible()
        return "\<C-n>"
    endif

    " REMOVE 6:
    if s:Nothing_before_cursor()
        return "\<TAB>"
    endif
    " REMOVE 5:
    if s:Space_before_cursor()
        return "\<TAB>"
    endif

    " REMOVE 3:
    " if exists('b:coc_suggest_disable') && b:coc_suggest_disable == 1
    "     if s:Period_before_cursor()
    "         return "\<C-x>\<C-o>" " Start omni-completion
    "     else
    "         return "\<C-p>" " Start keyword completion
    "         " return "\<C-n>" 
    "     endif
    " endif

    " REMOVE 4:
    " if !exists("*coc#refresh")
    "     return "\<C-p>" " Start keyword completion
    "     " return "\<C-n>" 
    " endif
    call coc#refresh() " Start Coc Completion
endfunction
inoremap <silent> <expr> <C-u> coc#refresh()


function! s:ShowDocumentationVim()
    let NewLineCount = { str -> count(trim(substitute(str, '```\(help\)\?', '', 'g')), "\n") }
    if exists("*CocHasProvider") && CocHasProvider('hover') && CocAction('getHover') != [] && NewLineCount(CocAction('getHover')[0]) != 0
        call CocAction('doHover')
    else
        normal! K
    endif
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

" h coc-locations-api
nnoremap <silent>        <leader>d  :call CocAction('jumpDefinition')<CR>
nnoremap <silent>        <leader>u  :call CocAction('jumpUsed')<CR>
nnoremap <silent> <expr> K          <SID>ShowDocumentation()
augroup IDEShowDoc
    au!
    au BufRead *.vim nnoremap <buffer> K :call <SID>ShowDocumentationVim()<CR>
augroup END
inoremap <silent> <expr> <TAB>      <SID>TabCompletion()
" inoremap <silent> <expr> <S-Tab> pumvisible() ? '<C-p>' : '<Tab>'
function! s:ShiftTab()
    if coc#pum#visible()
        return coc#pum#prev(1)
    endif
    if pumvisible()
        return "\<C-p>"
    endif
    return "\<C-h>"
endfunction
" inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent> <expr>  <S-TAB> <SID>ShiftTab()



" <<<<<<<<<< VIMSPECTOR


" nnoremap <Leader>dT :call vimspector#ClearBreakpoints()<CR>
" 
" nmap <Leader>dc <Plug>VimspectorContinue
" nmap <Leader>dl <Plug>VimspectorRestart


" windows:
"     expression
"     variable
"     breakpoints
"     frames
"     console
"     code
" 
" [home] dh - [free]
" 
" [wide] de - [free] never used because we have d;
" [wide] do - [free]
" [wide] dm - [free]
" [wide] dn - [free]
" [wide] dp - [free]
" [wide] du - [free]
" [wide] dy - [free]
" 
" [narr] dc - [free]
" [narr] dq - [free]
" [narr] dr - [free]
" [narr] dx - [free]
" [narr] dz - [free]
" 
" da - delete around
" db - delete back
" dd - delete line
" df - delete f inclusive
" dg - delete next match via dgn
" di - delete inside
" dj - delete back
" dk - delete line below
" dl - delete line above
" ds - vim-surround
" dt - delete f exclusive
" dv - delete visual
" dw - delete from cursor to end

" <Plug>VimspectorContinue                    vimspector#Continue()
" <Plug>VimspectorStop                        vimspector#Stop()
" <Plug>VimpectorRestart                      vimspector#Restart()
" <Plug>VimspectorPause                       vimspector#Pause()
" <Plug>VimspectorBreakpoints                 vimspector#ListBreakpoints()


" <Plug>VimspectorToggleConditionalBreakpoint vimspector#ToggleBreakpoint( { trigger expr, hit count expr } )
" <Plug>VimspectorAddFunctionBreakpoint       vimspector#AddFunctionBreakpoint( <cexpr> )
" <Plug>VimspectorGoToCurrentLine             vimspector#GoToCurrentLine()


" <Plug>VimspectorJumpToNextBreakpoint        vimspector#JumpToNextBreakpoint()
" <Plug>VimspectorJumpToPreviousBreakpoint    vimspector#JumpToPreviousBreakpoint()
" <Plug>VimspectorJumpToProgramCounter        vimspector#JumpToProgramCounter()
" <Plug>VimspectorBalloonEval                 _internal_

function! s:VimspectorIsEnabled()
    if !exists("g:vimspector_session_windows")
        return v:false
    endif
    if g:vimspector_session_windows == { 'breakpoints': v:none }
        return v:false
    endif
    if g:vimspector_session_windows == {}
        return v:false
    endif
    return v:true
endfunction

if !exists("s:left_save")
    let s:left_save = maparg("<Left>", "n")
    let s:right_save = maparg("<Right>", "n")
endif

nmap <silent> <expr> <Left>  <SID>VimspectorIsEnabled() ? '<Plug>VimspectorStepOut' : '<Plug>SidewaysLeftExtended'
nmap <silent> <expr> <Right> <SID>VimspectorIsEnabled() ? '<Plug>VimspectorStepInto' : '<Plug>SidewaysRightExtended'

nmap <Up>    <Plug>VimspectorUpFrame
nmap <Down>  <Plug>VimspectorDownFrame


" nnoremap <Leader>dt :call vimspector#ToggleBreakpoint()<CR>
nmap dp <Plug>VimspectorToggleBreakpoint
nmap dh <Plug>VimspectorRunToCursor
nmap dy <Plug>VimspectorBalloonEval

nnoremap dq :call vimspector#Reset()<CR>


" ~/vimfiles/vimspector/configurations/windows/_all/global.json
nnoremap do :call vimspector#Launch()<CR>

" VIMSPECTOR >>>>>>>>>>

function! s:StartInsert(...)
    call feedkeys("i", "n")
endfunction

function! s:PC()
    call timer_start(10, function("s:StartInsert"))
    return "\<CR>"
endfunction

augroup ConsoleMaps
    au!
    au BufEnter Vimspector.Console inoremap <buffer> <expr> <CR> <SID>PC()
augroup END

nmap <expr> <CR> <SID>VimspectorIsEnabled() ? "<Plug>VimspectorStepOver" : "<CR>"
" let console_bufnr = getwininfo(g:vimspector_session_windows.output)[0]['bufnr']

let g:vimspector_install_gadgets = [ 'debugpy' ]
if has('win32')
    let g:vimspector_base_dir = expand('~/vimfiles/vimspector')
else
    let g:vimspector_base_dir = expand('~/.vim/vimspector')
endif
