# Source all scripts in $HOME/Projects/void/scripts recursively
SCRIPTS_DIR="$HOME/Projects/void/scripts/"

DEV_YELLOW="\033[33m"
DEV_RESET="\033[0m"

printf '%sDevelopment Mode%s' "$DEV_YELLOW" "$DEV_RESET"

source_scripts_dir() {
    local scripts_count=0

    [ -d "$SCRIPTS_DIR" ] && \
    while IFS= read -r f; do
        ((scripts_count++))  # NOT POSIX  use 'scripts_count=$((scripts_count+1))
    done < <(find "$SCRIPTS_DIR" -type f -name "*.sh" | sort)
    printf '%sScripts loaded: %s.%s' "$DEV_YELLOW" "$scripts_count" "$DEV_RESET"
}

source_scripts_dir
