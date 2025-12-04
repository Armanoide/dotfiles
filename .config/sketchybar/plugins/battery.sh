#!/bin/sh

source "$CONFIG_DIR/colors.sh"

# Explicitly set the item name
ITEM_NAME="battery"

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"
INDICATOR_COLOR="green"
PADDING_RIGHT=0

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
FONT="MesloLGS Nerd Font Mono:Bold:30.0"

if [[ "$CHARGING" != "" ]]; then
  ICON=""
  PADDING_RIGHT=3
  FONT="MesloLGS Nerd Font Mono:Bold:20.0"
fi

# Set colors based on percentage
if [ "$PERCENTAGE" -le 15 ]; then
  INDICATOR_COLOR="red"
  COLOR=$RED
elif [ "$PERCENTAGE" -le 30 ]; then
  INDICATOR_COLOR="yellow"
  COLOR=$YELLOW
else
  COLOR=$GREEN
fi

sketchybar --set "$ITEM_NAME" icon="$ICON"  \
  icon.font="$FONT" \
  icon.y_offset=-2 \
  icon.padding_right=$PADDING_RIGHT \
  background.image="$CONFIG_DIR/assets/$INDICATOR_COLOR/${PERCENTAGE}.png"

