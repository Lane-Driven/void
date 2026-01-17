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

# Display the tree itself, now accepting extra tree options
stree_show_tree() {
    local DIR="$1"
    shift
    local TREE_OPTS=("$@")   # All remaining args are tree flags

    # Always dirs first, no report
    TREE_OPTS=("--dirsfirst" "--noreport" "${TREE_OPTS[@]}")

    # Run tree with colors and options
    tree -C "${TREE_OPTS[@]}" "$DIR" | while IFS= read -r line; do
        # Check for directory lines like [size] name/
        if [[ "$line" =~ ^(\[.*\][[:space:]]+)(.+)/$ ]]; then
            local prefix="${BASH_REMATCH[1]}"
            local name="${BASH_REMATCH[2]}"
            local size
            size=$(du -sh "$DIR/$name" 2>/dev/null | cut -f1)
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
    shift   # shift past DIR if provided

    local DEPTH
    DEPTH=$(stree_get_depth "$DIR")

    stree_git_check "$DIR"
    stree_recent_files "$DIR"

    # Pass -a (show hidden), -I '.git', and max depth
    stree_show_tree "$DIR" "-a" "-I" ".git" "-L" "$DEPTH" "$@"
}
