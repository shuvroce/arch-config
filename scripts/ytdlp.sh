#!/bin/bash

# 1. Define the constant Download directory
TARGET_DIR="$HOME/Downloads"
mkdir -p "$TARGET_DIR"

# 2. Get URL from clipboard (using wayland/wl-paste)
URL=$(wl-paste)

if [[ ! $URL =~ ^https?:// ]]; then
    zenity --error --title="yt-dlp Error" --text="No valid URL found in clipboard."
    exit 1
fi

# 3. Quality Selection Menu
CHOICE=$(zenity --list --title="Download Video" --width=300 --height=350 \
    --column="Quality Options" "480p" "720p" "1080p" "Best (Max)")

[ -z "$CHOICE" ] && exit 0 # Exit if user hits Cancel

case $CHOICE in
    "480p")  FORMAT="bv*[height<=480][ext=mp4]+ba[ext=m4a]/b[height<=480]" ;;
    "720p")  FORMAT="bv*[height<=720][ext=mp4]+ba[ext=m4a]/b[height<=720]" ;;
    "1080p") FORMAT="bv*[height<=1080][ext=mp4]+ba[ext=m4a]/b[height<=1080]" ;;
    *)       FORMAT="bv+ba/b" ;;
esac

# 4. Run Download and Pipe Progress to Zenity
# We use -P to tell yt-dlp exactly where to save the file
yt-dlp -f "$FORMAT" \
       -P "$TARGET_DIR" \
       --newline \
       --merge-output-format mp4 \
       "$URL" | \
    stdbuf -oL sed -n 's/^.*\[download\][[:space:]]*\([0-9.]*\)%.*$/\1/p' | \
    zenity --progress --title="Downloading to $TARGET_DIR" \
    --text="Fetching video..." --percentage=0 --auto-close

# 5. Final Notification
if [ $? -eq 0 ]; then
    notify-send "yt-dlp" "Success! Video saved to Downloads folder."
else
    notify-send "yt-dlp" "Download failed or interrupted."
fi