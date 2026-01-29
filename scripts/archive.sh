#!/bin/bash

# 1. Identify the folder where the files are located
# We take the directory of the first file passed by Thunar
BASE_DIR=$(dirname "$(readlink -f "$1")")

# 2. CHANGE DIRECTORY to that folder
# This is the key step to prevent deep nesting
cd "$BASE_DIR" || exit

# 3. Ask for the archive name
SUGGESTED_NAME=$(basename "$BASE_DIR").zip
ARCHIVE_NAME=$(zenity --entry --title="Create Archive" --text="Enter archive name:" --entry-text="$SUGGESTED_NAME")

[ -z "$ARCHIVE_NAME" ] && exit 0 

# Ensure .zip extension
[[ "$ARCHIVE_NAME" != *.zip ]] && ARCHIVE_NAME="${ARCHIVE_NAME}.zip"

# 4. Handle existing files
if [ -f "$ARCHIVE_NAME" ]; then
    ARCHIVE_NAME="${ARCHIVE_NAME%.*}_$(date +%H%M%S).zip"
fi

# 5. Extract only the filenames from the full paths passed by Thunar
# We need to pass relative names to 'zip' now that we've 'cd'ed
RELATIVE_FILES=()
for file in "$@"; do
    RELATIVE_FILES+=("$(basename "$file")")
done

# 6. Execute Zip
# We pass the RELATIVE_FILES array so zip doesn't see the /home/user/... paths
zip -rq "$ARCHIVE_NAME" "${RELATIVE_FILES[@]}" | zenity --progress --title="Archiving" --text="Compressing to $ARCHIVE_NAME..." --pulsate --auto-close

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    notify-send "Compression Complete" "Created $ARCHIVE_NAME in $BASE_DIR"
else
    zenity --error --text="Compression failed."
fi