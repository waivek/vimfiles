" for tmux launched from fish
if &term =~ '^screen'
    let &t_BE="\<Esc>[?2004h"
    let &t_BD="\<Esc>[?2004l"
    let &t_PS="\<Esc>[200~"
    let &t_PE="\<Esc>[201~"
endif

set title
