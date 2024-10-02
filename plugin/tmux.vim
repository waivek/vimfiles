
" Hide tmux status bar when entering Vim and show it when leaving

" augroup TmuxStatusToggle
"   autocmd!
"   
"   " Hide tmux status bar when entering Vim
"   autocmd VimEnter * silent !tmux setw status off
"
"   " Show tmux status bar when leaving Vim
"   autocmd VimLeave * silent !tmux setw status on
" augroup END
"

" for tmux launched from fish
if &term =~ '^screen'
    let &t_BE="\<Esc>[?2004h"
    let &t_BD="\<Esc>[?2004l"
    let &t_PS="\<Esc>[200~"
    let &t_PE="\<Esc>[201~"
endif

set title
