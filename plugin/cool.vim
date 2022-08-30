
" Modified version of cool.vim to work with dotty.vim
" vim-cool - Disable hlsearch when you are done searching.

" Maintainer:	romainl <romainlafourcade@gmail.com>
" Version:	0.0.2
" License:	MIT License
" Location:	plugin/cool.vim
" Website:	https://github.com/romainl/vim-cool


if exists("g:loaded_cool") || v:version < 703 || &compatible
    " finish
endif

let g:loaded_cool = 1

let s:save_cpo = &cpo
set cpo&vim

augroup Cool
    autocmd!
augroup END

if exists('##OptionSet')
    if !exists('*execute')
        autocmd Cool OptionSet highlight let <SID>saveh = &highlight
    endif
    " toggle coolness when hlsearch is toggled
    autocmd Cool OptionSet hlsearch call <SID>PlayItCool(v:option_old, v:option_new)
endif

function! s:PrintMatchInfo()
    " Check if cache needs to be refershed.
    if !exists("b:changedtick_save")
        let b:changedtick_save = -1
    endif
    if !exists("b:search_reg_save")
        let b:search_reg_save = @/
    endif
    if !exists("b:cool_match_positions")
        let b:cool_match_positions = []
    endif
    if !exists("b:call_count")
        let b:call_count = 0
    endif
    let cache_expired = b:changedtick_save != b:changedtick || b:cool_match_positions == [] || b:search_reg_save !=# @/
    if cache_expired
        let b:cool_match_positions = dotty#GetMatchByteOffsets()
        let b:changedtick_save = b:changedtick
        let cache_string = "Cache Refreshed"
        let b:search_reg_save = @/
    else
        let cache_string = "Cache Used"
    endif
    let b:call_count = b:call_count + 1
    
    let cursor_position = line2byte(".") + col(".")-1
    let match_number = index(b:cool_match_positions, cursor_position) + 1
    let total_matches = len(b:cool_match_positions)
    let info_string = printf("%d of %d", match_number, total_matches)
    let match_macro = common#Truncate(strtrans(@/),v:echospace-20)
    echon '/' . match_macro . " "
    echohl String 
    " echon info_string." (".cache_string."), Call Count: ".b:call_count
    echon info_string
    echohl Normal
endfunction

function! s:StartHL()

    if !v:hlsearch || mode() isnot 'n' 
        return
    endif

    " if g:repeating
    "     return
    " endif

    let [pos, rpos] = [winsaveview(), getpos('.')]
    " After the cursor has moved, moved exactly one byte behind
    silent! exe "keepjumps go".(line2byte('.')+col('.')-(v:searchforward ? 2 : 0))
    try
        silent keepjumps norm! n
        if getpos('.') != rpos
            throw 0
        endif
    catch /^\%(0$\|Vim\%(\w\|:Interrupt$\)\@!\)/
        call <SID>StopHL()
        return
    finally
        call winrestview(pos)
    endtry

    call s:PrintMatchInfo()
    return

    " Ported {{{

    " if !get(g:,'CoolTotalMatches') || !exists('*reltimestr')
    "     return
    " endif
    " exe "silent! norm! :let g:cool_char=nr2char(screenchar(screenrow(),1))\<cr>"
    " let cool_char = remove(g:,'cool_char')
    " if cool_char !~ '[/?]'
    "     return
    " endif
    " let [f, ws, now, noOf] = [0, &wrapscan, reltime(), [0,0]]
    " set nowrapscan
    " try
    "     while f < 2
    "         if reltimestr(reltime(now))[:-6] =~ '[1-9]'
    "             " time >= 100ms
    "             return
    "         endif
    "         let noOf[v:searchforward ? f : !f] += 1
    "         try
    "             silent exe "keepjumps norm! ".(f ? 'n' : 'N')
    "         catch /^Vim[^)]\+):E38[45]\D/
    "             call setpos('.',rpos)
    "             let f += 1
    "         endtry
    "     endwhile
    " finally
    "     call winrestview(pos)
    "     let &wrapscan = ws
    " endtry
    " redraw|echo cool_char.@/ 'match' noOf[0] 'of' noOf[0] + noOf[1] - 1

    " }}}
endfunction

function! s:StopHL()
    if !v:hlsearch || mode() isnot 'n'
        return
    endif
    silent call feedkeys("\<Plug>(StopHL)", 'm')
endfunction

if !exists('*execute')
    let s:saveh = &highlight
    " toggle highlighting, a workaround for :nohlsearch in autocmds
    function! s:AuNohlsearch()
        noautocmd set highlight+=l:-
        " autocmd Cool Insertleave * noautocmd let &highlight = s:saveh | autocmd! Cool InsertLeave *
        return ''
    endfunction
endif

function! s:PlayItCool(old, new)
    if a:old == 0 && a:new == 1
        " nohls --> hls
        "   set up coolness

        " noremap <silent> <Plug>(StopHL) :<C-U>nohlsearch<cr>
        noremap <silent> <Plug>(StopHL) :<C-U>nohlsearch<cr>:echo ""<cr>
        " noremap <silent> <Plug>(StopHL) :call StopCool()<cr>
        if !exists('*execute')
            noremap! <expr> <Plug>(StopHL) <SID>AuNohlsearch()
        else
            noremap! <expr> <Plug>(StopHL) execute('nohlsearch')[-1]
        endif

        autocmd Cool CursorMoved * call <SID>StartHL()
        " autocmd Cool InsertEnter * call <SID>StopHL()
    elseif a:old == 1 && a:new == 0
        " hls --> nohls
        "   tear down coolness
        nunmap <Plug>(StopHL)
        unmap! <expr> <Plug>(StopHL)

        autocmd! Cool CursorMoved
        " autocmd! Cool InsertEnter
    else
        " nohls --> nohls
        "   do nothing
        return
    endif
endfunction

" play it cool
call <SID>PlayItCool(0, &hlsearch)

let &cpo = s:save_cpo
