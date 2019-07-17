set encoding=utf8

function! PrintJavaScriptVariable()
    let print_fmt = 'console.log("variable_name: " + variable_name);'
    let reg_save = @a
    normal! gv"ay
    let @a = substitute(print_fmt, "variable_name", @a, "g")
    normal! oa
    normal! ^
    let @a = reg_save
endfunction
vnoremap z :<c-u>call PrintJavaScriptVariable()<CR>

function! SplitDiff()
    g/^Required Reading: /d
    normal! ggguG
    %s/[ \t]//g
    g/^$/d
endfunction

" Examples {{{
" If a
" If the
" If the
" If you
" If your
" of a
" of a
" of composition
" of composition
" of course
" of fmany
" of print
" of rapid
" of reverses
" of sentences
" of slight
" of steps
" of success
" of the
" of the
" of the
" of the
" of the
" of the
" of these
" of those
" of time
" of what
" of which
" of writing
" }}}

function! CorrectOneError()
    normal! ]S
    let [w, _] = spellbadword()
    if w == ''
        break
    endif
    if w[1] == 'f'
        normal! lli 
    endif
endfunction
function! CorrectSpellingErrors()
    normal! gg
    while v:true
        normal! ]S
        let [w, _] = spellbadword()
        if w == ''
            break
        endif
        if w[1] == 'f'
            s/\<\(\wf\)\(\w*\)\>/\1 \2
        endif
    endwhile
endfunction
function! CleanPDF()
    %s/modem/modern/g
    %s/'/’/g
    " call CorrectSpellingErrors()
endfunction
