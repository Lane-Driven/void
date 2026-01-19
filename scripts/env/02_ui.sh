
echo "DEV: env/02_ui.sh"

ui_git_branch() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
        [ -n "$branch" ] && printf '(%s)' "$branch"
    fi
}

ui_set_prompt() {
    echo $COLOR_RESET
    PS1=$(printf '%s[%s@%s %s\W%s%s%s] \$ ' \
        "$COLOR_GREEN" \
        "$USER"        \
        "$HOSTNAME"    \
        "$COLOR_BLUE"  \
        "$COLOR_YELLOW" \
        '$(ui_git_branch)'  \   # ← single quotes = literal → evaluated each time
        "$COLOR_RESET")
}

# Apply
ui_set_prompt
