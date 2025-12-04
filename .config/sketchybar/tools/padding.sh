#!/bin/bash

source "$CONFIG/color.sh"

set_padding() {
  local ITEM_NAME="$1"
  local MODE="$2"

  # Default padding values
  local ICON_LEFT=4
  local ICON_RIGHT=1
  local LABEL_LEFT=1
  local LABEL_RIGHT=4

  # If second argument is "icon_padding_off", override padding
  if [[ "$MODE" == "icon_padding_off" ]]; then
    sketchybar --set "$ITEM_NAME" \
      label.padding_left="$LABEL_LEFT" \
      label.padding_right="$LABEL_RIGHT"

  else
    sketchybar --set "$ITEM_NAME" \
      icon.padding_left="$ICON_LEFT" \
      icon.padding_right="$ICON_RIGHT" \
      label.padding_left="$LABEL_LEFT" \
      label.padding_right="$LABEL_RIGHT"
  fi


  # Proper bracket syntax
  sketchybar --add bracket "space_padding_inner.$ITEM_NAME" "$ITEM_NAME"
  sketchybar --add bracket "space_padding_outer.$ITEM_NAME" "space_padding_inner.$ITEM_NAME" "$ITEM_NAME"
}

