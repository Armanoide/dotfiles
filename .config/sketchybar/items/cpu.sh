#!/bin/sh

source "$TOOL_DIR/padding.sh"

sketchybar --add item cpu right \
           --set cpu script="$PLUGIN_DIR/cpu.sh" \
           update_freq=4

set_padding cpu
