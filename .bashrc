update_vimrc() {
    cd ~/Projects/void || return
    git pull
    cp .vimrc ~/.vimrc
    echo 'Updated .vimrc!'
}

alias ud-vimrc='update_vimrc'
