#!/bin/bash

source "$CONFIG_DIR/colors.sh"

ITEM_NAME="airpods_left"

# Get Bluetooth info
BT_INFO=$(system_profiler SPBluetoothDataType 2>/dev/null)

# Extract battery values
LEVEL=$(echo "$BT_INFO" | grep "Left Battery Level" | awk '{print $NF}' | tr -d '%' | tr -cd '0-9')
INDICATOR_COLOR="green"

if [[ $LEVEL -le 15 ]]; then
  INDICATOR_COLOR="red"
elif [[ $LEVEL -le 35 ]]; then
  INDICATOR_COLOR="yellow"
else
  INDICATOR_COLOR="green"
fi

sketchybar --set "$ITEM_NAME" icon="ᖰ" \
  icon.y_offset=-2 \
  icon.padding_right=5 \
  background.image="$CONFIG_DIR/assets/$INDICATOR_COLOR/${LEVEL}.png"

