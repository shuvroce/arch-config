#!/bin/bash

# Get brightness using a faster "terse" output mode
# VCP 10 C 50 100 -> awk picks the 4th field (50)
val=$(ddcutil getvcp 10 --terse 2>/dev/null | awk '{print $4}')

# Fallback if ddcutil fails or returns empty
if [ -z "$val" ]; then
    echo '{"text": "ERR", "percentage": 0}'
else
    echo "{\"text\": \"$val\", \"percentage\": $val}"
fi
