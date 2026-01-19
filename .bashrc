# Source all scripts in $HOME/Projects/void/scripts recursively
SCRIPTS_DIR="$HOME/Projects/void/scripts/"

echo "DEVELOPMENT MODE"

local scripts_count=0
[ -d "$SCRIPTS_DIR" ] && \
while IFS= read -r f; do
    [ -f "$f" ] && echo "Sourcing: $f" && source "$f"
    ((scripts_count++))  # NOT POSIX  use 'scripts_count=$((scripts_count+1))
done < <(find "$SCRIPTS_DIR" -type f -name "*.sh" | sort)

