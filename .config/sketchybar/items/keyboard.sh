#!/bin/sh

source "$TOOL/padding.sh"

sketchybar --add item keyboard right \
           --set keyboard script="$PLUGIN_DIR/keyboard.sh" \
           update_freq=2

set_padding keyboard right
