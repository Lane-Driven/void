# ~/.bashrc additions for a colorful welcome

LAST_UPDATE() {
    local LOGFILE="/var/log/void_update.log"

    [ -f "$LOGFILE" ] || { echo "Never"; return; }

    local last_epoch
    last_epoch=$(date -d "$(cat "$LOGFILE")" +%s)

    local now_epoch
    now_epoch=$(date +%s)

    local diff=$(( now_epoch - last_epoch ))

    if [ $diff -lt 60 ]; then
        echo "< 1 min"
    elif [ $diff -lt 3600 ]; then
        echo "< 1 hour"
    elif [ $diff -lt 86400 ]; then
        echo "< 1 day"
    elif [ $diff -lt 604800 ]; then
        echo "$((diff / 86400)) days ago"
    else
        echo "$((diff / 604800)) weeks ago"
    fi
}

welcome_void() {
    local LAST_UPDATE_OUT=$(LAST_UPDATE)


    # Colors
    local RED="\033[0;31m"
    local GREEN="\033[0;32m"
    local YELLOW="\033[0;33m"
    local BLUE="\033[0;34m"
    local MAGENTA="\033[0;35m"
    local CYAN="\033[0;36m"
    local RESET="\033[0m"

    # Read OS info
    local NAME=$(grep ^PRETTY_NAME= /etc/os-release | cut -d= -f2 | tr -d '"')
    local ID=$(grep ^ID= /etc/os-release | cut -d= -f2 | tr -d '"')

    # System info
    local KERNEL=$(uname -r)
    local ARCH=$(uname -m)
    local UPTIME=$(uptime -p)

    echo -e "${CYAN}=====================================${RESET}"
    echo -e "${GREEN}Welcome, ${YELLOW}$USER${GREEN}!"
    echo -e "${MAGENTA}System: ${CYAN}$NAME (${ID})"
    echo -e "${MAGENTA}Kernel: ${CYAN}$KERNEL [$ARCH]"
    echo -e "${MAGENTA}Last update: ${CYAN}$LAST_UPDATE_OUT"
    echo -e "${MAGENTA}Uptime: ${CYAN}$UPTIME"
    echo -e "${MAGENTA}Current directory: ${CYAN}$PWD"
    echo -e "${CYAN}=====================================${RESET}"
}

# Call it automatically on login
welcome_void

