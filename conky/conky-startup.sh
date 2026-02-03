#!/bin/sh

if [ "$DESKTOP_SESSION" = "niri" ]; then 
   killall conky
   cd "$HOME/.config/conky"
   conky -c "$HOME/.config/conky/conky.conf" &
   exit 0
fi
