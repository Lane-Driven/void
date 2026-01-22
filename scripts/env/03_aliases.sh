
alias ud_system="system_update"
alias install="sudo xbps-install -y"

alias sysinfo="uname -a; lscpu; free -h; df -h"

# Allow sudoedit to use vim instead of vi from my userspace
# If I only have root ever available sudoedit will and should just use the untouched builtin 'vi'
export EDITOR=vim
alias svim="sudoedit"

# runit service helpers
alias svrestart="sudo sv restart"
alias svstop="sudo sv stop"
alias svstart="sudo sv start"
alias svstatus="sudo sv status"
alias svreload="sudo sv reload"
alias svlogs="sudo sv log -f"

alias ll='ls -lh --color=auto'
alias la='ls -A --color=auto'

alias gs='git status'
alias gl='git log --oneline --graph --decorate --all'
alias gp='git pull'

alias rbash="source ~/.bashrc"
alias btm='btm --theme nord'
alias top='btm'

# Function to list common Git + git-extras commands
git_help() {
    printf "=== Common Git Commands ===\n"
    printf "git status       - Show current repo status\n"
    printf "git add .        - Stage all changes\n"
    printf "git commit -m '' - Commit staged changes\n"
    printf "git log          - View commit history\n"
    printf "git log --oneline --graph --decorate --all - Compact log view\n"
    printf "git diff         - Show changes since last commit\n"
    printf "git branch       - List branches\n"
    printf "git checkout <branch> - Switch branch\n"
    printf "git merge <branch>    - Merge another branch\n"
    printf "git pull         - Fetch and merge updates from remote\n"
    printf "git push         - Push commits to remote\n"

    printf "\n"
    printf "=== Git Extras Commands ===\n"
    printf "git summary      - Quick summary of the repository\n"
    printf "git changelog    - Generate changelog from commits\n"
    printf "git ignore       - Add patterns to .gitignore\n"
    printf "git fresh-branch - Create a new branch based on default\n"
    printf "git effort       - Show commit effort by author\n"
    printf "git info         - Detailed repo info\n"

    printf "\n"
    printf "Tip: You can add more aliases or explore 'git help -a' for all available commands.\n"
}

alias git_commands="git_help"
