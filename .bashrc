# Source all scripts in $HOME/Projects/void/scripts recursively
SCRIPTS_DIR="$HOME/Projects/void/scripts/"

printf '\033[33mDevelopment Mode\033[0m\n'

source_scripts_dir() {
    local scripts_count=0

    [ -d "$SCRIPTS_DIR" ] && \
    while IFS= read -r f; do
        [ -f "$f" ] && echo "Sourcing: $f" && source "$f"
        ((scripts_count++))  # NOT POSIX  use 'scripts_count=$((scripts_count+1))
    done < <(find "$SCRIPTS_DIR" -type f -name "*.sh" | sort)
}

source_scripts_dir
