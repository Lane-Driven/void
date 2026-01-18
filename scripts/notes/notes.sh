#!/usr/bin/env bash
# -----------------------------
# Colorized Terminal Notes
# -----------------------------

NOTES_DIR="$HOME/notes"
NOTES_FILE="$NOTES_DIR/notes.txt"

mkdir -p "$NOTES_DIR"
touch "$NOTES_FILE"

# Source shared colors
source "$(dirname "${BASH_SOURCE[0]}")/../colors/colors.sh"

# Map prefixes to colors
notes_get_color() {
    local NOTE="$1"

    case "$NOTE" in
        "!!"*) echo "$COLOR_BRIGHT_RED" ;;
        "!?"*)  echo "$COLOR_YELLOW" ;;
        "!@"*) echo "$COLOR_CYAN" ;;
        "!+"*) echo "$COLOR_GREEN" ;;
        "!-"*) echo "$COLOR_MAGENTA" ;;
        "!~"*) echo "$COLOR_BLUE" ;;
        "!"*) echo "$COLOR_RED" ;;
        *)    echo "$COLOR_WHITE" ;;
    esac
}

# Add a new note
notes_add() {
    local NOTE="$*"
    if [[ -z "$NOTE" ]]; then
        echo -e "${COLOR_YELLOW}Usage: notes add \"Your note here\"${COLOR_RESET}"
        return 1
    fi
    local TIMESTAMP
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$TIMESTAMP] $NOTE" >> "$NOTES_FILE"
    echo -e "${COLOR_YELLOW}Note added!${COLOR_RESET}"
}

# List notes
notes_list() {
    local COUNT="${1:-10}"

    # Decide to show header or not.  Useful if auto loading notes like
    # from a welcome screen.
    local SHOW_HEADER="${2:-true}"
    if [[ "$SHOW_HEADER" == true ]]; then
        echo -e "${COLOR_YELLOW}Last $COUNT notes:${COLOR_RESET}"
    fi

    tail -n "$COUNT" "$NOTES_FILE" | while IFS= read -r line; do
        local TS="${line%%]*}]"
        local CONTENT="${line#*] }"
        local COLOR=$(notes_get_color "$CONTENT")
        echo ${COLOR}

        echo -e "${COLOR_BLUE}${TS}${COLOR_BLUE} ${COLOR}${CONTENT}${COLOR_RESET}"
    done
}

notes_list_last() {
    local COUNT="${1:-5}"
    notes_list "$COUNT" false
}

# Search notes
notes_search() {
    local QUERY="$*"
    if [[ -z "$QUERY" ]]; then
        echo -e "${COLOR_YELLOW}Usage: notes search \"keyword\"${COLOR_RESET}"
        return 1
    fi

    grep -i --color=always "$QUERY" "$NOTES_FILE" | while IFS= read -r line; do
        local TS="${line%%]*}]"
        local CONTENT="${line#*] }"
        local COLOR=$(notes_get_color "$CONTENT")
        # Highlight search term
        local HIGHLIGHTED
        HIGHLIGHTED=$(echo "$CONTENT" | perl -pe "s/($QUERY)/\e[1;33m\$1\e[0m/ig")
        echo -e "${TS} ${HIGHLIGHTED}${COLOR_RESET}"
    done
}

# Help
notes_help() {
    echo -e "${COLOR_YELLOW}Notes prefixes and meaning:${COLOR_RESET}"
    echo -e "${COLOR_RED}!\t${COLOR_WHITE}Urgent / High Priority"
    echo -e "${COLOR_BRIGHT_RED}!!\t${COLOR_WHITE}Critical / Immediate Action"
    echo -e "${COLOR_YELLOW}!?\t${COLOR_WHITE}Question / Follow-up needed"
    echo -e "${COLOR_CYAN}!@\t${COLOR_WHITE}Reminder / Scheduled task"
    echo -e "${COLOR_GREEN}!+\t${COLOR_WHITE}Idea / Enhancement"
    echo -e "${COLOR_MAGENTA}!- \t${COLOR_WHITE}Bug / Issue"
    echo -e "${COLOR_BLUE}!~\t${COLOR_WHITE}WIP / Work in progress"
}

# Command dispatcher
notes() {
    local CMD="$1"
    shift
    case "$CMD" in
        add)    notes_add "$@" ;;
        list)   notes_list "$@" ;;
        search) notes_search "$@" ;;
        help)   notes_help ;;
        *)      echo -e "${COLOR_YELLOW}Usage: notes {add|list|search|help} [args]${COLOR_RESET}" ;;
    esac
}
