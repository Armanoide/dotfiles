
TAILSCALE_BIN="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

if ! command -v "$TAILSCALE_BIN" >/dev/null 2>&1; then
  exit 0
fi

STATUS=$("$TAILSCALE_BIN" status --json 2>/dev/null)

ONLINE=$(echo "$STATUS" | jq -r '.BackendState')
IP=$(echo "$STATUS" | jq -r '.Self.TailscaleIPs[0]')

if [[ "$ONLINE" == "Running" ]]; then
  $TAILSCALE_BIN down > /dev/null 2>&1
else
  $TAILSCALE_BIN up > /dev/null 2>&1
fi
