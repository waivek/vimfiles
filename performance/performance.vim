

" s:ToTail() {{{
function! s:ToTail(key, val)
    return a:key.":".fnamemodify(a:val, ":t")
endfunction
" }}}

" s:FilterTests() {{{
function! s:FilterTests()
    let s:iter_count = 10
    let s:pattern = "tw"
    let s:L = copy(v:oldfiles)
    if exists("s:mapped_results")
        unlet s:mapped_results
    endif
    if exists("s:filtered_results")
        unlet s:filtered_results
    endif

    if !exists("g:tails")
        let g:tails = []
        for fname in v:oldfiles
            let tail = fnamemodify(fname, ":t")
            call add(g:tails, tail)
        endfor
    endif

    let s:pattern_string = '\<' . s:pattern


    let s:results = []
    let start_time = common#Time()
    
    for i in range(s:iter_count)
        " for tail in g:tails
        "     if tail =~# s:pattern_string
        "         " call add(s:results, tail)
        "     endif
        " endfor
        " " 0.10
        " let s:results = filter(copy(g:tails), 'v:val =~# s:pattern_string')

        " 0.17
        " for fname in v:oldfiles
        "     let tail = ":".fnamemodify(fname, ":t")
        " endfor

        " 0.14
        " let s:results = map(copy(s:L), 'v:key.":".fnamemodify(v:val, ":t")')

        " 0.24
        " let s:mapped_results = map(copy(s:L), 'v:key.":".fnamemodify(v:val, ":t")')
        " let s:filtered_results = filter(s:mapped_results, 'v:val =~# s:pattern_string')


        " 0.25
        " let s:mapped_results = map(copy(s:L), '{"oldfiles_index": v:key, "tail": fnamemodify(v:val, ":t") }')
        " let s:filtered_results = filter(s:mapped_results, 'v:val["tail"] =~# s:pattern_string')

        " " 0.25
        " let s:mapped_results = map(copy(s:L), '{ "tail":  fnamemodify(v:val, ":t"), "oldfiles_index": v:key } ')
        " let s:filtered_results = filter(copy(s:mapped_results), 'v:val["tail"] =~# s:pattern_string')

        " 0.25
        " let s:results = map(copy(s:L), {key, val -> { "tail":  fnamemodify(v:val, ":t"), "oldfiles_index": v:key } })

        " 0.25
        " let s:results = map(copy(s:L), {key, val -> v:key.":".fnamemodify(v:val, ":t")})

        " 0.24
        " let s:results = map(copy(s:L), function('s:ToTail'))

        " 0.18
        " let s:results = map(copy(s:L), 'join([v:key,fnamemodify(v:val, ":t")])')

        " 0.17
        " let s:results = map(copy(s:L), 'printf("%s%s", v:key,fnamemodify(v:val, ":t"))')

        " echo s:mapped_results[0:5]
        " echo s:results
    endfor
    let time_taken = common#Time() - start_time
    echo "time_taken: ".printf("%f", time_taken)
endfunction

" }}}

" s:MruProfile() {{{
function! s:MruProfile()
    let g:performance_tails = map(copy(v:oldfiles), '{"oldfiles_index": v:key+1, "uniquetail": fnamemodify(v:val, ":t"), "tail": fnamemodify(v:val, ":t"), "text": v:val  }')
    let L = [ "u", "ut", "uti", "util" ]
    " Length, Time
    " RAW 14
    " 2648, 0.140
    "  100, 0.007

    " Time, (query: util)
    " 0.040
    function! s:ExtractTails(dictionaries)
        let tails = []
        for D in a:dictionaries
            call add(tails, D["tail"])
        endfor
        return tails
    endfunction
    let MinusOne = { s -> strpart(s, 0, len(s)-1) }
    let results_D = {}
    let final_filenames = []
    let isk_save=&iskeyword
    set isk-=_
    for regex in L
        let pattern_string = '\<'.regex
        let previous_regex = MinusOne(regex)
        if has_key(results_D, previous_regex)
            let tails_copy = copy(results_D[previous_regex])
        else
            let tails_copy = copy(g:performance_tails)
        endif
        let filenames = filter(tails_copy, 'v:val["tail"] =~# pattern_string')
        if !has_key(results_D, regex)
            " let results_D[regex] = copy(filenames)
            let results_D[regex] = filenames
        endif
    endfor
    let &iskeyword=isk_save
endfunction
" }}}

