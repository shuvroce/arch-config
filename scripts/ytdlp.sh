#!/bin/bash

# Get URL from clipboard
URL=$(wl-paste)

if [[ ! $URL =~ ^https?:// ]]; then
    notify-send "yt-dlp Error" "No valid URL found in clipboard."
    exit 1
fi

# Move to the Thunar directory
cd "$1"

echo "--- Universal Video Downloader ---"
echo "URL: $URL"
echo "Select desired quality:"

# Create a menu
PS3="Enter choice (1-5): "
# These strings must match the case patterns below EXACTLY
options=("480p" "720p" "1080p" "Best" "Quit")

select opt in "${options[@]}"
do
    case $opt in
        "480p")
            FORMAT="bv*[height<=480][ext=mp4]+ba[ext=m4a]/b[height<=480]"
            break
            ;;
        "720p")
            FORMAT="bv*[height<=720][ext=mp4]+ba[ext=m4a]/b[height<=720]"
            break
            ;;
        "1080p")
            FORMAT="bv*[height<=1080][ext=mp4]+ba[ext=m4a]/b[height<=1080]"
            break
            ;;
        "Best")
            FORMAT="bv+ba/b"
            break
            ;;
        "Quit")
            exit 0
            ;;
        *) 
            echo "Invalid option $REPLY. Please choose 1-5."
            ;;
    esac
done

echo "Downloading..."
yt-dlp -f "$FORMAT" --merge-output-format mp4 "$URL"

notify-send "Download Complete" "Video saved to $(pwd)"