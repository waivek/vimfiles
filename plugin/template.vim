
function! s:Template()
    let filetype_to_path_dict = {
                \ 'python': 'C:\Users\vivek\Python\waivek\waivek\template.py',
                \ 'vue':    'C:\Users\vivek\Documents\vuejs\template.vue',
                \ }
    let template_path = get(filetype_to_path_dict, &filetype, v:null)
    if template_path == v:null
        echo 'no template'
        return
    endif
    let l:template = readfile(template_path)
    call append(0, l:template)
    1
endfunction

command Template call s:Template()
