#!/bin/sh

source "$CONFIG_DIR/colors.sh"

ITEM_NAME="disk"

USAGE=$(memory_pressure | grep "System-wide memory free percentage:" | awk '{print 100-$5}')

sketchybar --set "$ITEM_NAME" \
  icon="" \
  icon.font="MesloLGS Nerd Font Mono:Bold:20.0" \
  icon.y_offset=-2 \
  icon.padding_right=3 \
  background.image="$CONFIG_DIR/assets/mauve/${USAGE}.png"

