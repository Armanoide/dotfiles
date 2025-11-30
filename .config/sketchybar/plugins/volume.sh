#!/bin/sh

source "$CONFIG_DIR/colors.sh"

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

ITEM_NAME="volume"

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"

  case "$VOLUME" in
  [6-9][0-9] | 100)
    ICON=""
    COLOR=$BLUE
    ;;
  [3-5][0-9])
    ICON=""
    COLOR=$BLUE
    ;;
  [1-9] | [1-2][0-9])
    ICON=""
    COLOR=$BLUE
    ;;
  *)
    ICON=""
    COLOR=$OVERLAY0
    ;;
  esac

  sketchybar --set "$ITEM_NAME" icon="$ICON" label="$VOLUME%" icon.color=$COLOR label.color=$COLOR \
    icon.font="MesloLGS Nerd Font Mono:Bold:28.0" \
    icon.padding_right=3 \
    background.color=$COLOR
fi
