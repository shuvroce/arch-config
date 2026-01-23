#!/bin/bash

for input_file in "$@"; do
    output_file="${input_file%.*}.mp3"
    if [[ "$input_file" == *.mp3 ]]; then
        continue
    fi
    
    input_name=$(basename "$input_file")
    output_name=$(basename "$output_file")
    
    echo "Converting: $input_name ..."
    
    ffmpeg -i "$input_file" -vn -acodec libmp3lame -q:a 2 "$output_file" -y -loglevel error
    
    echo "Converted to: $output_name"
    echo -e "--------------------------------------------------- \n"
done
notify-send "Conversion Complete" "Video files converted to MP3"
