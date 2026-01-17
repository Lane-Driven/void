# Source all scripts in $HOME/Projects/void/scripts recursively
find "$HOME/Projects/void/scripts" -type f -name "*.sh" | sort | while read -r f; do
    if [ -f "$f" ]; then
        source "$f"
    fi
done

