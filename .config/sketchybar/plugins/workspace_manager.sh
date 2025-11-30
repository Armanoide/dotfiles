#!/bin/bash
# Get config directory
CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"

# Get workspace states
NON_EMPTY=($(/opt/homebrew/bin/aerospace list-workspaces --monitor focused --empty no))
FOCUSED=$(/opt/homebrew/bin/aerospace list-workspaces --focused)

# Combine workspaces to show (non-empty + focused)
WORKSPACES_TO_SHOW=($(echo "${NON_EMPTY[@]}"$'\n'"$FOCUSED" | sort -un))

# Get existing space items from SketchyBar
EXISTING=($(sketchybar --query bar | jq -r '.items[] | select(startswith("space."))'))

# Remove workspaces that shouldn't be shown
for existing in "${EXISTING[@]}"; do
  sid=${existing#space.}
  # check if workspace is empty and not focused
  if [[ ! " ${WORKSPACES_TO_SHOW[@]} " =~ " ${sid} " ]]; then
    sketchybar --remove "$existing"
  fi
done

# Add/update workspaces that should be shown
for sid in "${WORKSPACES_TO_SHOW[@]}"; do
  if ! sketchybar --query "space.$sid" &>/dev/null; then
    if [ $sid = "11" ]; then
      LABEL="magic"
    else
      LABEL="$sid"
    fi
    sketchybar --add item "space.$sid" left \
      --set "space.$sid" \
      background.color=0x44ffffff \
      background.corner_radius=4 \
      background.height=20 \
      background.drawing=off \
      label="$LABEL" \
      click_script="/opt/homebrew/bin/aerospace workspace $sid" \
      script="$CONFIG_DIR/plugins/space.sh $sid" \
      update_freq=1 \
      --subscribe "space.$sid" aerospace_workspace_change workspace_manager
  fi
done

# Force initial update
sketchybar --trigger workspace_update
