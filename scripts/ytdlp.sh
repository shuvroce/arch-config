#!/bin/bash

TARGET_DIR="$HOME/Downloads"
mkdir -p "$TARGET_DIR"

URL=$(wl-paste)

# Basic URL validation
if [[ ! $URL =~ ^https?:// ]]; then
    zenity --error --title="Error" --text="No valid URL found in clipboard."
    exit 1
fi

# 1. Quality Selection
CHOICE=$(zenity --list --title="Download Video" --width=300 --height=350 \
    --column="Quality" "480p" "720p" "1080p" "Best (Max)")

[ -z "$CHOICE" ] && exit 0

case $CHOICE in
    "480p")  FORMAT="bv*[height<=480][ext=mp4]+ba[ext=m4a]/b[height<=480]" ;;
    "720p")  FORMAT="bv*[height<=720][ext=mp4]+ba[ext=m4a]/b[height<=720]" ;;
    "1080p") FORMAT="bv*[height<=1080][ext=mp4]+ba[ext=m4a]/b[height<=1080]" ;;
    *)       FORMAT="bv+ba/b" ;;
esac

# 2. DOWNLOAD & PROGRESS PARSING
# --no-playlist: Forces download of only the specific video
# --output: Standardizes filename to prevent "other video names" in parts
# --progress-template: Sends clean data to Zenity
yt-dlp -f "$FORMAT" \
    -P "$TARGET_DIR" \
    --no-playlist \
    --newline \
    --merge-output-format mp4 \
    --output "%(title)s.%(ext)s" \
    --progress-template "download:%(progress._percent_str)s" \
    "$URL" | stdbuf -oL sed -n 's/^download:[[:space:]]*\([0-9.]*\)%/\1/p' | \
    zenity --progress --title="Downloading Video" \
    --text="Working on: $URL" --percentage=0 --auto-close

# 3. Final Check
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    notify-send "yt-dlp" "Success! Video saved to Downloads."
else
    # This helps diagnose WHY it failed
    ERROR_MSG=$(yt-dlp --get-filename -f "$FORMAT" "$URL" 2>&1 | tail -n 1)
    zenity --error --title="Merge or Download Failed" --text="Error: $ERROR_MSG\n\nMake sure FFmpeg is installed."
fi