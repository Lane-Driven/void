#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/../colors/colors.sh"

# Get Git branch
ui_git_branch() {
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        local branch
        branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
        echo "(${branch})"
    fi
}

# Build PS1 dynamically
ui_set_prompt() {
    PS1="${COLOR_GREEN}[\u@\h ${COLOR_BLUE}\W${COLOR_GREEN}]${COLOR_YELLOW}\$(ui_git_branch)${COLOR_RESET} \$ "
}

# Apply
ui_set_prompt
