set encoding=utf8
let &l:formatprg='tidy -indent --indent-spaces 4 -quiet --show-errors 0 --wrap-attributes no --wrap 0'
source ~/vimfiles/ftplugin/css.vim


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

function! FixSingleQuoteTypography()
    let words = [ "I'll", "I'm", "I've", "It's", "That's", "There's", "They're", "can't", "didn't", "doesn't", "don't", 
                \ "he's", "isn't", "it's", "that's", "there's", "they're", "who'd", "you'll" ]

    for word in words
        let replacement = substitute(word, "'", "’", "")
        let substitute_command = '%s/\<' . word . '\>/' . replacement . '/g'
        execute substitute_command
    endfor

endfunction


function! InStartTag()
endfunction



breakdel *
" breakadd func 24 VisualSelectAroundAttribute
" Doesn’t work for hyphens. Exmaple: data-type="some-content"
function! VisualSelectAroundAttribute()
    " Check if cursor is inside < and >
    let pos_save = getpos(".")
    let quote_register = @"
    let @" = ""
    normal! yi>
    let yanked_text = @"
    let @" = quote_register
    call setpos(".", pos_save)
    if yanked_text ==# ""
        return
    endif

    " Check if tag has attributes
    if stridx(yanked_text, "=") == -1
        return
    endif

    " Check if cursor is inside the last attribute
    let cursor_on_last_attribute = v:false
    let last_attribute_pattern = search('\w\+="[^"]*"\s*>\?', "e")
    normal! vy
    let character_under_cursor = @"
    let on_last_attribute = character_under_cursor ==# ">"
    let @" = quote_register
    call setpos(".", pos_save)

    " Setting the pattern to ensure surrounding spaces are included in the
    " appropriate context
    let attribute_pattern = ""
    if on_last_attribute
        let attribute_pattern = '\s*\w\+="[^"]*"\s*\ze>'
    else
        let attribute_pattern = '\w\+="[^"]*"\s*'
    endif
    call search(attribute_pattern, "bc")
    normal! v
    call search(attribute_pattern, "ce")
endfunction

xnoremap  <silent> aa :<c-u>call VisualSelectAroundAttribute()<CR>
onoremap  <silent> aa :<c-u>call VisualSelectAroundAttribute()<CR>

