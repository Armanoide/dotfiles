#!/bin/bash

# Load colors (assuming this file exists in the config directory)
source "$CONFIG_DIR/colors.sh"

ITEM_NAME="media"

# --- Fetch Media Information ---
# Check if the 'media-control' command and 'jq' are available
if ! command -v media-control &> /dev/null || ! command -v jq &> /dev/null; then
    # Fallback if tools are missing
    sketchybar --set "$ITEM_NAME" label="Tools Missing" icon=""
    exit 1
fi

JSON=$(media-control get)
PLAYING=$(echo "$JSON" | jq -r '.playing')
LABEL_WIDTH=150
STATUS_ICON=""

COLOR=$MAUVE
COLOR_ICON=$COLOR

title=$(echo "$JSON" | jq -r '.title')
artist=$(echo "$JSON" | jq -r '.artist')

# If paused 
if [[ "$PLAYING" == "false" ]]; then
  STATUS_ICON=":playing:"
fi

# If playing 
if [[ "$PLAYING" == "true" ]]; then
  STATUS_ICON=":paused:"
fi

# No media
if [[ "$title" == "null" ]]; then
    COLOR_ICON=$OVERLAY0
    LABEL_WIDTH="0"
fi


# Combine the full text
FULL_TEXT="$title ⋅ $artist"
# --- Scrolling Configuration ---
MAX_LEN=40  # Max characters to display at once
STEP_TIME=0.5 # Time (in seconds) between each scroll step (0.5 is good)

NBSP=" "

# Create a padding string of NBSP equal to MAX_LEN
# This padding ensures smooth looping in the scrolling text.
PADDING=""
for ((i=1; i<=$MAX_LEN; i++)); do
    PADDING="${PADDING}${NBSP}"
done

if [[ ${#FULL_TEXT} -le $MAX_LEN ]]; then
    # If the text is short, pad it to the max length with NBSP
    DISPLAY_TITLE="$FULL_TEXT"
    while [[ ${#DISPLAY_TITLE} -lt $MAX_LEN ]]; do
        DISPLAY_TITLE="$DISPLAY_TITLE$NBSP"
    done
else
    # Scrolling logic for long text
    SCROLL_TEXT="$FULL_TEXT$PADDING"
    LEN=${#SCROLL_TEXT}

    # Calculate the current index based on time and step
    CURRENT_TIME=$(date +%s.%N)
    INDEX=$(awk -v t="$CURRENT_TIME" -v s="$STEP_TIME" -v l="$LEN" \
        'BEGIN { printf("%d", int(t / s) % l) }')

    # Slice the text for scrolling, handling wrap-around
    if (( INDEX + MAX_LEN <= LEN )); then
        DISPLAY_TITLE="${SCROLL_TEXT:$INDEX:$MAX_LEN}"
    else
        # Handle wrap-around: slice from current index to end, then from beginning
        FIRST=$(( LEN - INDEX ))
        SECOND=$(( MAX_LEN - FIRST ))
        DISPLAY_TITLE="${SCROLL_TEXT:$INDEX:$FIRST}${SCROLL_TEXT:0:$SECOND}"
    fi
fi


sketchybar --set "$ITEM_NAME" \
    icon=":music: $STATUS_ICON" \
    label="$DISPLAY_TITLE" \
    label.font="SF Mono:Regular:15" \
    icon.color="$COLOR_ICON" \
    label.color="$COLOR" \
    background.color="$COLOR" \
    icon.font="sketchybar-app-font:Regular:20.0" \
    label.max_chars=$MAX_LEN \
    label.width=$LABEL_WIDTH
