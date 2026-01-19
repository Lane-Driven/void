
echo "DEV: env/99_welcome.sh (loads last)"

# -----------------------------
# Show recent notes on welcome
# -----------------------------
welcome_recent_notes() {
    local COUNT=5   # Number of notes to display

    echo -e "${COLOR_YELLOW}Recent notes:${COLOR_RESET}"
    notes_list_last $COUNT  # ../notes/notes.sh
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

