# Source all scripts in $HOME/Projects/void/scripts recursively
SCRIPTS_DIR="$HOME/Projects/void/scripts/"

source_scripts_dir() {
    [ -d "$SCRIPTS_DIR" ] && \
    while IFS= read -r f; do
        [ -f "$f" ] && echo && source "$f"
    done < <(find "$SCRIPTS_DIR" -type f -name "*.sh" | sort)
}

source_scripts_dir
