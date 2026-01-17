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

    # Combine ignore pattern into find exclusion
    local IGNORE_PATTERN=".git|node_modules|dist"

    # Find recent files while ignoring patterns
    local files=()
    while IFS= read -r f; do
        files+=("$f")
    done < <(find "$DIR" -type f -mtime -"$DAYS" ! -path "*/.git/*" ! -path "*/node_modules/*" ! -path "*/dist/*" 2>/dev/null | sort)

    local count=${#files[@]}
    (( count == 0 )) && return

    echo -e "\033[1;33mRecent files (last $DAYS days):\033[0m"
    for ((i=0; i<count && i<LIMIT; i++)); do
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

    if [ "$SHOW_HIDDEN" = true ]; then
        tree -C -L "$DEPTH" --dirsfirst --noreport -a "$DIR"
    else
        tree -C -L "$DEPTH" --dirsfirst --noreport "$DIR"
    fi | while IFS= read -r line; do
        # directory lines ending with /
        if [[ "$line" =~ ^(\[.*\][[:space:]]+)(.+)/$ ]]; then
            local prefix="${BASH_REMATCH[1]}"
            local name="${BASH_REMATCH[2]}"
            local size
            size=$(stree_dir_size "$DIR/$name")
            local display
            display=$(stree_display_path "$DIR/$name")
            printf "%s[%4s] %s/\n" "$prefix" "$size" "$display"
        # file lines
        elif [[ -f "$line" ]]; then
            ls -lh --color=auto "$line"
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

streeh() {
    local DIR="${1:-.}"
    local DEPTH
    DEPTH=$(stree_get_depth "$DIR")
    
    stree_git_check "$DIR"
    stree_recent_files "$DIR"
    stree_show_tree "$DIR" "$DEPTH" true  # true = show hidden
}
