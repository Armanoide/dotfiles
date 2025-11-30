#!/bin/sh

source "$CONFIG_DIR/colors.sh"

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

# Format: Day/Month Hour:Minute
DATETIME=$(date '+%a %d %H:%M')

sketchybar --set "$NAME" label="$DATETIME" icon= \
  label.color=$MAROON \
  icon.color=$MAROON \
  icon.font="MesloLGS Nerd Font Mono:Bold:25.0" \
  background.color=$MAROON
