#!/bin/bash
# Logs module — log rotation. The only file to touch for rotation changes.

rotate_logs() {
    echo "Rotating logs..."
    for logfile in "$LOG_DIR"/*.log; do
        if [ -f "$logfile" ]; then
            local size
            size=$(stat -f%z "$logfile" 2>/dev/null || stat -c%s "$logfile" 2>/dev/null || echo "0")
            if [ "$size" -gt 10485760 ]; then
                local rotated="${logfile}.$(date +%Y%m%d%H%M%S)"
                tail -c 5M "$logfile" > "$rotated"
                mv "$rotated" "$logfile"
                echo "Rotated: $logfile"
            fi
        fi
    done
    ls -t "$LOG_DIR"/*.log.* 2>/dev/null | tail -n +6 | xargs -r rm -f 2>/dev/null || true
}
