#!/bin/sh

# Get config directory
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

# Get workspace ID
if [ -n "$1" ]; then
  WORKSPACE_ID="$1"
else
  WORKSPACE_ID="${NAME#space.}"
fi

# Get focused workspace
FOCUSED=$(/opt/homebrew/bin/aerospace list-workspaces --focused)

# Determine which apps are in the workspace
APPS=$(/opt/homebrew/bin/aerospace list-windows --workspace "$WORKSPACE_ID"  2>/dev/null)

ICON=$(get_icon "$APPS")

# Set the icon
sketchybar --set "$NAME" icon="$ICON"

# Highlight if focused
if [ "$WORKSPACE_ID" = "$FOCUSED" ]; then
  sketchybar --set $NAME \
    background.drawing=on \
    background.color=$MAUVE \
    label.color=$MAUVE \
    icon.color=$MAUVE
else
  sketchybar --set $NAME \
    background.drawing=off \
    label.color=$TEXT \
    icon.color=$TEXT
fi
