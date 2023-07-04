
function! s:GetTemplateNames(...)
    let extension = expand("%:e")
    let pattern =  '*.'.extension
    echo pattern
    let files_in_directory = split(globpath(s:GetTemplateDir(), pattern), '\n')
    let template_names = []
    for file in files_in_directory
        echo file
        let template_names = template_names + [fnamemodify(file, ':t:r')]
    endfor
    return template_names
endfunction

function! s:GetTemplateDir()
    let template_dir = has('win32') || has('win64') ? '~/vimfiles/templates' : '~/.vim/templates'
    let separator = has('win32') || has('win64') ? '\' : '/'
    let template_dir = expand(template_dir . separator)
    return template_dir
endfunction

function! s:GetFilename(args)
    let extension = expand("%:e")
    if len(a:args) == 0
        let filename = "template" . "." . extension
    else
        let filename = a:args . "." . extension
    endif
    return filename
endfunction

function! s:Template(args)
    let template_path = s:GetTemplateDir() . s:GetFilename(a:args)
    if !filereadable(template_path)
        echo 'Template not found: ' . template_path
        return
    endif
    let l:template = readfile(template_path)
    call append(0, l:template)
endfunction
command -complete=customlist,s:GetTemplateNames -nargs=? Template call s:Template(<q-args>)
