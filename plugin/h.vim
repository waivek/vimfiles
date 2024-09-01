function! s:GetBuffersWithChangeStats()

    " native is len(undotree())['entries'], per buffer; would have to figure
    " out how to get for all buffers as undotree() doesn’t take arguments
    " [-ve] would get wiped out on docker re-installs as undofiles() is not in `vcs`

    " otherwise i’d require a robust file watcher which would be more
    " independent but external. filewatcher would take a list of workspaces
    " over which it would watch the non gitignore’ed files
    " [1] is file watcher online ?
    " [2] is the file i'm editing being watched by the file ?
    " [3] are changes being comitted ? 

    " best option is to keep track of every bufwrite in a vcs'ed directory of
    " json files. the only additonal burden here would be updating files on
    " renames / file moves

endfunction
