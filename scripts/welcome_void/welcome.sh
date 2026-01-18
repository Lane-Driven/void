# -----------------------------
# ~/.bashrc additions for a colorful welcome
# -----------------------------

# Function to get last update time
LAST_UPDATE() {
    local LOGFILE="/var/log/void_update.log"

    # If log file doesn't exist
    [ -f "$LOGFILE" ] || { echo "Never"; return; }

    local last_epoch
    last_epoch=$(date -d "$(cat "$LOGFILE")" +%s)
    local now_epoch
    now_epoch=$(date +%s)
    local diff=$(( now_epoch - last_epoch ))

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

# Function to prompt for update if more than 3 days
prompt_update() {
    local LOGFILE="/var/log/void_update.log"

    # If log doesn't exist, suggest update
    if [ ! -f "$LOGFILE" ]; then
        echo -e "\033[1;33mIt looks like you haven't updated yet. Run \`update_void\` to update!\033[0m"
        return
    fi

    local last_epoch
    last_epoch=$(date -d "$(cat "$LOGFILE")" +%s)
    local now_epoch
    now_epoch=$(date +%s)
    local diff=$(( now_epoch - last_epoch ))

    # Threshold: 3 days = 259200 seconds
    if (( diff > 259200 )); then
        echo -e "\033[1;33mIt's been more than 3 days since the last update. Consider running \`update_void\`!\033[0m"
    fi
}

# Welcome function
welcome_void() {
    local LAST_UPDATE_OUT
    LAST_UPDATE_OUT=$(LAST_UPDATE)

    # Colors
    local RED="\033[0;31m"
    local GREEN="\033[0;32m"
    local YELLOW="\033[0;33m"
    local BLUE="\033[0;34m"
    local MAGENTA="\033[0;35m"
    local CYAN="\033[0;36m"
    local RESET="\033[0m"

    # Read OS info
    local NAME
    NAME=$(grep ^PRETTY_NAME= /etc/os-release | cut -d= -f2 | tr -d '"')
    local ID
    ID=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')

    # System info
    local KERNEL ARCH UPTIME
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

    # Check for update
    prompt_update
}

# Automatically call on login
welcome_void

