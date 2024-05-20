
function! s:HighlightGroupUnderCursor()
    let a = synIDattr(synID(line("."),col("."),1),"name")
    let b = synIDattr(synID(line("."),col("."),0),"name")
    let c = synIDattr(synIDtrans(synID(line("."),col("."),1)),"name")
    echo a . ' -> ' . b . ' -> ' . c 
endfunction
map <F10> :call <SID>HighlightGroupUnderCursor()<CR>

function! s:IDcolors (name)
    let id = hlID(a:name)
    let fg = synIDattr(id, "fg")
    let bg = synIDattr(id, "bg")
    let bg_string = len(bg) > 0 ? "guibg=" . bg : ""
    let leading_spaces = repeat(" ", indent("."))
    let cmd = leading_spaces . "hi " . a:name . " guifg=" . fg . " " . bg_string
    exec "put='" . cmd . "'"
endfunction
command! -complete=highlight -nargs=1 IDcolors call s:IDcolors(<q-args>)

function! s:ClearSelectedGroups()
    hi clear Identifier 
    hi clear PreProc 
    hi clear Special 
    hi clear Statement
    hi clear Type
    hi clear Constant
    hi clear SpecialKey
    hi clear Folded
    hi clear Operator
endfunction
function! s:Extend(c_name)
    if a:c_name ==# "apprentice"
        if has("win32")
            so ~/vimfiles/colors/apprentice_extended.vim
        else
            " so ~/.vim/colors/apprentice_extended.vim
        endif
    elseif a:c_name ==# "codedark"
        hi IncSearch guibg=#682900 ctermbg=52
        " hi Search ctermfg=235 ctermbg=229 guibg=#444444
        " hi Visual term=reverse cterm=reverse ctermfg=110 ctermbg=235 gui=reverse guifg=#8fafd7 guibg=#262626
    elseif a:c_name ==# 'strawberry-light'
        hi Visual guifg=white guibg=DarkRed
        hi StatusLine guifg=#fff0f7 guibg=#d46a84
        hi Normal guifg=#75616b guibg=#fff0f7
        hi WildMenu guifg=#000000 guibg=#F5DEB3
        hi Search guifg=#ffffff guibg=#1B9E9E gui=none
        set guicursor+=v:block-vCursor
        hi vCursor gui=reverse
    elseif a:c_name ==# 'plain'
        hi WildMenu guibg=#FB007A guifg=white
        set background=light
    elseif a:c_name ==# 'onedark'
        let onedark_colorD = #{ 
                    \ red         : "#E06C75", dark_red    : "#BE5046", green        : "#98C379", yellow         : "#E5C07B",
                    \ dark_yellow : "#D19A66", blue        : "#61AFEF", purple       : "#C678DD", cyan           : "#56B6C2",
                    \ white       : "#ABB2BF", black       : "#282C34", comment_grey : "#5C6370", gutter_fg_grey : "#4B5263",
                    \ cursor_grey : "#2C323C", visual_grey : "#3E4452", menu_grey    : "#3E4452", special_grey   : "#3B4048"
                    \}
        " call s:ClearSelectedGroups()
        hi Todo gui=reverse guifg=NONE guibg=NONE
        hi Function guifg=#E06C75 
        hi String guifg=#E5C07B 
        hi Number guifg=#61AFEF 

        hi clear Search IncSearch
        hi Search guibg=#444444 gui=NONE
        hi IncSearch guifg=black guibg=white
    endif
endfunction
augroup ExtendColorScheme
    au!
    au ColorScheme * call s:Extend(expand("<amatch>"))
augroup END

hi! link vimFunction Function

command! ListColors so $VIMRUNTIME/syntax/hitest.vim
