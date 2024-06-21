
function! s:FindFlaskRoot()
    let current_file_path = expand("%:p")
    " keep going up the directory tree until we find a folder with a folder
    " named 'templates' in it
    let current_dir = fnamemodify(current_file_path, ":h")
    while v:true
        let static_candidate = current_dir . "/static"
        if isdirectory(static_candidate)
            return current_dir
        endif
        if fnamemodify(current_dir, ":p") == current_dir
            return ""
        endif
        let current_dir = fnamemodify(current_dir, ":h")
    endwhile
    return current_dir

endfunction

function! s:GetCSSFiles()
    let flask_root = s:FindFlaskRoot()
    let static_folder = flask_root . "/static"
    let css_files = glob(flask_root . "/static/**/*.css", 0, 1)
    let css_files_truncated = map(css_files, {idx, val -> strpart(val, len(static_folder) + 1)})
    return css_files_truncated
endfunction

function! s:CompletionFunction(...)
    let flask_root = s:FindFlaskRoot()
    if flask_root == ""
        return []
    endif
    let css_files = s:GetCSSFiles()
    return css_files
endfunction

function! s:FlaskStylesheet(selection)
    let link_string = printf('<link rel="stylesheet" href="{{ url_for(''static'', filename=''%s'') }}">', a:selection)
    call append(line("."), link_string)
endfunction

augroup FlaskStylesheet
    au!
    " for filetype htmldjango
    " for python files that import flask

augroup END
command! -nargs=1 -complete=customlist,s:CompletionFunction FlaskStylesheet call s:FlaskStylesheet(<f-args>)
