
function! s:TidySelection()
    '<,'>!tidy  -quiet -indent --indent-spaces 4 --show-body-only 1
    normal! V`]=
endfunction
function! s:TidyFunction(...)
    '[,']!tidy  -quiet -indent --indent-spaces 4 --show-body-only 1
    normal! V`]=
endfunction

let &l:formatprg='tidy -quiet -indent --indent-spaces 4 --show-errors 0 --wrap-attributes no --wrap 0 --tidy-mark no'
let &l:formatprg=''
" xnoremap <buffer> gq :<c-u>call <SID>TidySelection()<CR>
" nnoremap <buffer> gq :set opfunc=TidyFunction<CR>g@
nnoremap <buffer> gqG :%!tidy -quiet -indent --indent-spaces 4 --show-errors 0 --wrap-attributes no --wrap 0 --tidy-mark no<CR>

set encoding=utf8
source ~/vimfiles/ftplugin/css.vim


function! s:PrintJavaScriptVariable()
    let print_fmt = 'console.log("variable_name: " + variable_name);'
    let reg_save = @a
    normal! gv"ay
    let @a = substitute(print_fmt, "variable_name", @a, "g")
    normal! oa
    normal! ^
    let @a = reg_save
endfunction
vnoremap z :<c-u>call <SID>PrintJavaScriptVariable()<CR>

function! s:SplitDiff()
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

function! s:CorrectOneError()
    normal! ]S
    let [w, _] = spellbadword()
    if w == ''
        break
    endif
    if w[1] == 'f'
        normal! lli 
    endif
endfunction
function! s:CorrectSpellingErrors()
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
function! s:CleanPDF()
    %s/modem/modern/g
    %s/'/’/g
    " call s:CorrectSpellingErrors()
endfunction

function! s:FixSingleQuoteTypography()
    let words = [ "I'll", "I'm", "I've", "It's", "That's", "There's", "They're", "can't", "didn't", "doesn't", "don't", 
                \ "he's", "isn't", "it's", "that's", "there's", "they're", "who'd", "you'll" ]

    for word in words
        let replacement = substitute(word, "'", "’", "")
        let substitute_command = '%s/\<' . word . '\>/' . replacement . '/g'
        execute substitute_command
    endfor

endfunction





" breakadd func 24 VisualSelectAroundAttribute
" Doesn’t work for hyphens. Exmaple: data-type="some-content"
function! s:VisualSelectAroundAttribute()
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
    " \w = [0-9A-Za-z_]
    " Tailwind needs hyphen [0-9A-Za-z_-]

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

xnoremap  <silent> aa :<c-u>call <SID>VisualSelectAroundAttribute()<CR>
onoremap  <silent> aa :<c-u>call <SID>VisualSelectAroundAttribute()<CR>

vnoremap <Plug>LeftBracket <
vmap <silent> <expr> < mode() ==# "v" ?  '<Plug>VSurround<'  :  '<Plug>LeftBracket'


" Doesn’t work
function! s:ShowDoubleQuotes()
    Isolate /[^=]"[^"=>]*"/
endfunction
command! ShowDoubleQuotes call s:ShowDoubleQuotes()

function! s:NextDoubleQuotes()
    call feedkeys('/[^=]\zs"[^"=>]*"')
endfunction
command! NextDoubleQuotes call s:NextDoubleQuotes()

function! s:ShowSingleQuotes()
    Isolate /\(\<\w\+\)'\(\w\w\?\>\)/
endfunction
command! ShowSingleQuotes call s:ShowSingleQuotes()

function! s:ReplaceSingleQuoteWithCurlyQuote()
    %s/\(\<\w\+\)'\(\w\w\?\>\)/\1’\2/g
endfunction
command! ReplaceSingleQuoteWithCurlyQuote call s:ReplaceSingleQuoteWithCurlyQuote()

function! s:TemplateHTML()
    0read template.html
    call search("<title>")
    let register = @"
    let @" = expand("%")
    norma! vitp
    let @" = register
    normal! gv
endfunction
command! TemplateHTML call s:TemplateHTML()

