" Handle
" Three Types: Assignments For Defs
" ExtraCases:
" 1. multiple de-structuring in assignments with surrounding braces
" 2. type annotations that include dictionaries 
" 3. default assignments in function declarations
" 4. Leading starts, Underscore variable names
function! s:LoadForInstances()
    PyGrep \bfor\b.*\bin\b
    Cfilter /^\s*for/
endfunction

function! s:LoadDefInstances()
    PyGrep \bdef\b
    Q2B
endfunction

function! s:ArgMatches(line)

    let line = a:line
    let line = substitute(line, '\[[^]]\+\]', '', 'g')

    let lst = []
    call substitute(line, '[(,*]\s*\zs\w\+', '\=add(lst, submatch(0))', 'g')
    let python_types = [ 'str', 'int', 'float', 'bytes', 'dict', 'list' ]
    call filter(lst, { idx, word -> index(python_types, word) == -1})
    return lst
endfunction

function! s:PathToBufLines(path)
    let path = a:path
    let path = expand(path)
    let buf_nr = bufnr(path)
    let lines = getbufline(buf_nr, 1, '$')
    return lines
endfunction
function! VardumpEntry()
    let lines = s:PathToBufLines('~/Desktop/Twitch/coffee-vps/code/twitch_utilities.py')
    call filter(lines, { idx, line -> line =~# '^\w\+\s*=' })
    echo join(lines, "\n")
    return

    let lines = s:PathToBufLines('~/Documents/Python/blank.py')
    call s:ParseLines(lines)
endfunction

function! s:OrderVariables(D1, D2)
    if a:D1['lineno'] < a:D2['lineno']
        return -1
    elseif a:D1['lineno'] > a:D2['lineno']
        return 1
    elseif a:D1['idx'] < a:D2['idx']
        return -1
    else
        return 1
    endif
endfunction

" TODO: vimgrep for def args, for loop, strucutral as and simple lhs
" assignments and handle semi-colon stacked assignments and destructuring
" TODO: Handle brackets () [] in multi variable de-structuring
" TODO: Handle type annotations in assignments
function! s:ParseLines(lines)
    let lines = a:lines
    call map(lines, { idx, line -> {'lineno': idx, 'line': line} })


    let Expand = { D -> map(D['variables'], { idx, variable -> { 'variable': substitute(trim(variable), '*', '', ''), 'lineno': D['lineno'], 'idx': idx } } ) }
    " PART 1
    let assignments = filter(copy(lines), { _, D -> D['line'] =~# '^\s*[(\[]\?\s*\<[a-zA-Z0-9_,* ]\+\>[\])]\?\s*=' })
    call map(assignments, { _, D -> { 'lineno': D['lineno'], 'variables': trim(substitute(D['line'], '=.*', '', ''))} })
    call map(assignments, { _, D -> { 'lineno': D['lineno'], 'variables': substitute(D['variables'], '[()\[\]]', '', 'g')} })
    call map(assignments, { _, D -> { 'lineno': D['lineno'], 'variables': split(D['variables'],',') } })
    call map(assignments, { _, D -> Expand(D) })
    call flatten(assignments)
    call filter(assignments, { _, D -> D['variable'] !=# '_' })

    " PART 2
    let fors = filter(copy(lines), { _, D -> D['line'] =~# '^\s*for ' })
    call map(fors, { _, D -> { 'lineno': D['lineno'], 'line': trim(substitute(D['line'], ' in.*', '', ''))} }) 
    call map(fors, { _, D -> { 'lineno': D['lineno'], 'line': trim(substitute(slice(D['line'], 3), '^\s*for', '', '')) } }) 
    call map(fors, { _, D -> { 'lineno': D['lineno'], 'line': trim(substitute(D['line'], '[() ]', '', 'g')) } }) 
    call map(fors, { _, D -> { 'lineno': D['lineno'], 'variables': split(D['line'],',') } }) 
    call map(fors, { _, D -> Expand(D) })
    call flatten(fors)
    call filter(fors, { _, D -> D['variable'] !=# '_' })

    " PART 3
    let defs = filter(copy(lines), { _, D -> D['line'] =~# '^\s*\(async\)\?\s*def ' })
    call map(defs, { _, D -> { 'lineno': D['lineno'], 'variables': s:ArgMatches(D['line']) } })
    call map(defs, { _, D -> Expand(D) })
    call flatten(defs)
    call filter(defs, { _, D -> D['variable'] !=# '_' })

    let variables = defs + fors + assignments
    " we add the lineno comparison for shadowing / re-declaration in same scope
    let Compare = { D1, D2 -> D1['variable'] ==# D2['variable'] ? (D1['lineno'] < D2['lineno'] ? -1: 1) : (D1['variable'] < D2['variable'] ? -1: 1) }
    call sort(variables, Compare) " Lexicographic
    call uniq(variables, Compare)
    call sort(variables, function("s:OrderVariables")) " Line Number
    call map(variables, { _, D -> D['variable'] })
    call reverse(variables)
    return variables

endfunction

function! s:AsyncWriteBuf(buf_nr, timer_id)
    call setbufvar(a:buf_nr, "&modified", 0)
endfunction

function! s:AsyncInitCallback(error, response)
    let g:printvar_response = { "error": error, "response": response }
endfunction

function! s:AsyncInit(extension, timer_id)
    " TODO: delautocommand after done
    if exists('s:printvar_initialized')
        return
    endif
    let start_time = localtime()
    echom "Start Time: " . strftime("%c")
    let path = expand('~/vimfiles/temp/vardump.' . a:extension)
    if bufloaded(path) == 0
        execute 'badd ' . path
        silent call bufload(path)
        sleep 10m
    endif
    let buf_nr = bufnr(path)
    call deletebufline(buf_nr, 1, '$')
    call setbufline(buf_nr, 1, [ "def foo():", "    pass" ])
    let PartialFunc = function('s:AsyncWriteBuf', [buf_nr])
    call timer_start(1, PartialFunc)
    call CocActionAsync('documentSymbols', buf_nr)
    let s:printvar_initialized = v:true
    let time_taken = localtime() - start_time
    echom "Time Taken: " . string(time_taken)
endfunction


function! s:CocRefreshTempBuffer()
    let extension = expand("%:e")
    let path = expand('~/vimfiles/temp/vardump.' . extension)
    " no def returns 0 which works for getline
    let start_lineno = search('def', 'bn') 
    let lines = getline(start_lineno, line("."))
    if bufloaded(path) == 0
        execute 'badd ' . path
        silent call bufload(path)
        sleep 10m
    endif
    let buf_nr = bufnr(path)
    call deletebufline(buf_nr, 1, '$')
    call setbufline(buf_nr, 1, lines)
    let PartialFunc = function('s:AsyncWriteBuf', [buf_nr])
    call timer_start(1, PartialFunc)
    return [ buf_nr, path ]
endfunction

function! s:RegexDocumentSymbols()
    let start_lineno = search('def', 'bn') 
    let lines = getline(start_lineno, line("."))
    let items = s:ParseLines(lines)
    return items
endfunction

function! GetCocVariables()
    let [ buf_nr, path ] = s:CocRefreshTempBuffer()
    let items = CocAction('documentSymbols', buf_nr)
    " let items = s:RegexDocumentSymbols()
    if type(items) != v:t_list | echoerr 'items is not list. items are: '.string(items) | return | endif
    let functions = filter(copy(items), {idx, D -> D['kind'] ==# 'Function' && D['lnum'] <= line(".") } )
    let last_function_lnum = len(functions) > 0 ? functions[-1]['lnum'] : 1
    call filter(items, {idx, D -> D['kind'] ==# 'Variable'} )
    call filter(items, {idx, D -> D['lnum'] >= last_function_lnum && D['lnum'] <= line(".") })
    call map(items, {idx, D-> {'lnum': D['lnum'], 'col': D['col'], 'text': D['text']}})
    call map(items, { idx, D -> D['text'] })
    call reverse(items)
    return items
endfunction

function! s:CompleteStub(findstart, base)
    if a:findstart == 1
        return col(".")
    endif
    return s:items
endfunction

function! s:PythonSetUpCFU()
    let s:cfu=&completefunc
    set completefunc=s:CompleteStub
    function! s:CompleteFuncRestore()
        let &completefunc=s:cfu
        au! PythonVariableInsertGroup
    endfunction
    augroup PythonVariableInsertGroup
        au!
        au CompleteDone * call s:CompleteFuncRestore()
    augroup END
endfunction

function! s:PrintPythonVariable()
    let s:items = s:RegexDocumentSymbols()
    call s:PythonSetUpCFU()
    let ic_exists = search('^\s*from \.\?\(ic\|waivek\) import.*ic', 'wn') != 0
    if ic_exists
        imap <buffer> <expr> <Plug>InsertPrintvarText "ic()\<Left>\<C-x>\<C-u>\<C-p>"
        call feedkeys("\<Plug>InsertPrintvarText")
    else
        imap <buffer> <expr> <Plug>InsertPrintvarText 'print(("=" + "\x1b[96m").join(f"{ = }".split("=", 1)) + "\x1b[39m")T{'
        call feedkeys("\<Plug>InsertPrintvarText")
        call feedkeys(" \<BS>\<C-x>\<C-u>\<C-p>")
    endif
endfunction


let s:items = []

" Don’t use <expr>. :h <expr> | call search('side effects')
augroup FiletypeMappings
    au!
    au BufRead *.py inoremap <buffer> jf <Cmd>call <SID>PrintPythonVariable()<CR>
    " au BufRead *.py call timer_start(1, function('s:AsyncInit', ["py"]))
augroup END

