#!/bin/sh

source "$CONFIG_DIR/colors.sh"

# Explicitly set the item name
ITEM_NAME="battery"

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

case "${PERCENTAGE}" in
9[0-9] | 100)
  ICON=""
  ;;
[6-8][0-9])
  ICON=""
  ;;
[3-5][0-9])
  ICON=""
  ;;
[1-2][0-9])
  ICON=""
  ;;
*) ICON="" ;;
esac
# setting the font for icons abouve
FONT="MesloLGS Nerd Font Mono:Bold:35.0"

if [[ "$CHARGING" != "" ]]; then
  ICON=""
  FONT="MesloLGS Nerd Font Mono:Bold:20.0"
fi

# Set colors based on percentage
if [ "$PERCENTAGE" -le 15 ]; then
  COLOR=$RED
elif [ "$PERCENTAGE" -le 30 ]; then
  COLOR=$YELLOW
else
  COLOR=$GREEN
fi

sketchybar --set "$ITEM_NAME" icon="$ICON" label="${PERCENTAGE}%" \
  icon.color=$COLOR \
  label.color=$COLOR \
  icon.font="$FONT" \
  background.color=$COLOR