" s:LambdaVsFor() {{{
function! s:LambdaVsFor(test_cache)
    let test_cache = a:test_cache
    let start_time = s:Time()

    let difference = strlen("something") - strlen("keyword")
    let last_change_position = 100
    " 0.32
    " for k in range(100)
    "     for i in range(len(test_cache))
    "        let position = test_cache[i]
    "        if position > last_change_position
    "            let test_cache[i] = test_cache[i] + difference
    "        endif
    "     endfor
    " endfor
    
    " "0.17
    for i in range(100)
        call map(test_cache, {_, value -> value > last_change_position ? value+difference : value })
    endfor

    " 0.19
    " function! IncrementOnCondition(last_change_position, difference, _, value)
    "     return a:value > a:last_change_position ? a:value + a:difference: a:value
    " endfunction
    " let MyClosure = function("IncrementOnCondition", [last_change_position, difference])
    " for i in range(100)
    "     call map(test_cache, MyClosure)
    " endfor



    let time_taken = string(s:Time() - start_time) 
    echo "time_taken: ".time_taken
endfunction
" }}}

" s:SearchList() {{{
function! s:SearchList(test_cache)
    let test_cache = a:test_cache
    let start_time = s:Time()
    let search_key = 25373


    " 0.000031
    " let key_index=  index(test_cache, search_key)
    " let match_count = len(test_cache)





    let time_taken = s:Time() - start_time 
    echo "time_taken: ".printf("%f", time_taken)
endfunction

" let test_cache = [38, 53, 68, 83, 98, 23713, 23728, 23746, 23761, 23776, 23791, 23806, 23821, 23836, 23851, 23866, 23884, 23899, 23914, 23929, 23944, 23959, 23974, 23989, 24004, 24038, 24053, 24068, 24083, 24098, 24113, 24128, 24143, 24159, 24174, 24189, 24204, 24219, 24234, 24249, 24264, 24279, 24295, 24310, 24325, 24340, 24355, 24370, 24385, 24400, 24415, 24433, 24448, 24463, 24478, 24493, 24508, 24523, 24538, 24553, 24569, 24584, 24599, 24614, 24629, 24644, 24659, 24674, 24689, 24705, 24720, 24735, 24750, 24765, 24780, 24795, 24810, 24825, 24843, 24858, 24873, 24888, 24903, 24918, 24933, 24948, 24963, 24979, 24994, 25009, 25024, 25039, 25054, 25069, 25084, 25099, 25115, 25130, 25145, 25160, 25175, 25190, 25205, 25220, 25235, 25253, 25268, 25283, 25298, 25313, 25328, 25343, 25358, 25373, 25389, 25404, 25419, 25434, 25449, 25464, 25479, 25494, 25509, 25525, 25540, 25555, 25570, 25585, 25600, 25615, 25630, 25645, 26032, 26047, 26062, 26077, 26092, 26107, 26122, 26137, 26152, 26168, 26183, 26198, 26213, 26228, 26243, 26258, 26273, 26288, 26304, 26319, 26334, 26349, 26364, 26379, 26394, 26409, 26424, 26576, 26591, 26606, 26621, 26636, 26651, 26666, 26681, 26696, 26712, 26727, 26742, 26757, 26772, 26787, 26802, 26817, 26832, 26848, 26863, 26878, 26893, 26908, 26923, 26938, 26953, 26968, 26986, 27001, 27016, 27031, 27046, 27061, 27076, 27091, 27106, 27122, 27137, 27152, 27167, 27182, 27197, 27212, 27227, 27242, 27258, 27273, 27288, 27303, 27318, 27333, 27348, 27363, 27378, 27396, 27411, 27426, 27441, 27456, 27471, 27486, 27501, 27516, 27532, 27547, 27562, 27577, 27592, 27607, 27622, 27637, 27652, 27668, 27683, 27698, 27713, 27728, 27743, 27758, 27773, 27788, 27806, 27821, 27836, 27851, 27866, 27881, 27896, 27911, 27926, 27942, 27957, 27972, 27987, 28002, 28017, 28032, 28047, 28062, 28078, 28093, 28108, 28123, 28138, 28153, 28168, 28183, 28198, 31303 ]
" call s:SearchList(test_cache)
" }}}

