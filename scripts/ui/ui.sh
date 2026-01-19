
echo "DEV: ui/ui.sh"

ui_git_branch() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        branch=$(git symbolic-ref --short HEAD 2>/dev/null)
        if [ -z "$branch" ]; then
            branch=$(git rev-parse --short HEAD 2>/dev/null)
        fi
        printf '(%s)' "$branch"
    fi
}

ui_set_prompt() {
    PS1=$(printf '%s[%s@%s %s%s]%s%s%s $ ' \
        "$COLOR_GREEN" \
        "$USER" \
        "$(hostname)" \
        "$COLOR_BLUE" \
        "$(basename "$PWD")" \
        "$COLOR_YELLOW" \
        "$(ui_git_branch)" \
        "$COLOR_RESET")
}

# Apply
ui_set_prompt
