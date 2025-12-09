#!/bin/bash

# --- Configuration ---
TEST_URL="http://speedtest.tele2.net/100MB.zip"
TEMP_DOWNLOAD_FILE="/tmp/speedtest_download_file"
REPORT_FILE="/tmp/speedtest_report.txt"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
RUNNING_FLAG="/tmp/speedtest_running.flag"

# --- Function to clean up the temporary download file ---
cleanup() {
    if [ -f "$TEMP_DOWNLOAD_FILE" ]; then
        rm "$TEMP_DOWNLOAD_FILE"
    fi

    if [ -f "$RUNNING_FLAG" ]; then
        rm "$RUNNING_FLAG"
    fi
}

# Ensure cleanup runs on script exit or interruption
trap cleanup EXIT

# --- Execution ---

echo "true" > $RUNNING_FLAG
echo "Starting download speed test at $TIMESTAMP..."
echo "Results will be written to: $REPORT_FILE"
echo "---"

# Use curl to download the file and measure the speed
DOWNLOAD_SPEED_BPS=$(curl -o "$TEMP_DOWNLOAD_FILE" -s -w "%{speed_download}" "$TEST_URL")

# --- Results Processing and Report Generation ---

# Start the report content
REPORT_CONTENT="--- Download Speed Test Report ---\n"
REPORT_CONTENT+="Timestamp: $TIMESTAMP\n"
REPORT_CONTENT+="Test URL: $TEST_URL\n"

# Check if curl was successful (exit code 0)
if [ $? -eq 0 ]; then
    # Convert speed from Bytes/sec (B/s) to Mbps and MB/s
    DOWNLOAD_SPEED_MBPS=$(echo "scale=2; $DOWNLOAD_SPEED_BPS * 8 / 1024 / 1024" | bc)
    DOWNLOAD_SPEED_MB_S=$(echo "scale=2; $DOWNLOAD_SPEED_BPS / 1024 / 1024" | bc)
    
    # Add successful results to the report
    REPORT_CONTENT+="Status: SUCCESS\n"
    REPORT_CONTENT+="Average Speed (Bytes/sec): $DOWNLOAD_SPEED_BPS\n"
    REPORT_CONTENT+="Result (Mbps): $DOWNLOAD_SPEED_MBPS\n"
    REPORT_CONTENT+="Result (MB/s): $DOWNLOAD_SPEED_MB_S\n"

    # Display results to the console
    echo "✅ Test Complete. Speed written to report."
    echo "   Average Download Speed: **$DOWNLOAD_SPEED_MBPS Mbps**"
    
else
    # Add failure message to the report
    REPORT_CONTENT+="Status: FAILURE\n"
    REPORT_CONTENT+="Error: The download failed or 'curl' command was not found.\n"
    
    # Display error to the console
    echo "❌ Error: The download failed. Report status is FAILURE."
fi

# Append the report content to the file
# Note: Using '>>' to append, so you can run the test multiple times
# and keep a history in the same file.
echo -e "$REPORT_CONTENT\n--------------------------------------\n" >> "$REPORT_FILE"

echo "Report successfully saved to **$REPORT_FILE**"
