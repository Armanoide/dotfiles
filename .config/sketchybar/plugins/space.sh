#!/bin/sh

# Get config directory
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

# Get workspace ID
if [ -n "$1" ]; then
  WORKSPACE_ID="$1"
else
  WORKSPACE_ID="${NAME#space.}"
fi

# Get focused workspace
FOCUSED=$(/opt/homebrew/bin/aerospace list-workspaces --focused)

# Highlight if focused
if [ "$WORKSPACE_ID" = "$FOCUSED" ]; then
  sketchybar --set $NAME \
    background.color=$MAUVE \
    background.drawing=on \
    background.y_offset=0 \
    label.color=$CRUST
else
  sketchybar --set $NAME \
    background.drawing=off \
    label.color=$TEXT
fi

# replace line 21 to 23 with the following code
# if you want to have a line under the foucsed space
# instead of a colored background
#background.height=2 \
#background.y_offset=-13 \
#background.padding_left=2 \
#background.padding_right=2 \
#label.color=$MAUVE \
