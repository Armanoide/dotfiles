
#!/bin/sh

source "$CONFIG_DIR/colors.sh"

ITEM_NAME="tailscale"

TAILSCALE_BIN="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

if ! command -v "$TAILSCALE_BIN" >/dev/null 2>&1; then
  sketchybar --set "$NAME" label="Tailscale missing" icon="⚠️"
  exit 0
fi

STATUS=$("$TAILSCALE_BIN" status --json 2>/dev/null)

ONLINE=$(echo "$STATUS" | jq -r '.BackendState')

if [[ "$ONLINE" == "Running" ]]; then
  sketchybar --set "$NAME" \
    icon=":tailscale:" \
    icon.font="sketchybar-app-font:Regular:20.0" \
    icon.color=$TEXT \
    label.font="MesloLGS Nerd Font Mono:Bold:12.0"
else
  sketchybar --set "$NAME" \
    icon=":tailscale:" \
    icon.font="sketchybar-app-font:Regular:20.0" \
    icon.padding_left=5 \
    icon.color=$OVERLAY0
fi
