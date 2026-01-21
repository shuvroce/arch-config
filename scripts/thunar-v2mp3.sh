#!/bin/bash

# Check if libnotify is installed for the "all done" message
HAS_NOTIFY=$(command -v notify-send)

# Loop through every file passed by Thunar
for input_file in "$@"; do
    # Generate output filename
    output_file="${input_file%.*}.mp3"
    
    # Skip if the file is already an mp3 to avoid accidental loops
    if [[ "$input_file" == *.mp3 ]]; then
        continue
    fi

    # Convert using ffmpeg
    ffmpeg -i "$input_file" -vn -acodec libmp3lame -q:a 2 "$output_file" -y -loglevel quiet
done

# Send one final notification when the whole batch is finished
if [ -n "$HAS_NOTIFY" ]; then
    notify-send "FFmpeg Conversion" "Batch processing complete: $(echo "$#" files processed)"
fi