" s:SplitList() {{{
function! s:SplitList()
    let test_cache = [38, 53, 68, 83, 98, 23713, 23728, 23746, 23761, 23776, 23791, 23806, 23821, 23836, 23851, 23866, 23884, 23899, 23914, 23929, 23944, 23959, 23974, 23989, 24004, 24038, 24053, 24068, 24083, 24098, 24113, 24128, 24143, 24159, 24174, 24189, 24204, 24219, 24234, 24249, 24264, 24279, 24295, 24310, 24325, 24340, 24355, 24370, 24385, 24400, 24415, 24433, 24448, 24463, 24478, 24493, 24508, 24523, 24538, 24553, 24569, 24584, 24599, 24614, 24629, 24644, 24659, 24674, 24689, 24705, 24720, 24735, 24750, 24765, 24780, 24795, 24810, 24825, 24843, 24858, 24873, 24888, 24903, 24918, 24933, 24948, 24963, 24979, 24994, 25009, 25024, 25039, 25054, 25069, 25084, 25099, 25115, 25130, 25145, 25160, 25175, 25190, 25205, 25220, 25235, 25253, 25268, 25283, 25298, 25313, 25328, 25343, 25358, 25373, 25389, 25404, 25419, 25434, 25449, 25464, 25479, 25494, 25509, 25525, 25540, 25555, 25570, 25585, 25600, 25615, 25630, 25645, 26032, 26047, 26062, 26077, 26092, 26107, 26122, 26137, 26152, 26168, 26183, 26198, 26213, 26228, 26243, 26258, 26273, 26288, 26304, 26319, 26334, 26349, 26364, 26379, 26394, 26409, 26424, 26576, 26591, 26606, 26621, 26636, 26651, 26666, 26681, 26696, 26712, 26727, 26742, 26757, 26772, 26787, 26802, 26817, 26832, 26848, 26863, 26878, 26893, 26908, 26923, 26938, 26953, 26968, 26986, 27001, 27016, 27031, 27046, 27061, 27076, 27091, 27106, 27122, 27137, 27152, 27167, 27182, 27197, 27212, 27227, 27242, 27258, 27273, 27288, 27303, 27318, 27333, 27348, 27363, 27378, 27396, 27411, 27426, 27441, 27456, 27471, 27486, 27501, 27516, 27532, 27547, 27562, 27577, 27592, 27607, 27622, 27637, 27652, 27668, 27683, 27698, 27713, 27728, 27743, 27758, 27773, 27788, 27806, 27821, 27836, 27851, 27866, 27881, 27896, 27911, 27926, 27942, 27957, 27972, 27987, 28002, 28017, 28032, 28047, 28062, 28078, 28093, 28108, 28123, 28138, 28153, 28168, 28183, 28198, 31303 ]
    let length = len(test_cache)
    let mid_element = test_cache[length / 2]
    let start_time = common#Time()
    let difference = 5
    for i in range(100)

        " 0.12-0.17
        " let positions_before_match = filter(copy(test_cache), { _, value -> value < l:mid_element })

        " 0.006
        " let search_index = index(test_cache, mid_element)
        " let positions_before_match = test_cache[0:search_index-1]

    endfor
    let time_taken = common#Time() - start_time
    echo "time_taken: ".printf("%f", time_taken)
endfunction
" }}}

" s:PressN() {{{
function! s:PressN()
    let view_save = winsaveview()
    let start_time = common#Time()

    for i in range(100)
        " 0.02
        silent! keepjumps n

        " " 0.002
        " call search(@/)
    endfor
    let time_taken = common#Time() - start_time
    echo "time_taken: ".printf("%f", time_taken)
    call winrestview(view_save)
endfunction
" nnoremap <silent> ga :call <SID>PressN()<CR>
" }}}

" s:GetRandomD() {{{
function! s:GetRandomD()
    let json_D = {}
    let entry_count = 3000
    " let entry_count = 4
    let seed = srand(100)
    for i in range(entry_count)
        let key = "key_".rand(seed)
        let value = i
        let json_D[key] = value
    endfor
    return json_D
endfunction
" }}}

" s:ProfileJSONFunctionsViaDictionary() {{{
function! s:ProfileJSONFunctionsViaDictionary()
    let path = expand("~/vimfiles/logs/t1.json")
    let json_D = s:GetRandomD()

    let start_time = common#Time()

    " " 0.009
    " let json_string = json_encode(json_D)
    " let file_L = [ json_string ]
    " call writefile(file_L, path, "w")

    " " 0.007
    " let file_L = readfile(path)[0]
    " let new_D = json_decode(file_L)
    " let my_value = new_D["key_234013740"]

    " 0.018
    let keys = keys(json_D)
    let my_L = map(keys, { _, key -> [ key, json_D[key] ] })
    call sort(my_L, { T1, T2 -> T1[1] < T2[1] ? 1 : -1})
    let time_taken = common#Time() - start_time
    echo "time_taken: ".printf("%f", time_taken)
