#!/bin/bash
# Entrypoint Web — setup + HTTP server (port 4096)
# Lifecycle managed by Sablier (start/stop on demand)

# shellcheck source=/dev/null
source /usr/local/bin/entrypoint-common.sh

common_setup
echo "Starting API server on port 4096..."
opencode web --port 4096 --hostname 0.0.0.0 --cors "${OPENCODE_CORS_URL:-https://opencode.aramnoide.net}"
