#!/bin/bash

for input_file in "$@"; do
    output_file="${input_file%.*}.mp3"
    if [[ "$input_file" == *.mp3 ]]; then
        continue
    fi
    ffmpeg -i "$input_file" -vn -acodec libmp3lame -q:a 2 "$output_file" -y -loglevel quiet
done
notify-send "Conversion Complete" "Video files converted to MP3"
