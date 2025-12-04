#!/bin/sh

source "$CONFIG_DIR/colors.sh"

# The volume_change event supplies a $INFO variable in which the current volume
# percentage is passed to the script.

ITEM_NAME="volume"
PADDING_RIGHT=5
if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"

  case "$VOLUME" in
  [6-9][0-9] | 100)
    ICON=":volume_high:"
    COLOR=$TEXT
    ;;
  [3-5][0-9])
    ICON=":volume_low:"
    COLOR=$TEXT
    ;;
  [1-9] | [1-2][0-9])
    ICON=":volume_low:"
    COLOR=$TEXT
    ;;
  *)
    ICON=":volume_muted:"
    COLOR=$OVERLAY0
    PADDING_RIGHT=2
    ;;
  esac

  sketchybar --set "$ITEM_NAME" icon="$ICON" icon.color=$COLOR \
    icon.font="sketchybar-app-font:Regular:20.0" \
    icon.y_offset=-2 \
    icon.padding_right=$PADDING_RIGHT \
    background.image="$CONFIG_DIR/assets/mauve/${VOLUME}.png"

fi
