#!/bin/bash

(
total=$#
count=0
for input_file in "$@"; do
    ((count++))
    percent=$((count * 100 / total))
    output_file="${input_file%.*}.mp3"
    
    echo "# Extracting Audio: $(basename "$input_file")"
    echo "$percent"
    
    ffmpeg -i "$input_file" -vn -acodec libmp3lame -q:a 2 "$output_file" -y -loglevel error
done
) | zenity --progress --title="Video to MP3" --percentage=0 --auto-close

notify-send "Extraction Complete" "Audio files saved as MP3"