function! s:ToggleEntities()
    let quote_save = @"
    silent! normal! gvy
    let selection = @"
    let @" = quote_save
    let escaped_lt_count = count(selection, "&lt;")
    let unescaped_lt_count = count(selection, "<")
    let escaped_gt_count = count(selection, "&gt;")
    let unescaped_gt_count = count(selection, ">")
    let escaped_entity_count = escaped_lt_count + escaped_gt_count
    let unescaped_entity_count = unescaped_lt_count + unescaped_gt_count

    if unescaped_entity_count > escaped_entity_count
        silent! '<,'>s/</\&lt;/g
        silent! '<,'>s/>/\&gt;/g
    elseif unescaped_entity_count < escaped_entity_count
        silent! '<,'>s/&lt;/</g
        silent! '<,'>s/&gt;/>/g
    else
    endif
endfunction
command! -range ToggleEntities call s:ToggleEntities()

" TODO: Modfy syntax/html.vim, indent/html.vim to enable this via gq
function! s:GetOpeningAndClosingTagLines()
    let view_save = winsaveview()
    let reg_save = @"

    normal! $
    let tag_found = search('<\zsli\|<\zsp\|<\zsdd', "bc")
    if !tag_found
        return [0, 0]
    endif
    normal! yiw
    let tag = @"
    let opening_tag_line = line(".")
    call search('<\/'.tag.'>')
    let closing_tag_line = line(".")

    let @" = reg_save
    call winrestview(view_save)
    return [opening_tag_line, closing_tag_line]
endfunction

function! s:SplitParagraphOrListItem()
    let start_indent = indent(".")


    let current_line = line(".")
    let [opening_tag_line, closing_tag_line] = s:GetOpeningAndClosingTagLines()
    let on_same_line = opening_tag_line == closing_tag_line && current_line == opening_tag_line
    let can_split = on_same_line


    if !can_split
        return
    endif
    s/>/>
    s/.*\zs</<
    normal! =at
    normal! j
    if indent(".") == start_indent
        normal! >>
    endif
    normal! gqq

    normal! $
    call search('<\zsli\|<\zsp\|<\zsdd', "bc")
endfunction
function! s:JoinParagraphOrListItem()
    let can_join = v:true
    let current_line = line(".")
    let [opening_tag_line, closing_tag_line] = s:GetOpeningAndClosingTagLines()
    let not_on_same_line = opening_tag_line != closing_tag_line
    let between_tags = current_line >= opening_tag_line && current_line <= closing_tag_line
    let can_join = not_on_same_line && between_tags
    " echo 'opening_tag_line: '.opening_tag_line.", closing_tag_line: ".closing_tag_line
    " echo 'not_on_same_line: '.not_on_same_line.", between_tags: ".between_tags
    if !can_join
        return
    endif

    call search('<li\|<p\|<dd', "bc")
    normal! vatJ
    s/^\s*<\(li\|p\|dd\)[^>]*>\zs\s*//g
    s/\s*\ze<\/\(li\|p\|dd\)>\s*$//g

    normal! $
    call search('<\zsli\|<\zsp\|<\zsdd', "bc")
endfunction
function! s:SplitjoinParagraphOrListItem()
    let current_line = line(".")
    let [opening_tag_line, closing_tag_line] = s:GetOpeningAndClosingTagLines()
    if opening_tag_line == 0
        return
    endif
    if current_line < opening_tag_line
        return
    endif
    if opening_tag_line == closing_tag_line
        call s:SplitParagraphOrListItem()
    else
        call s:JoinParagraphOrListItem()
    endif
endfunction
nnoremap <buffer> gu :call <SID>SplitjoinParagraphOrListItem()<CR>
" ~\Desktop\website\css_rules.txt
" iabbrev <buffer> tdn text-decoration: none;
" iabbrev <buffer> tdu text-decoration: underline;

" MARGIN
" iabbrev <buffer> ma margin: auto;
" iabbrev <buffer> m0 margin: 0;
" iabbrev <buffer> mla margin-left: auto;
" iabbrev <buffer> mra margin-right: auto;
" iabbrev <buffer> mt0 margin-top: 0;
" iabbrev <buffer> mt1 margin-top: 1rem;
" iabbrev <buffer> mb0 margin-bottom: 0;
" iabbrev <buffer> mb1 margin-bottom: 1rem;

" iabbrev <buffer> mt margin-top:
" iabbrev <buffer> mb margin-bottom:
" iabbrev <buffer> ml margin-left:
" iabbrev <buffer> mr margin-right:

" iabbrev <buffer> mt1 margin-top: 1rem;
" iabbrev <buffer> mb1 margin-bottom: 1rem;
" iabbrev <buffer> ml1 margin-left: 1rem;
" iabbrev <buffer> mr1 margin-right: 1rem;

