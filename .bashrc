update_vimrc() {
    cd ~/Projects/void || return
    git pull
    cp .vimrc ~/.vimrc
    echo 'Updated .vimrc!'
}

alias ud-vimrc='update_vimrc'

source $HOME/Projects/void/scripts/welcome_void/welcome
