# Source all scripts in $HOME/Projects/void/scripts recursively
SCRIPTS_DIR="$HOME/Projects/void/scripts"
MY_TEST="$(cd -- "$(dirname -- "{BASH_SOURCE[0]}")" && pwd)"
echo "MY TEST: $MY_TEST" 
[ -d "$SCRIPTS_DIR" ] && \
while IFS= read -r f; do
    [ -f "$f" ] && source "$f"
done < <(find "$SCRIPTS_DIR" -type f -name "*.sh" | sort)

