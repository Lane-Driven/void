# Source all scripts in $HOME/Projects/void/scripts recursively
SCRIPTS_DIR="$HOME/Projects/void/scripts/"

echo "DEVELOPMENT MODE"

[ -d "$SCRIPTS_DIR" ] && \
while IFS= read -r f; do
    [ -f "$f" ] && echo "$f" && source "$f"
done < <(find "$SCRIPTS_DIR" -type f -name "*.sh" | sort)

