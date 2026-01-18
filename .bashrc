# Source all scripts in $HOME/Projects/void/scripts recursively
SCRIPTS_DIR="$(cd -- "$(dirname -- "{BASH_SOURCE[0]}")" && pwd)/scripts"
echo "Hello from void/bashrc"
[ -d "$SCRIPTS_DIR" ] && \
while IFS= read -r f; do
    [ -f "$f" ] && source "$f"
done < <(find "$SCRIPTS_DIR" -type f -name "*.sh" | sort)

