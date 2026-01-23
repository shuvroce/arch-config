#!/bin/bash

# Refresh package database
sudo pacman -Sy

# Install Pacman Packages
echo "--- Installing Pacman Packages ---"
PKGS=(
    curl wget git which \
    micro gedit fish btop fastfetch pacman-contrib timeshift \
    reflector thunar gvfs tumbler vlc firefox swaybg ddcutil brightnessctl nethogs nnn \
    wireplumber wl-clipboard cliphist swaylock wlsunset evince glances udiskie ffmpeg qt6-multimedia-ffmpeg \
    ifuse usbmuxd libplist libimobiledevice inter-font ttf-jetbrains-mono-nerd otf-codenewroman-nerd \
    tar bzip2 gzip unzip unrar python-pip yt-dlp ristretto zathura \
    wireguard-tools playerctl libappindicator-gtk3
    )

for pkg in "${PKGS[@]}"; do
    sudo pacman -S --noconfirm --needed "$pkg" || echo "Package $pkg not found, skipping..."
done

# Install Yay
echo "--- Installing Yay ---"
if ! command -v yay &> /dev/null; then
    sudo pacman -S --needed --noconfirm base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay
fi

# Install AUR Packages
echo "--- Installing AUR Packages ---"
yay -S --noconfirm waypaper wlogout nwg-look unimatrix-git visual-studio-code-bin google-chrome
