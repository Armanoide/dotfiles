#!/bin/bash

ITEM_NAME="network_ping"

# Get the ping target from .zshrc using ripgrep
TARGET=$(rg 'PING_REMOTE_WORK_TARGET' "$HOME/.zshrc_secret" | rg -o '\d+\.\d+\.\d+\.\d+' | head -n1)

# Perform a single ping with a short timeout
PING_OUTPUT=$(ping -c 1 -W 300 "$TARGET" 2>/dev/null)

# Extract ms latency
LATENCY=$(echo "$PING_OUTPUT" | grep "time=" | awk -F"time=" '{print $2}' | awk '{print $1}')
INDICATOR_COLOR="red"

# Default if ping failed
if [[ -z "$LATENCY" ]]; then
    INDICATOR_COLOR="red"
    LATENCY_PERCENT=100
else
    LAT=${LATENCY%.*}  # integer part

    # Map latency to color
    if (( LAT < 25 )); then
        INDICATOR_COLOR="green"
    elif (( LAT < 50 )); then
        INDICATOR_COLOR="yellow"
    else
        INDICATOR_COLOR="red"
    fi

    # Map latency to 1–100 scale
    MAX_LATENCY=100
    LATENCY_PERCENT=$(( LAT * 100 / MAX_LATENCY ))
    if (( LATENCY_PERCENT > 100 )); then
        LATENCY_PERCENT=100
    elif (( LATENCY_PERCENT < 1 )); then
        LATENCY_PERCENT=1
    fi
fi

# Update SketchyBar
sketchybar --set "$ITEM_NAME" \
    icon="" \
    icon.font="MesloLGS Nerd Font Mono:Bold:25.0" \
    icon.padding_left=8 \
    background.image="$CONFIG_DIR/assets/$INDICATOR_COLOR/${LATENCY_PERCENT}.png"


