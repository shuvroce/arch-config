#!/bin/bash

# Refresh package database
sudo pacman -Sy

# Install Pacman Packages
echo "--- Installing Pacman Packages ---"
sudo pacman -S --needed --noconfirm \
curl wget git which \
neofetch nano micro neovim fish btop pacman-contrib timeshift \
reflector network-manager-applet thunar gvfs tumbler vlc firefox swaybg ddcutil brightnessctl \
wireplumber wl-clipboard cliphist "swaync" swaylock cava wlsunset evince gedit glances udiskie qt6-multimedia-ffmpeg \
ifuse usbmuxd libplist libimobiledevice inter-font ttf-jetbrains-mono-nerd tar bzip2 gzip unzip unrar \
wireguard-tools localsend playerctl libappindicator-gtk3

# Install Yay
echo "--- Installing Yay ---"
if ! command -v yay &> /dev/null; then
    sudo pacman -S --needed --noconfirm base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay
fi

# Install AUR Packages
echo "--- Installing AUR Packages ---"
yay -S --noconfirm waypaper wlogout nwg-look unimatrix-git visual-studio-code-bin
