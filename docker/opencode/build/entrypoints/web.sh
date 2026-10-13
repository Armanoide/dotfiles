#!/bin/bash
# Web entrypoint — setup + HTTP server (port 4096).
# Lifecycle managed by Sablier (start/stop on demand).

source /usr/local/bin/entrypoints/common/setup.sh   # core + logs + config-gen + common_setup

common_setup
echo "Starting API server on port 4096..."
exec opencode serve --port 4096 --hostname 0.0.0.0 --cors "${OPENCODE_CORS_URL:-https://opencode.aramnoide.net}"
