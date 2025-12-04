#!/bin/sh

source "$CONFIG_DIR/colors.sh"

ITEM_NAME="ram"

USAGE=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{print 100-$5}')
# df -H | grep -E '^(/dev/disk3s5).' | awk '{ printf ("%s\n", $5) }'
sketchybar --set "$ITEM_NAME" \
  icon=":ram:" \
  icon.font="sketchybar-app-font:Regular:17.0" \
  icon.y_offset=-2 \
  background.image="$CONFIG_DIR/assets/mauve/${USAGE}.png"