" iabbrev <buffer> mt0 margin-top: 0rem;
" iabbrev <buffer> mb0 margin-bottom: 0rem;
" iabbrev <buffer> ml0 margin-left: 0rem;
" iabbrev <buffer> mr0 margin-right: 0rem;

" PADDING
" iabbrev <buffer> p0 padding: 0;

" iabbrev <buffer> pt padding-top:
" iabbrev <buffer> pb padding-bottom:
" iabbrev <buffer> pl padding-left:
" iabbrev <buffer> pr padding-right:

" iabbrev <buffer> pt1 padding-top: 1rem;
" iabbrev <buffer> pb1 padding-bottom: 1rem;
" iabbrev <buffer> pl1 padding-left: 1rem;
" iabbrev <buffer> pr1 padding-right: 1rem;

" iabbrev <buffer> pt0 padding-top: 0rem;
" iabbrev <buffer> pb0 padding-bottom: 0rem;
" iabbrev <buffer> pl0 padding-left: 0rem;
" iabbrev <buffer> pr0 padding-right: 0rem;

" iabbrev <buffer> mw max-width:
" iabbrev <buffer> pa position: absolute;

" iabbrev <buffer> ls letter-spacing:
" iabbrev <buffer> lh line-height:
" iabbrev <buffer> fs font-size:
" iabbrev <buffer> ttu text-transform: uppercase;
" iabbrev <buffer> ttl text-transform: lowercase;
" iabbrev <buffer> ff font-family:
" iabbrev <buffer> fw font-weight:

" iabbrev <buffer> bg background:
" iabbrev <buffer> tac text-align: center;
" iabbrev <buffer> tar text-align: right;
" iabbrev <buffer> taj text-align: justify;
" iabbrev <buffer> tal text-align: left;

" iabbrev <buffer> dg display: grid;
" iabbrev <buffer> gtc grid-template-columns:
" iabbrev <buffer> gtr grid-template-rows:
" iabbrev <buffer> gc grid-column:
" iabbrev <buffer> gr grid-row:

" iabbrev <buffer> df display: flex;
" iabbrev <buffer> fdr flex-direction: row;
" iabbrev <buffer> fdc flex-direction: column;
" iabbrev <buffer> jcfs justify-content: flex-start;
" iabbrev <buffer> jcfe justify-content: flex-end;
" iabbrev <buffer> jcsa justify-content: space-around;
" iabbrev <buffer> jcsb justify-content: space-between;

" iabbrev <buffer> dib display: inline-block;
" iabbrev <buffer> dn  display: none;

" iabbrev <buffer> fvsc font-variant: small-caps;

" iabbrev <buffer> br border-radius:


nnoremap <silent> gS :call sj#css#SplitDefinition()<CR>
nnoremap <silent> gJ :call sj#css#JoinDefinition()<CR>
function! s:GotoStyleTagEnd()
    " We have the screenline check to check if the <\/style> tag is in the
    " current window. If it is, then we restore the view. This avoids an extra
    " alignment change / animation that you would have got similar to how
    " pressing zz does one.
    let view_save = winsaveview()
    let oldBotScreenLine = min([line(".") - winline() + winheight(0), line("$")])
    normal! G
    let search_line_number = search('<\/style>', "b")
    if search_line_number == 0
        call winrestview(view_save)
        return
    endif
    let newTopScreenLine = line(".") - winline() + 1
    if oldBotScreenLine >= newTopScreenLine
        call winrestview(view_save)
        normal! L
        call search('<\/style>', "bc")
    endif

    normal! k^
endfunction
nnoremap <silent> <buffer> 's :call <SID>GotoStyleTagEnd()<CR>
nnoremap <silent> <buffer> `s :call <SID>GotoStyleTagEnd()<CR>

" iabbrev <buffer> btl border-top-left-radius:
" iabbrev <buffer> btr border-top-right-radius:
" iabbrev <buffer> bbl border-bottom-left-radius:
" iabbrev <buffer> bbr border-bottom-right-radius:

" iabbrev <buffer> h* h1, h2, h3, h4, h5, h6

function! s:ShowClasses()
    %s/class="[^"]*"/\0/g
    v/class/d
    %s/class="//
    %s/"$//
    %s/ //g
    %sort
    %!uniq -c
    %sort! n
endfunction
command! ShowClasses silent! call s:ShowClasses()

" iabbrev reset h1, h2, h3, h4, h5, h6, body, p, hr, pre, ol, ul, header, nav, button { margin: 0; padding: 0; }

