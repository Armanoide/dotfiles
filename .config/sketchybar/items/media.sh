#!/bin/bash


source "$TOOL/padding.sh"

sketchybar --add item media left \
           --set media script="$PLUGIN_DIR/media.sh" \
                         click_script="media-control toggle-play-pause" \
                         update_freq=1

set_padding media
