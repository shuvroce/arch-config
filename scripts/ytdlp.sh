#!/bin/bash

URL=$(wl-paste)
if [[ ! $URL =~ ^https?:// ]]; then
    zenity --error --text="No valid URL found in clipboard."
    exit 1
fi

# Change to the Thunar directory passed as %f
cd "$1"

# Graphical Selection Menu
CHOICE=$(zenity --list --title="yt-dlp Downloader" --column="Quality" "480p" "720p" "1080p" "Best")

[ -z "$CHOICE" ] && exit 0

case $CHOICE in
    "480p")  FORMAT="bv*[height<=480][ext=mp4]+ba[ext=m4a]/b[height<=480]" ;;
    "720p")  FORMAT="bv*[height<=720][ext=mp4]+ba[ext=m4a]/b[height<=720]" ;;
    "1080p") FORMAT="bv*[height<=1080][ext=mp4]+ba[ext=m4a]/b[height<=1080]" ;;
    *)       FORMAT="bv+ba/b" ;;
esac

# Download with a pulsating bar
yt-dlp -f "$FORMAT" --merge-output-format mp4 "$URL" | zenity --progress --title="Downloading..." --text="Fetching video from $URL" --pulsate --auto-close

notify-send "Download Complete" "Video saved to $(pwd)"