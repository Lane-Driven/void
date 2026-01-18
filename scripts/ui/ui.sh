#!/usr/bin/env bash

# Colors
UI_RESET="\[\033[0m\]"
UI_GREEN="\[\033[1;32m\]"
UI_BLUE="\[\033[1;34m\]"
UI_YELLOW="\[\033[38;5;226m\]"

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
    PS1="${UI_GREEN}[\u@\h ${UI_BLUE}\w${UI_GREEN}]${UI_YELLOW}\$(ui_git_branch)${UI_RESET} \$ "
}

# Apply
ui_set_prompt

