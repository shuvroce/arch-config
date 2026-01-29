#!/bin/bash

# Count total files for progress calculation
total_files=$#
current_count=0

(
for file_path in "$@"; do
    # Calculate progress percentage
    ((current_count++))
    percentage=$((current_count * 100 / total_files))
    
    abs_path=$(readlink -f "$file_path")
    parent_dir=$(dirname "$abs_path")
    filename=$(basename "$abs_path")
    folder_name="${filename%.*}"
    target_dir="$parent_dir/$folder_name"

    # Send text to Zenity progress bar
    echo "# Extracting: $filename ($current_count/$total_files)"
    echo "$percentage"

    mkdir -p "$target_dir"

    # Extraction commands (using -q for quiet so they don't flood the pipe)
    case "$filename" in
        *.tar.gz|*.tgz) tar -xzf "$abs_path" -C "$target_dir" ;;
        *.tar.xz)       tar -xJf "$abs_path" -C "$target_dir" ;;
        *.zip)          unzip -q "$abs_path" -d "$target_dir" ;;
        *.7z)           7z x "$abs_path" -o"$target_dir" -y > /dev/null ;;
        *.rar)          unrar x -o+ "$abs_path" "$target_dir/" > /dev/null ;;
    esac
done
) | zenity --progress --title="Extracting Archives" --text="Starting..." --percentage=0 --auto-close --pulsate

notify-send "Extraction Complete" "$total_files archives processed."