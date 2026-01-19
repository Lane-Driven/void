
echo "DEV: env/03_update.sh (update_void)"

update_void() {
    local LOGDIR="/var/log"
    local LOGFILE="$LOGDIR/void_update.log"

    echo "Updating Void Linux packages..."
    sudo xbps-install -Su

    # Log the timestamp
    sudo bash -c "date '+%Y-%m-%d %H:%M:%S' > '$LOGFILE'"
    echo "Update complete!"
}
