function v2mp3
    # If no argument is given, use the current working directory (.)
    set target_dir (if test -n "$argv[1]"; echo "$argv[1]"; else; echo "."; end)

    # Resolve to absolute path to avoid confusion
    set target_dir (realpath "$target_dir")
    set output_dir "$target_dir/converted_mp3s"

    echo "Source: $target_dir"
    echo "Output: $output_dir"
    mkdir -p "$output_dir"

    # Loop through common video files
    for file in "$target_dir"/*.{mp4,mkv,mov,avi,flv,webm}
        if test -f "$file"
            set filename (basename "$file" | string replace -r '\.[^.]+$' '')
            echo "Converting: $filename..."
            
            ffmpeg -i "$file" -vn -acodec libmp3lame -q:a 2 "$output_dir/$filename.mp3" -y -loglevel quiet
        end
    end

    echo "---------------------------------------"
    echo "Conversion complete!"
end