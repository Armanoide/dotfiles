#!/bin/sh

source "$CONFIG_DIR/colors.sh"

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

ITEM_NAME="volume"

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"

  case "$VOLUME" in
  [6-9][0-9] | 100)
    ICON=":volume_high:"
    COLOR=$BLUE
    ;;
  [3-5][0-9])
    ICON=":volume_low:"
    COLOR=$BLUE
    ;;
  [1-9] | [1-2][0-9])
    ICON=":volume_low:"
    COLOR=$BLUE
    ;;
  *)
    ICON=":volume_muted:"
    COLOR=$OVERLAY0
    ;;
  esac

  sketchybar --set "$ITEM_NAME" icon="$ICON" label="$VOLUME%" icon.color=$COLOR label.color=$COLOR \
    icon.padding_right=3 \
    icon.font="sketchybar-app-font:Regular:20.0" \
    background.color=$COLOR
fi
