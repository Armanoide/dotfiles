#!/bin/bash

source "$CONFIG_DIR/colors.sh"

ITEM_NAME="airpods_case"

# Get Bluetooth info
BT_INFO=$(system_profiler SPBluetoothDataType 2>/dev/null)

# Extract battery values
LEVEL=$(echo "$BT_INFO" | grep "Case Battery Level" | awk '{print $NF}' | tr -d '%' | tr -cd '0-9')
INDICATOR_COLOR="green"

if [[ $LEVEL -le 15 ]]; then
  INDICATOR_COLOR="red"
elif [[ $LEVEL -le 35 ]]; then
  INDICATOR_COLOR="yellow"
else
  INDICATOR_COLOR="green"
fi

sketchybar --set "$ITEM_NAME" icon=":airpods_case:" \
  icon.font="sketchybar-app-font:Regular:19.0" \
  icon.y_offset=-2 \
  icon.padding_right=1 \
  background.image="$CONFIG_DIR/assets/$INDICATOR_COLOR/${LEVEL}.png"

