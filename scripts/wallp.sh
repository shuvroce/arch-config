#!/bin/bash

killall swaybg 2>/dev/null

swaybg -i "$1" -m fill &

{
    echo '#!/bin/bash'
    echo 'killall swaybg 2>/dev/null'
    printf 'swaybg -i %q -m fill &\n' "$1"
} > ~/.config/niri/wallpaper.sh
chmod +x ~/.config/niri/wallpaper.sh
