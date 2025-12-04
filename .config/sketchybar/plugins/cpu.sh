#!/bin/sh

source "$CONFIG_DIR/colors.sh"

ITEM_NAME="cpu"

CORE_COUNT=$(sysctl -n machdep.cpu.thread_count)
CPU_INFO=$(ps -eo pcpu,user)
CPU_SYS=$(echo "$CPU_INFO" | grep -v $(whoami) | sed "s/[^ 0-9\.]//g" | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")
CPU_USER=$(echo "$CPU_INFO" | grep $(whoami) | sed "s/[^ 0-9\.]//g" | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")

USAGE=$(echo "$CPU_SYS $CPU_USER" | awk '{printf "%.0f\n", ($1 + $2)*100}')

sketchybar --set "$ITEM_NAME" \
  icon=":cpu:" \
  icon.font="sketchybar-app-font:Regular:17.0" \
  icon.y_offset=-2 \
  background.image="$CONFIG_DIR/assets/mauve/${USAGE}.png"

