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

# Get Git branch (if in a Git repo)
ui_git_branch() {
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        local BRANCH
        BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
        echo "(${BRANCH})"
    fi
}

# Build the user@host + cwd part
ui_user_host_cwd() {
    echo -n "\[${UI_GREEN}\][\u@\h \[${UI_BLUE}\]\w\[${UI_GREEN}\]]"
}

# Build the Git branch part
ui_git_prompt() {
    local BRANCH
    BRANCH=$(ui_git_branch)
    if [[ -n "$BRANCH" ]]; then
        echo -n "\[${UI_YELLOW}\]${BRANCH}\[${UI_RESET}\]"
    else
        echo -n " "  # optional spacing if no branch
    fi
}

# Combine into a dynamic prompt
ui_set_prompt() {
    PS1='$(ui_user_host_cwd)$(ui_git_prompt) \$ '
}

# Apply the prompt
ui_set_prompt

