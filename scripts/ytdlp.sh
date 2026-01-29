#!/bin/bash

TARGET_DIR="$HOME/Downloads"
mkdir -p "$TARGET_DIR"

URL=$(wl-paste)

if [[ ! $URL =~ ^https?:// ]]; then
    zenity --error --title="Error" --text="No valid URL found in clipboard."
    exit 1
fi

CHOICE=$(zenity --list --title="Download Video" --width=300 --height=350 \
    --column="Quality" "480p" "720p" "1080p" "Best (Max)")

[ -z "$CHOICE" ] && exit 0

case $CHOICE in
    "480p")  FORMAT="bv*[height<=480][ext=mp4]+ba[ext=m4a]/b[height<=480]" ;;
    "720p")  FORMAT="bv*[height<=720][ext=mp4]+ba[ext=m4a]/b[height<=720]" ;;
    "1080p") FORMAT="bv*[height<=1080][ext=mp4]+ba[ext=m4a]/b[height<=1080]" ;;
    *)       FORMAT="bv+ba/b" ;;
esac

# 4. DOWNLOAD & PROGRESS PARSING
# --newline: sends each update on a new line
# --nopart: prevents the "tiny parts" flooding
# stdbuf & sed: extracts the number (e.g. 45.2) for Zenity to move the bar
yt-dlp -f "$FORMAT" \
    -P "$TARGET_DIR" \
    --newline \
    --nopart \
    --merge-output-format mp4 \
    "$URL" | stdbuf -oL sed -n 's/^.*\[download\][[:space:]]*\([0-9.]*\)%.*$/\1/p' | \
    zenity --progress --title="Downloading..." \
    --text="Downloading to $TARGET_DIR" --percentage=0 --auto-close

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    notify-send "yt-dlp" "Success! Video saved to Downloads."
else
    notify-send "yt-dlp" "Download failed or check your connection."
fi