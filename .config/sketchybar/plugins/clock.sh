#!/bin/sh

source "$CONFIG_DIR/colors.sh"

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

# Format: Day/Month Hour:Minute
DATETIME=$(date '+%H:%M')

sketchybar --set "$NAME" label="$DATETIME" icon=":clock:" \
  label.color=$MAUVE \
  icon.color=$MAUVE \
  icon.font="sketchybar-app-font:Regular:20.0" \
  background.color=$MAUVE
