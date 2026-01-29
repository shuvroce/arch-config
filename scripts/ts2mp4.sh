#!/bin/bash

(
total=$#
count=0
for input_file in "$@"; do
    ((count++))
    percent=$((count * 100 / total))
    output_file="${input_file%.*}.mp4"
    
    echo "# Converting: $(basename "$input_file") ($count/$total)"
    echo "$percent"
    
    if [[ "$input_file" != *.mp4 ]]; then
        ffmpeg -i "$input_file" -c copy -movflags +faststart "$output_file" -y -loglevel error
    fi
done
) | zenity --progress --title="Video Converter" --percentage=0 --auto-close

notify-send "Conversion Complete" "TS files converted to MP4"