#!/bin/sh

source "$TOOL/padding.sh"

sketchybar --add item battery right \
           --set battery update_freq=120 script="$PLUGIN_DIR/battery.sh" \
           --subscribe battery system_woke power_source_change

set_padding battery icon_padding_off
