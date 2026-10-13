#!/bin/bash
# Setup module — orchestrator of common/* modules (exact order preserved).
# Sources core.sh, logs.sh, config-gen.sh then exposes common_setup().

source /usr/local/bin/entrypoints/common/core.sh
source /usr/local/bin/entrypoints/common/logs.sh
source /usr/local/bin/entrypoints/common/config-gen.sh

# Common setup for all modes
common_setup() {
    fix_permissions
    setup_directories
    generate_auth_config
    generate_opencode_config
    rotate_logs
    echo "Config OK: auth.json generated, opencode.json preserved (template)"
}
