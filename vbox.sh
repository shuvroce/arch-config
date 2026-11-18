#!/bin/bash

if [ "$(id -u)" -eq 0 ]; then
    echo "Run this script as your normal user, not as root." >&2
    exit 1
fi

sudo pacman -S --needed --noconfirm virtualbox-guest-utils
sudo usermod -aG vboxsf "$USER"
sudo systemctl enable --now vboxservice.service
