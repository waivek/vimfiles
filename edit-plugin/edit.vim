
" keep track of all `write` commands done to each file inside vim on a
" database file

" we show 10 files to try to guess which file the user is trying to jump to

" file ranking considerations:
" 1. number of writes
" 2. number of writes in the last 1 hour / 1 day / 1 week
" 3. whether the file is loaded in the buffer 
" 4. whether the file is in the current root directory / project files
" 5. prioritize .py files?
" 6. interaction frequeuncy
" 7. last access counts

" Define functions to call the C library

" read the library path from the file

" check if library_name.txt exists

source ./sqlite-functions.vim
