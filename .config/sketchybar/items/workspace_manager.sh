#!/bin/bash

# Get config directory
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"
source "$TOOL_DIR/padding.sh"

WORKSPACES=(1 2 3 4 5 6 7 8 9)
SPACE_GROUP=()

for sid in "${WORKSPACES[@]}"; do
  if ! sketchybar --query "space.$sid" &>/dev/null; then
    if [ $sid = "11" ]; then
      LABEL="magic"
    else
      LABEL="$sid"
    fi

    # Circle size
    CIRCLE_SIZE=32
    RADIUS=$((CIRCLE_SIZE / 2))

    PADDING_RIGHT=5
    PADDING_LEFT=5

    SPACE_GROUP+=("space.$sid")

    sketchybar --add item "space.$sid" left \
      --set "space.$sid" \
        background.drawing=on \
        background.height=$CIRCLE_SIZE \
        background.width=$CIRCLE_SIZE \
        background.corner_radius=$RADIUS \
        background.padding_left=$PADDING_LEFT \
        background.padding_right=$PADDING_RIGHT \
        icon.font="sketchybar-app-font:Regular:20.0" \
        label="$LABEL" \
        click_script="/opt/homebrew/bin/aerospace workspace $sid" \
        script="$CONFIG_DIR/plugins/space.sh $sid" \
        update_freq=1 \
      --subscribe "space.$sid" aerospace_workspace_change workspace_manager

    set_padding "space.$sid"
  fi
done

sketchybar --add bracket space_group "${SPACE_GROUP[@]}" \
  --set space_group \
    background.color=$CRUST

# Force initial update
sketchybar --trigger workspace_update

