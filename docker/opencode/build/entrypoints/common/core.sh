#!/bin/bash
# Core module — global vars + base setup (permissions, directories).
# Sourced FIRST by every entrypoint. Defines DATA_DIR/CONFIG_DIR/LOG_DIR.

# --- CONFIGURATION ---
DATA_DIR="/home/opencode/.local/share/opencode"
CONFIG_DIR="/home/opencode/.config/opencode"
LOG_DIR="$DATA_DIR/log"
# Supported permissions list
PERMS_LIST=("edit" "write" "read" "grep" "glob" "list" "lsp" "patch" "skill" "todowrite" "todoread" "webfetch" "websearch")

fix_permissions() {
    echo "Fixing directory ownership..."
    local uid
    uid=$(id -u)
    local gid
    gid=$(id -g)
    echo chown -R "$uid:$gid" "$DATA_DIR" "$CONFIG_DIR"
    sudo chown -R "$uid:$gid" "$DATA_DIR" "$CONFIG_DIR"
    echo "Ownership fixed"
}

setup_directories() {
    echo "Setting up directories..."
    mkdir -p "$LOG_DIR" "$CONFIG_DIR"
    touch "$LOG_DIR/opencode.log"
}
