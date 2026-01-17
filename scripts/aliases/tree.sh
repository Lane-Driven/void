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

# Get directory size in human-readable format
stree_dir_size() {
    du -sh "$1" 2>/dev/null | cut -f1
}

# Smart tree depth based on top-level item count
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

# Detect Git repository
stree_git_check() {
    local DIR="$1"
    [ -d "$DIR/.git" ] && echo -e "\033[1;34mGit repository detected in $DIR\033[0m"
}

# List recent files (modified in last N days)
stree_recent_files() {
    local DIR="${1:-.}"
    local DAYS="${2:-2}"
    local LIMIT=5

    local files=()
    while IFS= read -r f; do
        files+=("$f")
    done < <(find "$DIR" -type f -mtime -"$DAYS" \
        ! -path "*/.git/*" \
        ! -path "*/node_modules/*" \
        ! -path "*/dist/*" 2>/dev/null | sort)

    (( ${#files[@]} == 0 )) && return

    echo -e "\033[1;33mRecent files (last $DAYS days):\033[0m"
    for ((i=0; i<${#files[@]} && i<LIMIT; i++)); do
        local file_display
        file_display=$(stree_display_path "${files[i]}")
        ls -lh --color=auto "${files[i]}" | sed "s|${files[i]}|$file_display|"
    done

    if (( ${#files[@]} > LIMIT )); then
        echo -e "\033[2m# $(( ${#files[@]} - LIMIT )) more modified files\033[0m"
    fi
}

# Display the tree itself
stree_show_tree() {
    local DIR="$1"
    local DEPTH="$2"
    local SHOW_HIDDEN="$3"

    local TREE_OPTS="--dirsfirst --noreport -L $DEPTH -I '.git'"
    [ "$SHOW_HIDDEN" = true ] && TREE_OPTS="$TREE_OPTS -a"

    tree -C $TREE_OPTS "$DIR" | while IFS= read -r line; do
        local line_clean
        line_clean=$(echo "$line" | sed 's/\x1B\[[0-9;]*[JKmsu]//g')

        # Directory lines
        if [[ "$line_clean" =~ ^(\[.*\][[:space:]]+)(.+)/$ ]]; then
            local prefix="${BASH_REMATCH[1]}"
            local name="${BASH_REMATCH[2]}"
            local size
            size=$(du -sh "$DIR/$name" 2>/dev/null | cut -f1)
            local display
            display=$(stree_display_path "$DIR/$name")
            printf "%s[%4s] %s/\n" "$prefix" "$size" "$display"
        else
            # Print files and tree lines as-is
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

    [ "$1" == "-a" ] && { SHOW_HIDDEN=true; DIR="${2:-.}"; }

    DEPTH=$(stree_get_depth "$DIR")
    stree_git_check "$DIR"
    stree_recent_files "$DIR"
    stree_show_tree "$DIR" "$DEPTH" "$SHOW_HIDDEN"
}

streeh() {
    local DIR="${1:-.}"
    local DEPTH
    DEPTH=$(stree_get_depth "$DIR")

    stree_git_check "$DIR"
    stree_recent_files "$DIR"
    stree_show_tree "$DIR" "$DEPTH" true
}

