# -----------------------------
# Void update utilities
# -----------------------------

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
        echo -e "\033[1;33mIt looks like you haven't updated yet. Run \`update_void\`!\033[0m"
    elif (( diff > 259200 )); then
        echo -e "\033[1;33mIt's been more than 3 days since last update. Consider running \`update_void\`!\033[0m"
    fi
}

# -----------------------------
# Welcome screen
# -----------------------------
welcome_void() {
    local LAST_UPDATE_OUT
    LAST_UPDATE_OUT=$(void_update_human)

    # Colors
    local RED="\033[0;31m"
    local GREEN="\033[0;32m"
    local YELLOW="\033[0;33m"
    local BLUE="\033[0;34m"
    local MAGENTA="\033[0;35m"
    local CYAN="\033[0;36m"
    local RESET="\033[0m"

    # OS info
    local NAME ID KERNEL ARCH UPTIME
    NAME=$(grep ^PRETTY_NAME= /etc/os-release | cut -d= -f2 | tr -d '"')
    ID=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')
    KERNEL=$(uname -r)
    ARCH=$(uname -m)
    UPTIME=$(uptime -p)

    echo -e "${CYAN}=====================================${RESET}"
    echo -e "${GREEN}Welcome, ${YELLOW}$USER${GREEN}!"
    echo -e "${MAGENTA}System: ${CYAN}$NAME (${ID})"
    echo -e "${MAGENTA}Kernel: ${CYAN}$KERNEL [$ARCH]"
    echo -e "${MAGENTA}Last update: ${CYAN}$LAST_UPDATE_OUT"
    echo -e "${MAGENTA}Uptime: ${CYAN}$UPTIME"
    echo -e "${MAGENTA}Current directory: ${CYAN}$PWD"
    echo -e "${CYAN}=====================================${RESET}"

    prompt_update
}

# Automatically call on login
welcome_void

