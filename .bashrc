# Source all scripts in $HOME/Projects/void/scripts recursively
SCRIPTS_DIR="$HOME/Projects/void/scripts/"

source_scripts_dir() {
    local scripts_count=0

    [ -d "$SCRIPTS_DIR" ] && \
    while IFS= read -r f; do
        [ -f "$f" ] && echo && source "$f"
        ((scripts_count++))  # NOT POSIX  use 'scripts_count=$((scripts_count+1))
    done < <(find "$SCRIPTS_DIR" -type f -name "*.sh" | sort)
    echo "${COLOR_YELLOW}Scripts loaded: ${scripts_count}"
}

source_scripts_dir
