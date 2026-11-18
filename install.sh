#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "$(readlink -f -- "$0")")" && pwd)"
cd -- "$SCRIPT_DIR" || exit 1

if [ "$(id -u)" -eq 0 ]; then
    echo "Run this script as your normal user, not as root." >&2
    exit 1
fi

USER_NAME="$(id -un)"

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Refresh package database
sudo pacman -Syu --noconfirm

# Install Pacman Packages
echo "--- Installing Pacman Packages ---"
PKGS=(
    # System Core & Drivers
    base-devel xwayland-satellite xdg-desktop-portal-gtk xdg-desktop-portal-gnome
    xdg-utils polkit-gnome udiskie expac ntfs-3g os-prober flatpak gnome-keyring

    # Niri Environment
    niri waybar fuzzel mako libcanberra sound-theme-freedesktop
    alacritty wl-clipboard cliphist playerctl swaybg swaylock btop fcitx5

    # Tools & Shell
    curl wget git fish fastfetch gedit nano micro
    pacman-contrib timeshift reflector nethogs

    # Networking & Audio
    iwd openssh wireguard-tools wireplumber pipewire-pulse pipewire-alsa

    # File Management (The Thunar Stack)
    thunar gvfs gvfs-mtp tumbler ffmpegthumbnailer

    # Media & Graphics
    vlc vlc-plugins-all ristretto evince gnome-disk-utility
    yt-dlp ffmpeg nwg-look
    ifuse usbmuxd libplist libimobiledevice rclone fuse3 libnotify jq

    # Browsers
    firefox

    # Social
    telegram-desktop

    # Fonts & Themes
    noto-fonts inter-font ttf-jetbrains-mono-nerd otf-codenewroman-nerd
    adw-gtk-theme libappindicator-gtk3 qt5ct qt6ct

    # Archives
    zip tar bzip2 gzip unzip unrar 7zip xarchiver

    # Development
    python-pip nodejs opencode

    # Greeter
    lightdm lightdm-slick-greeter

    # Extra
    # zathura obs-studio qbittorrent ddcutil brightnessctl
)

failed=()
for pkg in "${PKGS[@]}"; do
    if ! sudo pacman -S --noconfirm --needed "$pkg"; then
        failed+=("$pkg")
    fi
done

if [ ${#failed[@]} -gt 0 ]; then
    echo "Warning: these packages failed to install: ${failed[*]}" >&2
fi

# Install Yay
echo "--- Installing Yay ---"
if ! command -v yay &> /dev/null; then
    tmpdir="$(mktemp -d)"
    if git clone --depth=1 https://aur.archlinux.org/yay.git "$tmpdir/yay"; then
        ( cd "$tmpdir/yay" && makepkg -si --noconfirm )
    fi
    rm -rf "$tmpdir"

    if ! command -v yay &> /dev/null; then
        echo "yay installation failed." >&2
        exit 1
    fi
fi

# Install AUR Packages
echo "--- Installing AUR Packages ---"
AUR_PKGS=(
    zenity-gtk3 wlogout visual-studio-code-bin google-chrome numix-circle-icon-theme-git ttf-freebanglafont
)
if ! yay -S --noconfirm --needed "${AUR_PKGS[@]}"; then
    echo "Warning: some AUR packages failed to install." >&2
fi

echo "--- Applying user configuration ---"
if ! bash ./config.sh; then
    echo "Configuration step failed." >&2
    exit 1
fi

if [ -t 0 ]; then
    read -rp "Set up Google Drive (rclone + offline cache) now? [y/N] " reply
    case "$reply" in
        [Yy]*) bash ./gdrive.sh || echo "Google Drive setup failed." >&2 ;;
    esac
fi

echo "--- Setup Complete. Please reboot. ---"
