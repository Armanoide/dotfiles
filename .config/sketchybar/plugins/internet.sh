
#!/bin/bash

# Load colors (Assuming $CONFIG_DIR is correctly set)
source "$CONFIG_DIR/colors.sh"

ITEM_NAME="internet"
PING_TARGET="8.8.8.8"

NETWORK_IFACE=$(route get default 2>/dev/null | grep interface | awk '{print $2}')
IP_ADDRESS_INTERNET=$(ifconfig "$NETWORK_IFACE" 2>/dev/null | grep 'inet ' | awk '$1=="inet" {print $2}')


if [ -n "$IP_ADDRESS_INTERNET" ]; then
  ICON_COLOR="$TEXT"
else
  ICON_COLOR="$OVERLAY0"
fi

#TODO: RATE LEVEL internet 

LEVEL=0
sketchybar --set "$ITEM_NAME" \
  icon="" \
  icon.font="MesloLGS Nerd Font Mono:Bold:25.0" \
  icon.color="$ICON_COLOR" \
  background.image="$CONFIG_DIR/assets/mauve/${LEVEL}.png"
