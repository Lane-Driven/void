#!/usr/bin/env bash
# Void update utilities
# -----------------------------
source "$(dirname "${BASH_SOURCE[0]}")/../colors/colors.sh"

source "$(dirname "${BASH_SOURCE[0]}")/../notes/notes.sh"

# -----------------------------
# Show recent notes on welcome
# -----------------------------
welcome_recent_notes() {
    local COUNT=5   # Number of notes to display
    local NOTES_FILE="$NOTES_FILE" # from notes.sh

    [ -f "$NOTES_FILE" ] || return 0  # No notes file, skip

    local TOTAL_LINES
    TOTAL_LINES=$(wc -l < "$NOTES_FILE")
    (( TOTAL_LINES == 0 )) && return 0  # Empty file, skip

    echo -e "${COLOR_YELLOW}Recent notes:${COLOR_RESET}"
    tail -n "$COUNT" "$NOTES_FILE" | while IFS= read -r line; do
        local TS="${line%%]*}]"
        local CONTENT="${line#*] }"

        if [[ "$CONTENT" == !* ]]; then
            # Urgent note, highlight in red
            echo -e "${COLOR_BLUE}${TS}${COLOR_RESET} ${COLOR_RED}${CONTENT}${COLOR_RESET}"
        else
            echo -e "${COLOR_BLUE}${TS}${COLOR_RESET} ${COLOR_WHITE}${CONTENT}${COLOR_RESET}"
        fi
    done
}

# Path to update log
void_update_logfile() {
    echo "/var/log/void_update.log"
}

# Get last update epoch (seconds since 1970)
void_update_last_epoch() {
    local LOGFILE
    LOGFILE=$(void_update_logfile)

    if [ ! -f "$LOGFILE" ]; then
        echo 0  # never updated
        return
    fi

    date -d "$(cat "$LOGFILE")" +%s 2>/dev/null || echo 0
}

# Seconds since last update
void_update_seconds_since() {
    local last_epoch now_epoch diff
    last_epoch=$(void_update_last_epoch)
    now_epoch=$(date +%s)
    diff=$(( now_epoch - last_epoch ))
    echo "$diff"
}

# Human-readable last update
void_update_human() {
    local diff
    diff=$(void_update_seconds_since)

    if (( diff < 60 )); then
        echo "< 1 min"
    elif (( diff < 3600 )); then
        echo "< 1 hour"
    elif (( diff < 86400 )); then
        echo "< 1 day"
    elif (( diff < 604800 )); then
        echo "$(( diff / 86400 )) days ago"
    else
        echo "$(( diff / 604800 )) weeks ago"
    fi
}

# Prompt user if update is older than threshold (3 days)
prompt_update() {
    local diff
    diff=$(void_update_seconds_since)

    # 3 days = 259200 seconds
    if (( diff == 0 )); then
        echo -e "${COLOR_YELLOW}It looks like you haven't updated yet. Run \`update_void\`!${COLOR_RESET}"
    elif (( diff > 259200 )); then
        echo -e "${COLOR_YELLOW}It's been more than 3 days since last update. Consider running \`update_void\`!${COLOR_RESET}"
    fi
}

# -----------------------------
# Welcome screen
# -----------------------------
welcome_void() {
    local LAST_UPDATE_OUT
    LAST_UPDATE_OUT=$(void_update_human)

    # OS info
    local NAME ID KERNEL ARCH UPTIME
    NAME=$(grep ^PRETTY_NAME= /etc/os-release | cut -d= -f2 | tr -d '"')
    ID=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
    KERNEL=$(uname -r)
    ARCH=$(uname -m)
    UPTIME=$(uptime -p)

    echo -e "${COLOR_CYAN}=====================================${COLOR_RESET}"
    echo -e "${COLOR_GREEN}Welcome, ${COLOR_YELLOW}$USER${COLOR_GREEN}!"
    echo -e "${COLOR_MAGENTA}System: ${COLOR_CYAN}$NAME (${ID})"
    echo -e "${COLOR_MAGENTA}Kernel: ${COLOR_CYAN}$KERNEL [$ARCH]"
    echo -e "${COLOR_MAGENTA}Last update: ${COLOR_CYAN}$LAST_UPDATE_OUT"
    echo -e "${COLOR_MAGENTA}Uptime: ${COLOR_CYAN}$UPTIME"
    echo -e "${COLOR_MAGENTA}Current directory: ${COLOR_CYAN}$PWD"
    echo -e "${COLOR_CYAN}=====================================${COLOR_RESET}"
    
    welcome_recent_notes
    prompt_update
}

# Automatically call on login
welcome_void

