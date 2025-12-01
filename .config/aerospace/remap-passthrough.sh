#!/usr/bin/env bash

# Usage: remap-passthrough.sh --key "<key>" --command "<aerospace-command>" --except "App1,App2"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --key) key="$2"; shift ;;
        --command) command="$2"; shift ;;
        --only) only="$2"; shift ;;
        --except) except="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Default: run command if not forwarded
run_aerospace_command=true

# Path raycast detector
RAYCAST_DETECTOR="$HOME/.cargo/bin/raycast-detector"

# Check if Raycast dialog is open
if "$RAYCAST_DETECTOR" > /dev/null 2>&1; then
    # Dialog is open → forward key to Raycast
    aerospace mode passthrough
    skhd -k "$key"
    aerospace mode main
    run_aerospace_command=false
fi

# Check --only apps
if [ -n "$only" ]; then
    IFS=',' read -r -a only_array <<< "$only"
    for item in "${only_array[@]}"; do
        if aerospace list-windows --focused --format "%{app-name} | %{app-bundle-id}" | grep -q "$item"; then
            run_aerospace_command=false
            break
        fi
    done
fi

# Check --except apps
if [ -n "$except" ]; then
    IFS=',' read -r -a except_array <<< "$except"
    for item in "${except_array[@]}"; do
        if aerospace list-windows --focused --format "%{app-name} | %{app-bundle-id}" | grep -q "$item"; then
            run_aerospace_command=true
            break
        fi
    done
fi

# If we didn’t forward to macOS, run the normal Aerospace command
if [ "$run_aerospace_command" = true ] && [ -n "$command" ]; then
    read -r -a cmd_array <<< "$command"
    aerospace "${cmd_array[@]}"
fi

