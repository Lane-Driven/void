# -----------------------------
# Modular Super Tree Function
# -----------------------------

# Convert absolute paths to display-friendly (replace $HOME with ~)
stree_display_path() {
    local path="$1"
    if [[ "$path" == "$HOME"* ]]; then
        echo "~${path#$HOME}"
    else
        echo "$path"
    fi
}

# -----------------------------
# Display a single directory with size
# -----------------------------
stree_dir_display() {
    local PARENT="$1"
    local NAME="$2"   # directory name
    local INDENT="$3" # leading spaces for tree alignment

    local FULLPATH="$PARENT/$NAME"
    local SIZE

    if [ -e "$FULLPATH" ]; then
        SIZE=$(du -sh "$FULLPATH" 2>/dev/null | cut -f1)
    else
        SIZE="?"
    fi

    printf "%s[%4s] %s/\n" "$INDENT" "$SIZE" "$NAME"
}

# Smart tree depth based on top-level item count
stree_get_depth() {
    local DIR="$1"
    local COUNT
    COUNT=$(find "$DIR" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l)

    local DEPTH
    if [ "$COUNT" -gt 50 ]; then
        DEPTH=2
    elif [ "$COUNT" -gt 20 ]; then
        DEPTH=3
    else
        DEPTH=4
    fi

    # Ensure minimum depth is 1
    echo $(( DEPTH < 1 ? 1 : DEPTH ))
}
# Detect Git repository
stree_git_check() {
    local DIR="$1"
    [ -d "$DIR/.git" ] && echo -e "\033[1;34mGit repository detected in $DIR\033[0m"
}

# Display a single recent file nicely
stree_find_recent_files() {
    local DIR="${1:-.}"
    local DAYS="${2:-2}"
    local SHOW_HIDDEN="${3:-false}"

    find "$DIR" -type f -mtime -"$DAYS" \
        $( [ "$SHOW_HIDDEN" != true ] && echo ! -name ".*" ) \
        ! -path "*/.git/*" \
        ! -path "*/node_modules/*" \
        ! -path "*/dist/*" 2>/dev/null | sort
}

# List recent files (modified in last N days)
stree_recent_files() {
    local DIR="${1:-.}"
    local DAYS="${2:-2}"
    local LIMIT=5
    local SHOW_HIDDEN="${3:-false}"
    local COUNT=0

    echo -e "\033[1;33mRecent files (last $DAYS days):\033[0m"

    stree_find_recent_files "$DIR" "$DAYS" "$SHOW_HIDDEN" |
    while IFS= read -r file; do
        ((COUNT++))
        if (( COUNT <= LIMIT )); then
            stree_display_recent_file "$file"
        fi
    done

    if (( COUNT > LIMIT )); then
        echo -e "\033[2m# $(( COUNT - LIMIT )) more modified files\033[0m"
    fi
}

# Get tree options safely
stree_tree_opts() {
    local DEPTH="$1"
    local SHOW_HIDDEN="$2"

    # Ensure minimum depth of 1
    DEPTH=$(( DEPTH < 1 ? 1 : DEPTH ))

    local OPTS="--dirsfirst --noreport -L $DEPTH"

    # Show hidden files if requested
    [ "$SHOW_HIDDEN" = true ] && OPTS="$OPTS -a"

    # Always ignore .git
    OPTS="$OPTS -I .git"

    echo "$OPTS"
}

# Display the tree itself
stree_show_tree() {
    local DIR="$1"
    local DEPTH="$2"
    local SHOW_HIDDEN="$3"

    local TREE_OPTS
    TREE_OPTS=$(stree_tree_opts "$DEPTH" "$SHOW_HIDDEN")

    tree -C $TREE_OPTS "$DIR" | while IFS= read -r line; do
        if [[ "$line" =~ ^(\[.*\][[:space:]]+)(.+)/$ ]]; then
            local prefix="${BASH_REMATCH[1]}"
            local name="${BASH_REMATCH[2]}"
            local size
            size=$(stree_dir_size "$DIR/$name")   # centralized size calculation
            local display
            display=$(stree_display_path "$DIR/$name")
            printf "%s[%4s] %s/\n" "$prefix" "$size" "$display"
        elif [[ -f "$line" ]]; then
            ls -lh --color=auto "$line"
        else
            echo "$line"
        fi
    done
}

# -----------------------------
# Main super tree functions
# -----------------------------
stree() {
    local DIR="${1:-.}"
    local SHOW_HIDDEN=false
    local DEPTH

    # Check for -a option
    if [[ "$1" == "-a" ]]; then
        SHOW_HIDDEN=true
        DIR="${2:-.}"
        shift 2
    fi

    DEPTH=$(stree_get_depth "$DIR")
    stree_git_check "$DIR"
    stree_recent_files "$DIR"

    if [ "$SHOW_HIDDEN" = true ]; then
        stree_show_tree "$DIR" "-a" "-L" "$DEPTH" "$@"
    else
        stree_show_tree "$DIR" "-L" "$DEPTH" "$@"
    fi
}

streeh() {
    local DIR="${1:-.}"
    local DEPTH
    DEPTH=$(stree_get_depth "$DIR")
    
    stree_git_check "$DIR"
    stree_recent_files "$DIR" 2 true
    stree_show_tree "$DIR" "$DEPTH" true  # true = show hidden (excluding .git)
}

