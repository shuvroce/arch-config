#!/bin/bash

# 1. Setup
TARGET_DIR="$HOME/Downloads"
mkdir -p "$TARGET_DIR"

# 2. Get URL from clipboard
URL=$(wl-paste)

# Basic validation
if [[ ! $URL =~ ^https?:// ]]; then
    zenity --error --title="Error" --text="No valid URL found in clipboard."
    exit 1
fi

# 3. Get Filename (Aria2 can sometimes guess this, but we'll show the URL)
# We use a pulsating bar because Aria2's progress output is harder to parse 
# for a 0-100% bar without complex regex, so we'll show the raw speed.

(
# -x 16: Use 16 connections per server
# -s 16: Use 16 connections total
# --dir: Save location
aria2c -x 16 -s 16 --dir="$TARGET_DIR" --summary-interval=1 "$URL" 2>&1 | while read -r line; do
# Extract progress info to show in the Zenity text area
if [[ "$line" == *%* ]]; then
    echo "# $line"
fi
done
) | zenity --progress --title="Aria2 Downloading..." \
    --text="Connecting to $URL" --pulsate --auto-close

# 4. Final Check
if [ $? -eq 0 ]; then
    notify-send "Aria2" "Download Complete! Saved to Downloads."
else
    zenity --error --title="Download Failed" --text="Aria2 could not download the file. Check the link or your connection."
fi