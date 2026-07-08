#!/bin/bash

# Load environment variables
source "$HOME/.zshrc_secret"

# 1. READ REQUIRED PARAMETER
DIRECTION=$1
LOG_FILE="/tmp/rsync_sync_status.log"
RSYNC_BINARY="/opt/homebrew/bin/rsync"

# --- DETERMINE PATHS BASED ON DIRECTION ---
case "$DIRECTION" in
    push)
        SYNC_PATHS=$RSYNC_PUSH_PATHS
        ;;
    pull)
        SYNC_PATHS=$RSYNC_PULL_PATHS
        ;;
    *)
        # Default action if no valid argument is provided
        osascript -e 'display dialog "ERROR: Sync requires argument: push or pull." with title "Sync Failed"'
        exit 1
        ;;
esac

# Construct the final rsync command with the chosen paths
RSYNC_COMMAND="$RSYNC_BINARY -avhz --info=progress2 $SYNC_PATHS"

# ---------------------
# 2. Execution and Logging

# Clean up any previous log file
# rm -f "$LOG_FILE"

# Start rsync in the background and log its output
# We pass the full command string to nohup/bash -c
nohup bash -c "$RSYNC_COMMAND 2>&1 | tee $LOG_FILE" > /dev/null &

