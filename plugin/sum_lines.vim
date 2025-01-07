
function! s:GetLastNumberFromString(idx, input)
    " Find all numbers in the string
    let l:matches = []
    let l:start = 0

    " Keep finding numbers until we reach the end
    while l:start < strlen(a:input)
        let l:match = matchstr(a:input, '\d\+', l:start)
        if l:match == ''
            break
        endif
        call add(l:matches, l:match)
        let l:start = matchend(a:input, '\d\+', l:start)
    endwhile

    " Return the last number found, or empty string if none found
    return len(l:matches) > 0 ? eval(l:matches[-1]) : 0
endfunction

function! s:SumNumbersInList(numbers) abort
  " Initialize the sum to 0
  let l:sum = 0

  " Iterate through each number in the list and add to the sum
  for l:num in a:numbers
    let l:sum += l:num
  endfor

  " Return the calculated sum
  return l:sum
endfunction


function! s:LinesToNumbers(lines)
    let l:lines = copy(a:lines)
    let l:lines = map(l:lines, function('s:GetLastNumberFromString'))
    call filter(l:lines, 'v:val != 0')
    return l:lines
endfunction

function! s:SumLines(...)
    let l:argcount = a:0
    if l:argcount > 0
        let l:bufnr = a:1
    else
        let l:bufnr = bufnr()
    endif
    let l:lines = getbufline(l:bufnr, 1, '$')
    " echo string(l:lines)
    let l:lines = s:LinesToNumbers(l:lines)
    let l:sum = s:SumNumbersInList(l:lines)
    echo "Sum: " . string(l:sum)
endfunction

function! s:SumIt(line1, line2)
    if a:line1 != a:line2
        let l:lines = getbufline(bufnr(), a:line1, a:line2)
    else
        let l:lines = getbufline(bufnr(), 1, '$')
    endif
    let l:lines = s:LinesToNumbers(l:lines)
    let l:sum = s:SumNumbersInList(l:lines)
    echo "Sum: " . string(l:sum)
endfunction

command! -range SumIt call s:SumIt(<line1>, <line2>)

