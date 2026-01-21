#!/bin/bash

source "$CONFIG_DIR/colors.sh"

NETWORK_IFACE=$(route get default 2>/dev/null | grep interface | awk '{print $2}')

IP_ADDRESS=$(ifconfig "$NETWORK_IFACE" 2>/dev/null | grep 'inet ' | awk '{print $2}')

if [ -n "$IP_ADDRESS" ]; then
    ICON_COLOR="$GREEN"
else
    ICON_COLOR="$OVERLAY0"
fi

sketchybar --set "internet" \
  icon="" \
  icon.font="MesloLGS Nerd Font Mono:Bold:25.0" \
  icon.color="$ICON_COLOR" 
