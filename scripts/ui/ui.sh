#!/usr/bin/env bash
# -----------------------------
# Terminal prompt UI
# -----------------------------

# Colors
UI_RESET="\[\033[0m\]"
UI_BOLD="\[\033[1m\]"
UI_BLUE="\[\033[1;34m\]"
UI_GREEN="\[\033[1;32m\]"
UI_YELLOW="\[\033[1;33m\]"
UI_RED="\[\033[1;31m\]"

# Function to get Git branch (if in a Git repo)
ui_git_branch() {
    # Only show branch if we're in a git repo
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        local BRANCH
        BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
        echo -n "\[${UI_YELLOW}(${BRANCH})${UI_RESET}\]"
    fi
}

# Set PS1
ui_set_prompt() {
    # \u = user, \h = host, \w = full path
    PS1="${UI_GREEN}[\u@\h ${UI_BLUE}\w${UI_RESET}]\$(ui_git_branch) \$ "
}

# Apply it
ui_set_prompt

