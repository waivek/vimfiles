
" 1. When you WRITE a file, create a copy of the file in ~/Desktop/all-files/filename.ext
" 2. Exclude READONLY files
" 3. Exclude files > 1mb (Everything.reg, all.json)
" 4. Put higher priority on files that you spend a lot of time on. Deduce this
"    by looking at the changelist.
" 5. Should be completely silent. A. COPY B. GIT COMMIT C. GIT PUSH
" 6. Duplicate examples ftplugin/html.vim, autoload/html.vim
" 7. Handle conflicts how you handle MRU but with an SQLite db storing
"    filename -> path mappings which can be updated when duplicates are
"    encountered. Filename: SMALLEST UNIQUE FILENAME. Link FILENAME to PATH.
"
"    Detect MOVE, RENAME, DELETE
"    MOVE -> UPDATE PATH, RECALCULATE SMALLEST UNIQUE FILENAME
"
" 8. Performance should be able to handle 30 file `:cdo`
" 9. Patch undofiles to be able to update when an external program has
"    modified the file.
