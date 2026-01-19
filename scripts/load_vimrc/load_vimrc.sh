
echo "DEV: update_vim/update_vim.sh"

update_vimrc() {
    cd ~/Projects/void || return
    git pull
    cp .vimrc ~/.vimrc
    printf "Updated .vimrc!\n"
}

alias ud-vimrc='update_vimrc'
