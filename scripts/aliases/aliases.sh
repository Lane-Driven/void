alias update="update_void"
# IMPORTANT
alias install="sudo xbps-install -y"

alias sysinfo="uname -a; lscpu; free -h; df -h"

alias ll='ls -lh --color=auto'
alias la='ls -A --color=auto'

alias gs='git status'
alias gl='git log --oneline --graph --decorate --all'
alias gp='git pull'

alias rbash="source ~/.bashrc"


# Function to list common Git + git-extras commands
git_help() {
    echo "=== Common Git Commands ==="
    echo "git status       - Show current repo status"
    echo "git add .        - Stage all changes"
    echo "git commit -m '' - Commit staged changes"
    echo "git log          - View commit history"
    echo "git log --oneline --graph --decorate --all - Compact log view"
    echo "git diff         - Show changes since last commit"
    echo "git branch       - List branches"
    echo "git checkout <branch> - Switch branch"
    echo "git merge <branch>    - Merge another branch"
    echo "git pull         - Fetch and merge updates from remote"
    echo "git push         - Push commits to remote"

    echo ""
    echo "=== Git Extras Commands ==="
    echo "git summary      - Quick summary of the repository"
    echo "git changelog    - Generate changelog from commits"
    echo "git ignore       - Add patterns to .gitignore"
    echo "git fresh-branch - Create a new branch based on default"
    echo "git effort       - Show commit effort by author"
    echo "git info         - Detailed repo info"

    echo ""
    echo "Tip: You can add more aliases or explore 'git help -a' for all available commands."
}

