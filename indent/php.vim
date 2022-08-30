"
" SOURCE: https://vim.fandom.com/wiki/Better_indent_support_for_php_with_html
"
" Better indent support for PHP by making it possible to indent HTML sections
" as well.
if exists("b:did_indent")
  finish
endif
" This script pulls in the default indent/php.vim with the :runtime command
" which could re-run this script recursively unless we catch that:
if exists('s:doing_indent_inits')
  finish
endif
let s:doing_indent_inits = 1
runtime! indent/html.vim
unlet b:did_indent
runtime! indent/php.vim
unlet s:doing_indent_inits
function! s:InsideScriptBlock()
    " let script_start = search('<script>', "bnc")
    " if script_start == 0
    "     return v:false
    " endif
    " let script_end = search('</script>', "nc")
    " if script_end == 0
    "     return v:false
    " endif
    " let inside_script_block = line(".") >= script_start && line(".") <= script_end
    " return inside_script_block
    let before_line_num = search('<\/\?script', "bnc")
    let after_line_num = search('<\/\?script', "nc")
    if before_line_num == 0 || after_line_num == 0
        " echoerr "First False: before: ".string(before_line_num).", after: ".string(after_line_num)
        return v:false
    endif
    let before_script_type = stridx(getline(before_line_num), '/') == -1 ? "START" : "END"
    let after_script_type = stridx(getline(after_line_num), '/') == -1 ? "START" : "END"
    if before_script_type ==# "START" && after_script_type ==# "END"
        " echoerr "True"
        return v:true
    endif
    " echoerr "Last False: before_script_type: ".before_script_type.", after_script_type: ".after_script_type
    return v:false
endfunction
function! s:GetPhpHtmlIndent(lnum)
    if s:InsideScriptBlock()
        return GetJavascriptIndent()
    endif
  if exists('*HtmlIndent')
    let html_ind = HtmlIndent()
  else
    let html_ind = HtmlIndentGet(a:lnum)
  endif
  let php_ind = GetPhpIndent()
  " priority one for php indent script
  if php_ind > -1
    return php_ind
  endif
  if html_ind > -1
    if getline(a:lnum) =~ "^<?" && (0< searchpair('<?', '', '?>', 'nWb')
          \ || 0 < searchpair('<?', '', '?>', 'nW'))
      return -1
    endif
    return html_ind
  endif
  return -1
endfunction
setlocal indentexpr=s:GetPhpHtmlIndent(v:lnum)
setlocal indentkeys+=<>>
