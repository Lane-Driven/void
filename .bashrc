# Source all scripts in $HOME/void/scripts recursively
SCRIPTS_DIR="$HOME/void/scripts/"

source_scripts_dir() {
    [ -d "$SCRIPTS_DIR" ] && \
    while IFS= read -r f; do
        [ -f "$f" ] && source "$f"
    done < <(find "$SCRIPTS_DIR" -type f -name "*.sh" | sort)
}

source_scripts_dir
