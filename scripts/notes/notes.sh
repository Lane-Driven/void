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

notes_count() {
    [ -f "$NOTES_FILE" ] || { echo 0; return; }
    grep -c . "$NOTES_FILE"
}

notes_strip_timestamp() {
    awk '{ sub(/^\[[^}}*\] /, ""); print }'
}

notes_count_by_prefix() {
    local PREFIX="$1"

    [ -f "$NOTES_FILE" ] || { echo 0; return; }

    awk -v prefix="$PREFIX" '
    {
        # Extract content after the timestamp
        match($0, /\] (.*)/, arr)
        content = arr[1]
        gsub(/^[ \t]+/, "", content)

        # Match only if content starts exactly with prefix
        # Ensure the next character isn’t another prefix char (! ? + ~ @ -)
        if (content ~ "^" prefix "([^!?+~@-]|$)") count++
    }
    END { print count+0 }' "$NOTES_FILE"
}

# Map prefixes to colors
notes_get_color() {
    NOTE="$1"

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
    NOTE="$*"
    if [ -z "$NOTE" ]; then
        printf "${COLOR_YELLOW}Usage: notes add 'Your note here'${COLOR_RESET}\n"
        return 1
    fi
    local TIMESTAMP
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$TIMESTAMP] $NOTE" >> "$NOTES_FILE"
    printf "${COLOR_YELLOW}Note added!${COLOR_RESET}\n"
}

# List notes
notes_list() {
    COUNT="${1:-10}"
    SHOW_HEADER="${2:-true}"

    NOTE_COUNT=$(notes_count)

    # No notes is NOT an error
    if [ "$NOTE_COUNT" -eq 0 ]; then
        printf "${COLOR_YELLOW}%s${COLOR_RESET}\n" "No notes to display."
        return 0
    fi

    # Invalid count cases ARE errors
    if [ "$COUNT" -eq 0 ]; then
        echo "${COLOR_YELLOW}Count must be at least 1.${COLOR_RESET}\n"
        return 1
    fi

    if [ "$COUNT" -lt 0 ]; then
        printf "${COLOR_YELLOW}Count cannot be negative.${COLOR_RESET}\n"
        return 1
    fi

    # Clamp COUNT to NOTE_COUNT
    if [ "$COUNT" -gt "$NOTE_COUNT" ]; then
        COUNT="$NOTE_COUNT"
    fi

    # Optional header (useful for welcome screen)
    if [ "$SHOW_HEADER" = true ]; then
        printf "${COLOR_YELLOW}Last $COUNT notes:${COLOR_RESET}\n"
    fi

    tail -n "$COUNT" "$NOTES_FILE" | while IFS= read -r line; do
        TS="${line%%]*}]"
        CONTENT="${line#*] }"
        COLOR=$(notes_get_color "$CONTENT")

        printf "${COLOR_BLUE}${TS}${COLOR_RESET} ${COLOR}${CONTENT}${COLOR_RESET}\n"
    done

    return 0
}

notes_list_last() {
    local COUNT="${1:-5}"
    notes_list "$COUNT" false
}

# Search notes
notes_search() {
    QUERY="$*"
    if [ -z "$QUERY" ]; then
        printf "${COLOR_YELLOW}Usage: notes search 'keyword'${COLOR_RESET}"
        return 1
    fi

    grep -i --color=always "$QUERY" "$NOTES_FILE" | while IFS= read -r line; do
        TS="${line%%]*}]"
        CONTENT="${line#*] }"
        COLOR=$(notes_get_color "$CONTENT")
        # Highlight search term
        HIGHLIGHTED
        HIGHLIGHTED=$(printf '%s\n' "$CONTENT" | awk -v q="$QUERY" '
        {
            IGNORECASE = 1
            gsub(q, "\033[1;33m&\033[0m")
            print
        }')
        HIGHLIGHTED=$(echo "$CONTENT" | perl -pe "s/($QUERY)/\e[1;33m\$1\e[0m/ig")
        printf "${TS} ${HIGHLIGHTED}${COLOR_RESET}"
    done
}

# Help
notes_help() {
    printf "${COLOR_YELLOW}%s${COLOR_RESET}\n" "Usage: notes {add|list|search|help|clear} [args]\n\n"

    printf "${COLOR_YELLOW}Notes prefixes and meaning:${COLOR_RESET}\n"
    printf "${COLOR_RED}!\t${COLOR_WHITE}Urgent / High Priority\n"
    printf "${COLOR_BRIGHT_RED}!!\t${COLOR_WHITE}Critical / Immediate Action\n"
    printf "${COLOR_YELLOW}!?\t${COLOR_WHITE}Question / Follow-up needed\n"
    printf "${COLOR_CYAN}!@\t${COLOR_WHITE}Reminder / Scheduled task\n"
    printf "${COLOR_GREEN}!+\t${COLOR_WHITE}Idea / Enhancement\n"
    printf "${COLOR_MAGENTA}!- \t${COLOR_WHITE}Bug / Issue\n"
    printf "${COLOR_BLUE}!~\t${COLOR_WHITE}WIP / Work in progress\n"
}

# Clear all notes, optionally with force
notes_clear() {
    FORCE=false

    # Check for -f flag
    if [ "$1" = "-f" ]; then
        FORCE=true
    fi

    if [ ! -f "$NOTES_FILE" ]; then
        printf "Notes file does not exist.\n"
        return 1
    fi

    if [ "$FORCE" = false ]; then
        # Confirm with the user
        printf "Are you sure you want to delete ALL notes? [y/N] "
        read -r CONFIRM
        case "$CONFIRM" in
            [yY]|[yY][eE][sS]) ;;
            *) 
                printf "Aborted. No notes were deleted.\n"
                return 1
                ;;
        esac
    fi

    # Clear the notes file
    : > "$NOTES_FILE"
    printf "${COLOR_YELLOW}%s\n${COLOR_RESET}" "All notes have been deleted."
}

# Command dispatcher - POSIX compliant
notes() {
    CMD="$1"
    shift

    # No arguments: open editor for a new note
    if [ -z "$CMD" ]; then
        printf "${COLOR_YELLOW}%s${COLOR_RESET}\n" "Notes file location: $NOTES_FILE"
        printf "Would you like to create a new note? [y/N] "
        read -r CONFIRM
        case "$CONFIRM" in
            [yY]*) 
                ;;
            *)
                printf "DEGUG: ${CONFIRM}\n"
                printf "%s\n" "Usage: notes {add|list|search|help|clear} [args]"
                return 1
                ;;
        esac

        printf "${COLOR_YELLOW}%s${COLOR_RESET}\n" "Opening editor to add a new note..."

        # Use $EDITOR or fallback to vim
        EDITOR_CMD="${EDITOR:-vim}"

        # Temporary file
        TMPFILE="/tmp/notes.$$"

        # Open editor
        "$EDITOR_CMD" "$TMPFILE"

        # Add note if file is non-empty
        if [ -s "$TMPFILE" ]; then
            NOTE=$(cat "$TMPFILE")
            notes_add "$NOTE"
        else
            printf "${COLOR_YELLOW}%s${COLOR_RESET}\n" "No note added."
        fi

        # Clean up
        rm -f "$TMPFILE"
        return 0
    fi

    case "$CMD" in
        add)
            notes_add "$@"
            ;;
        list)
            notes_list "$@"
            ;;
        search)
            notes_search "$@"
            ;;
        help)
            notes_help
            ;;
        clear)
            notes_clear "$@"
            ;;
        *)
            notes_help
            ;;
    esac
}
