#!/bin/sh

source "$CONFIG_DIR/colors.sh"

DATETIME=$(date '+%H:%M')

sketchybar --set "$NAME" label="$DATETIME" \
  icon.font="sketchybar-app-font:Regular:20.0"
