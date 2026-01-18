#!/bin/sh
# -----------------------------
# Modular Super Tree Function
# -----------------------------
#source "$(dirname "${BASH_SOURCE[0]}")/../colors/colors.sh"
. "$SCRIPTS_DIR/colors/colors.sh"
# Convert absolute paths to display-friendly (replace $HOME with ~)
stree_display_path() {
    STREE_PATH="$1"

    case $STREE_PATH in
        "$HOME"/*)
            printf '~%s\n' "${STREE_PATH#"$HOME"}"
            ;;
        *)
            printf '%s\n' "$STREE_PATH"
            ;;
    esac
}

# -----------------------------
# Display a single directory with size
# -----------------------------
stree_dir_display() {
    PARENT="$1"
    NAME="$2"   # directory name
    INDENT="$3" # leading spaces for tree alignment

    FULLPATH="$PARENT/$NAME"
    SIZE='?'

    if [ -e "$FULLPATH" ]; then
        if du -h . >/dev/null 2>&1; then
            SIZE=$(du -sh "$FULLPATH" 2>/dev/null | awk '{print $1}')
        else
            SIZE=$(du -s "$FULLPATH" 2>/dev/null | awk '{print $1}')
        fi
    fi

    printf "%s[%4s] %s/\n" "$INDENT" "$SIZE" "$NAME"
}

# Centralized size calculation for files and directories
stree_dir_size() {
    path=$1

    if [ -f "$path" ] || [ -d "$path" ]; then
        du "$path" 2>/dev/null | awk '{ print $1 }'
    else
        printf "%s\n" "?"
    fi
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
    [ -d "$DIR/.git" ] && echo -e "${COLOR_BLUE}Git repository detected in $DIR${COLOR_RESET}"
}

# -----------------------------
# Recent files modular functions
# -----------------------------
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

stree_display_recent_file() {
    local FILE="$1"
    local DISPLAY SIZE
    DISPLAY=$(stree_display_path "$FILE")
    SIZE=$(stree_dir_size "$FILE")
    printf "[%4s] %s\n" "$SIZE" "$DISPLAY"
}

stree_recent_files() {
    local DIR="${1:-.}"
    local DAYS="${2:-2}"
    local SHOW_HIDDEN="${3:-false}"
    local LIMIT=5
    local COUNT=0

    echo -e "${COLOR_YELLOW}Recent files (last $DAYS days):${COLOR_RESET}"

    # Use process substitution to avoid subshell issues
    while IFS= read -r file; do
        ((COUNT++))
        ((COUNT <= LIMIT)) && stree_display_recent_file "$file"
    done < <(stree_find_recent_files "$DIR" "$DAYS" "$SHOW_HIDDEN")

    (( COUNT > LIMIT )) && echo -e "${COLOR_DIM}# $(( COUNT - LIMIT )) more modified files${COLOR_RESET}"
}

# -----------------------------
# Tree options
# -----------------------------
stree_tree_opts() {
    local DEPTH="$1"
    local SHOW_HIDDEN="$2"

    DEPTH=$(( DEPTH < 1 ? 1 : DEPTH ))
    local OPTS="--dirsfirst --noreport -L $DEPTH"

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
            size=$(stree_dir_size "$DIR/$name")
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
    stree_recent_files "$DIR" 2 "$SHOW_HIDDEN"
    stree_show_tree "$DIR" "$DEPTH" "$SHOW_HIDDEN"
}

streeh() {
    local DIR="${1:-.}"
    local DEPTH
    DEPTH=$(stree_get_depth "$DIR")

    stree_git_check "$DIR"
    stree_recent_files "$DIR" 2 true     # always show hidden
    stree_show_tree "$DIR" "$DEPTH" true # always show hidden, .git ignored
}

