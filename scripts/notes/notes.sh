#!/usr/bin/env bash
# -----------------------------
# Colorized Terminal Notes
# -----------------------------

NOTES_DIR="$HOME/notes"
NOTES_FILE="$NOTES_DIR/notes.txt"

# Ensure the notes directory exists
mkdir -p "$NOTES_DIR"
touch "$NOTES_FILE"

# Colors
COLOR_RESET="\033[0m"
COLOR_TIMESTAMP="\033[1;34m"   # bright blue
COLOR_NOTE="\033[1;37m"        # white
COLOR_HIGHLIGHT="\033[1;33m"   # yellow

# Add a new note
notes_add() {
    local NOTE="$*"
    if [[ -z "$NOTE" ]]; then
        echo -e "${COLOR_HIGHLIGHT}Usage: notes add \"Your note here\"${COLOR_RESET}"
        return 1
    fi
    local TIMESTAMP
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$TIMESTAMP] $NOTE" >> "$NOTES_FILE"
    echo -e "${COLOR_HIGHLIGHT}Note added!${COLOR_RESET}"
}

# List recent notes
notes_list() {
    local COUNT="${1:-10}"  # Default to last 10 notes
    echo -e "${COLOR_HIGHLIGHT}Last $COUNT notes:${COLOR_RESET}"
    tail -n "$COUNT" "$NOTES_FILE" | while IFS= read -r line; do
        # Split timestamp and note content
        local TS="${line%%]*}]"
        local CONTENT="${line#*] }"

        # Set base color based on urgency
        local NOTE_COLOR="$COLOR_NOTE"
        [[ "$CONTENT" == \!* ]] && NOTE_COLOR="\033[1;31m"  # Red for urgent notes

        echo -e "${COLOR_TIMESTAMP}${TS}${COLOR_RESET} ${NOTE_COLOR}${CONTENT}${COLOR_RESET}"
    done
}

# Search notes
notes_search() {
    local QUERY="$*"
    if [[ -z "$QUERY" ]]; then
        echo -e "${COLOR_HIGHLIGHT}Usage: notes search \"keyword\"${COLOR_RESET}"
        return 1
    fi

    while IFS= read -r line; do
        local TS="${line%%]*}]"
        local CONTENT="${line#*] }"

        # Use perl for case-insensitive highlight without repeating
        local HIGHLIGHTED_CONTENT
        HIGHLIGHTED_CONTENT=$(echo "$CONTENT" | perl -pe "s/($QUERY)/${COLOR_HIGHLIGHT}\$1${COLOR_NOTE}/ig")

        echo -e "${COLOR_TIMESTAMP}${TS}${COLOR_RESET} ${COLOR_NOTE}${HIGHLIGHTED_CONTENT}${COLOR_RESET}"
    done < <(grep -i "$QUERY" "$NOTES_FILE")
}


# Command dispatcher
notes() {
    local CMD="$1"
    shift
    case "$CMD" in
        add) notes_add "$@" ;;
        list) notes_list "$@" ;;
        search) notes_search "$@" ;;
        *) echo -e "${COLOR_HIGHLIGHT}Usage: notes {add|list|search} [args]${COLOR_RESET}" ;;
    esac
}

