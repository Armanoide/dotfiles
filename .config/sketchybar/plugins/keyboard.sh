#!/bin/bash

source "$CONFIG_DIR/colors.sh"

ITEM_NAME="keyboard"

# macOS command to get current input source
LAYOUT=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources \
  | rg -Po '"KeyboardLayout Name"\s*=\s*\K[^;]+' \
  | tr -d '"' \
  | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
  | head -n1)

# Select icon depending on layout
case "$LAYOUT" in
  "French"|"FR")                          LAYOUT="FR";;
  "U.S."|"US"|"USInternational-PC")       LAYOUT="US";;
  *)                                      LAYOUT="??";;
esac

# Colors
COLOR=$MAROON

sketchybar --set "$ITEM_NAME" \
  icon=":keyboard:" \
  label=$LAYOUT \
  icon.color=$COLOR \
  background.color=$COLOR \
  label.color="$COLOR" \
  icon.font="sketchybar-app-font:Regular:20.0" \
  icon.padding_right=4

