# -----------------------------
# Modular Super Tree Function
# -----------------------------

stree_dir_size() {
    du -sh "$1" 2>/dev/null | cut -f1
}

# Get smart depth based on number of top-level items
stree_get_depth() {
    local DIR="$1"
    local COUNT
    COUNT=$(find "$DIR" -mindepth 1 -maxdepth 1 | wc -l)
    if [ "$COUNT" -gt 50 ]; then
        echo 2
    elif [ "$COUNT" -gt 20 ]; then
        echo 3
    else
        echo 4
    fi
}

# Detect if folder is a Git repository
stree_git_check() {
    local DIR="$1"
    [ -d "$DIR/.git" ] && echo -e "\033[1;34mGit repository detected in $DIR\033[0m"
}

# List recent files (modified in last N days)
stree_recent_files() {
    local DIR="$1"
    local DAYS="${2:-2}"
    local LIMIT=5

    local files
    mapfile -t files < <(
        find "$DIR" -type f -mtime -"$DAYS" -print
    )

    local count="${#files[@]}"

    (( count == 0 )) && return

    echo -e "\033[1;33mRecent files (last $DAYS days):\033[0m"

    for (( i=0; i< count && i< LIMIT; i++ )); do
        ls -lh --color=auto "${files[i]}"
    done

    if (( count > LIMIT )); then
        echo -e "\033[2m# $((count - LIMIT)) more modified files\033[0m"
    fi
}

# Display the tree itself
stree_show_tree() {
    local DIR="$1"
    local DEPTH="$2"
    local SHOW_HIDDEN="$3"

    local CMD="tree -C -L $DEPTH --dirsfirst --noreport"
    [ "$SHOW_HIDDEN" = true ] && CMD="$CMD -a"

    $CMD "$DIR" | while IFS= read -r line; do
        # Match directory lines (ending with /)
        if [[ "$line" =~ (.*)[[:space:]]+([^[:space:]]+)/$ ]]; then
            local prefix="${BASH_REMATCH[1]}"
            local name="${BASH_REMATCH[2]}"
            local size
            size=$(stree_dir_size "$DIR/$name")
            printf "%s[%4s] %s/\n" "$prefix" "$size" "$name"
        else
            echo "$line"
        fi
    done
}

# Main super tree function
stree() {
    local DIR="${1:-.}"
    local SHOW_HIDDEN=false
    local DEPTH

    # Check for -a option
    if [[ "$1" == "-a" ]]; then
        SHOW_HIDDEN=true
        DIR="${2:-.}"
    fi

    # Calculate depth
    DEPTH=$(stree_get_depth "$DIR")

    # Git repo check
    stree_git_check "$DIR"

    # Recent files
    stree_recent_files "$DIR"

    # Show tree
    stree_show_tree "$DIR" "$DEPTH" "$SHOW_HIDDEN"
}

