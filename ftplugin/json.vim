if has('win32')
    let &formatprg='C:\Users\vivek\go\src\jsonfmt\jsonfmt.exe'
else
    let &formatprg='jq --indent 4'
endif
