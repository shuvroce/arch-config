#!/bin/bash

for input_file in "$@"
do
    output_file="${input_file%.*}.mp4"
    # -c copy tells ffmpeg to copy the streams without re-encoding (instant!)
    # -bsf:a aac_adtstoasc fixes bitstream filter issues common in .ts files
    ffmpeg -i "$input_file" -c copy -bsf:a aac_adtstoasc "$output_file" -y -loglevel quiet
done
notify-send "Conversion Complete" "TS files converted to MP4"