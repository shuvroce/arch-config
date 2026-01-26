#!/bin/bash

for file in "$@"; do
    # Get the filename without the extension to use as folder name
    # e.g., "my_archive.zip" -> "my_archive"
    dirname="${file%.*}"
    
    # Create the directory (and don't complain if it already exists)
    mkdir -p "$dirname"
    
    echo "Extracting '$(basename "$file")' into '$dirname'..."

    case "$file" in
        *.tar.gz|*.tgz) tar -xzvf "$file" -C "$dirname" ;;
        *.tar.xz)       tar -xJvf "$file" -C "$dirname" ;;
        *.zip)          unzip "$file" -d "$dirname"     ;;
        *.7z)           7z x "$file" -o"$dirname"       ;;
        *.rar)          unrar x "$file" "$dirname/"     ;;
        *)              echo "Unknown format: $file"    ;;
    esac
done

notify-send "Extraction Complete" "Files extracted to their own subfolders."