endfunction
" }}}

" s:ProfileSqlite() {{{
let s:call_count = 0
function! s:JobCallback(...)
    let s:call_count = s:call_count + 1
    echoerr 's:call_count: '.s:call_count
endfunction
function! s:ProfileSqlite()
    let start_time = common#Time()
    " call job_start('sqlite3 C:\Users\vivek\vimfiles\logs\mru.db "SELECT * FROM mru"', { 'callback': function('s:JobCallback') } )

    let command = [&shell, &shellcmdflag, 'sqlite3 logs/mru.db "SELECT * FROM mru"']
    " let command = [&shell, &shellcmdflag, 'type mini.vimrc']
    let job = job_start('sqlite3 C:\Users\vivek\vimfiles\logs\mru.db "SELECT * FROM mru"', {'out_io': 'buffer', 'out_name': 'mybuffer'})

    let time_taken = common#Time() - start_time
    echo "time_taken: ".printf("%f", time_taken)
endfunction
" call s:ProfileSqlite()
" }}}

function! s:GetProfileFilepath(name)
    let date_string = strftime("%y%m%d")
    let file_version = -1
    let version_string = printf("%02d", file_version)
    let vimhome = has('win32') ? '~/vimfiles' : '~/.vim'
    let path_end = 'performance/%s.%s.v%02d.txt'
    let separator = '/'
    let file_format = join([vimhome, path_end], separator)

    let filepath = v:null
    for i in range(1, 50)
        let filepath = printf(file_format, date_string, a:name, i)
        let file_exists = filereadable(expand(filepath))
        if file_exists == v:false
            break
        endif
        " echo printf("Exists: %s | Path: %s", file_exists, filepath)
    endfor
    return filepath
endfunction


function! s:ProfileHorizontalMovement()
    let filepath = s:GetProfileFilepath('horizontal_movement')
    let command = printf('profile start %s | profile func * | profile file *', filepath)
    execute command
endfunction
" command! PHM call s:ProfileHorizontalMovement()

function! s:ProfileSidewaysParsing()
    let filepath = s:GetProfileFilepath('sideways_parsing')
    let command = printf('profile start %s | profile func * | profile file *', filepath)
    execute command
endfunction
command! PSP call s:ProfileSidewaysParsing()

function! s:ProfilePythonO()
    let filepath = s:GetProfileFilepath('python_o')
    let command = printf('profile start %s | profile func * | profile file *', filepath)
    execute command
endfunction
command! PPO call s:ProfilePythonO()

function! s:ProfilePythonLag()
    let filepath = s:GetProfileFilepath('python_lag')
    let command = printf('profile start %s | profile func * | profile file *', filepath)
    execute command
endfunction
command! PPL call s:ProfilePythonLag()


function! s:ProfileHTMLWrite()
    let filepath = s:GetProfileFilepath('html_write')
    let command = printf('profile start %s | profile func * | profile file *', filepath)
    execute command
endfunction
command! PHW call s:ProfileHTMLWrite()

function! s:ProfileCocVars()
    let filepath = s:GetProfileFilepath('coc_vars')
    let command = printf('profile start %s | profile func * | profile file *', filepath)
    execute command
endfunction
command! PCV call s:ProfileCocVars()

function! s:ProfileLongPauseLinuxTerm()
    let filepath = s:GetProfileFilepath('long_pause_linux_term')
    let command = printf('profile start %s | profile func * | profile file *', filepath)
    execute command
endfunction
command! PLPLT call s:ProfileLongPauseLinuxTerm()

function! s:ProfileVueFileRead()
    let filepath = s:GetProfileFilepath('vue_file_read')
    let command = printf('profile start %s | profile func * | profile file *', filepath)
    execute command
endfunction
command! PVFR call s:ProfileVueFileRead()

function! s:ProfileVimExit()
    let filepath = s:GetProfileFilepath('vim_exit')
    let command = printf('profile start %s | profile func * | profile file *', filepath)
    execute command
endfunction
command! PVE call s:ProfileVimExit()

" nnoremap <Plug>PlugProfilePause :call <SID>ProfilePause()<CR>
nnoremap ga :profile pause<CR>

" call s:ProfileHorizontalMovement()
