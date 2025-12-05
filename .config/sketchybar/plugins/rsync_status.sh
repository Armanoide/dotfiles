#!/bin/bash

source "$CONFIG_DIR/colors.sh"

LOG_FILE="/tmp/rsync_sync_status.log"
ITEM_NAME="rsync_status"

PROGRESS_RATE=0
COLOR=$OVERLAY0
ICON="󰴋"
# Check if the process is still running
if pgrep -f "rsync -avhz" > /dev/null; then
  COLOR=$TEXT
    if [ -f "$LOG_FILE" ]; then

        # Get the status line containing the progress percentage
        PROGRESS=$(cat "$LOG_FILE"  | tail -n 1 |  rg -o "\d+%" | tail -n 1)
        if [[ "$PROGRESS" != "" ]]; then
            # Remove the '%' sign from the PROGRESS string to get a number 1-100
            PROGRESS_RATE=${PROGRESS%\%}
        fi
    fi
else
    # rsync process is not running. Check if a log file exists, meaning it just finished.
    if [ -f "$LOG_FILE" ]; then
        # Cleanup the log file and show success
        rm -f "$LOG_FILE"
        PROGRESS_RATE=0
        ICON="󱥿"
        COLOR=$GREEN
    fi
fi


sketchybar --set $ITEM_NAME icon="$ICON" \
  icon.font="MesloLGS Nerd Font Mono:Bold:25.0" \
  icon.padding_left=8 \
  icon.color=$COLOR \
  background.image="$CONFIG_DIR/assets/mauve/${PROGRESS_RATE}.png"
