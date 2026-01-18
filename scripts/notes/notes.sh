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
COLOR_TIMESTAMP="\033[1;34m"   # bright blue for timestamp
COLOR_DEFAULT="\033[1;37m"     # white for normal notes

# Note type prefixes and colors
declare -A NOTE_TYPES=(
    ["!"]="\033[1;31m"   # Urgent / Red
    ["!!"]="\033[1;91m"  # Critical / Bright Red
    ["!?"]="\033[1;33m"  # Question / Yellow
    ["!@"]="\033[1;36m"  # Reminder / Cyan
    ["!+"]="\033[1;32m"  # Idea / Green
    ["!-"]="\033[1;35m"  # Bug / Magenta
    ["!~"]="\033[1;34m"  # WIP / Blue
)

NOTE_MEANINGS=(
    "! : Urgent / High Priority"
    "!! : Critical / Immediate Action"
    "!? : Question / Follow-up needed"
    "!@ : Reminder / Scheduled task"
    "!+ : Idea / Enhancement"
    "!– : Bug / Issue"
    "!~ : Work in Progress"
)

# -----------------------------
# Helper: Determine note color
# -----------------------------
notes_colorize() {
    local NOTE="$1"
    local PREFIX
    local CONTENT="$NOTE"
    local COLOR="$COLOR_DEFAULT"

    # Check for multi-character prefixes first
    for key in "${!NOTE_TYPES[@]}"; do
        if [[ "$NOTE" == "$key"* ]]; then
            PREFIX="$key"
            CONTENT="${NOTE#"$key"}"
            COLOR="${NOTE_TYPES[$key]}"
            break
        fi
    done

    echo -e "${COLOR}${CONTENT}${COLOR_RESET}"
}

# -----------------------------
# Add a new note
# -----------------------------
notes_add() {
    local NOTE="$*"
    if [[ -z "$NOTE" ]]; then
        echo -e "\033[1;33mUsage: notes add \"!Note content\"${COLOR_RESET}"
        return 1
    fi
    local TIMESTAMP
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$TIMESTAMP] $NOTE" >> "$NOTES_FILE"
    echo -e "\033[1;33mNote added!${COLOR_RESET}"
}

# -----------------------------
# List recent notes
# -----------------------------
notes_list() {
    local COUNT="${1:-10}"
    echo -e "\033[1;33mLast $COUNT notes:${COLOR_RESET}"
    tail -n "$COUNT" "$NOTES_FILE" | while IFS= read -r line; do
        local TS="${line%%]*}]"
        local CONTENT="${line#*] }"
        echo -e "${COLOR_TIMESTAMP}${TS}${COLOR_RESET} $(notes_colorize "$CONTENT")"
    done
}

# -----------------------------
# Search notes
# -----------------------------
notes_search() {
    local QUERY="$*"
    if [[ -z "$QUERY" ]]; then
        echo -e "\033[1;33mUsage: notes search \"keyword\"${COLOR_RESET}"
        return 1
    fi
    grep -i --color=always "$QUERY" "$NOTES_FILE" | while IFS= read -r line; do
        local TS="${line%%]*}]"
        local CONTENT="${line#*] }"
        # Highlight search term within the note content
        local HIGHLIGHTED_CONTENT
        HIGHLIGHTED_CONTENT=$(echo "$CONTENT" | sed "s/$QUERY/\033[1;93m&\033[0m/Ig")
        echo -e "${COLOR_TIMESTAMP}${TS}${COLOR_RESET} $(notes_colorize "$HIGHLIGHTED_CONTENT")"
    done
}

# -----------------------------
# Display note type help
# -----------------------------
notes_help() {
    echo -e "\033[1;33mNote Types:\033[0m"
    for entry in "${NOTE_MEANINGS[@]}"; do
        # Extract prefix
        PREFIX="${entry%%:*}"
        echo -e "${NOTE_TYPES[$PREFIX]}$entry${COLOR_RESET}"
    done
}

# -----------------------------
# Command dispatcher
# -----------------------------
notes() {
    local CMD="$1"
    shift
    case "$CMD" in
        add) notes_add "$@" ;;
        list) notes_list "$@" ;;
        search) notes_search "$@" ;;
        help) notes_help ;;
        *) echo -e "\033[1;33mUsage: notes {add|list|search|help} [args]${COLOR_RESET}" ;;
    esac
}

