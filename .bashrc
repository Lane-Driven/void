# Source all scripts in $HOME/Projects/void/scripts recursively
SCRIPTS_DIR="$HOME/Projects/void/scripts/"

source_scripts_dir() {
    local scripts_count=0

    [ -d "$SCRIPTS_DIR" ] && \
    while IFS= read -r f; do
        ((scripts_count++))  # NOT POSIX  use 'scripts_count=$((scripts_count+1))
    done < <(find "$SCRIPTS_DIR" -type f -name "*.sh" | sort)
}

source_scripts_dir
