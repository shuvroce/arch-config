#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "$(readlink -f -- "$0")")" && pwd)"
cd -- "$SCRIPT_DIR" || exit 1

if [ "$(id -u)" -eq 0 ]; then
    echo "Run this script as your normal user, not as root." >&2
    exit 1
fi

shopt -s nullglob

USER_NAME="$(id -un)"

sudo -v

# Create Directories
echo "--- Setting up Configs ---"
mkdir -p ~/GoogleDrive
mkdir -p ~/.config/{xdg-desktop-portal,fish,niri,waybar,alacritty,fuzzel,Thunar,mako,qt5ct,qt6ct,wlogout,rclone-offline}
mkdir -p ~/.config/fish/functions
mkdir -p ~/.config/qt5ct/colors
mkdir -p ~/.config/qt6ct/colors
mkdir -p ~/.config/systemd/user
mkdir -p ~/.local/bin
mkdir -p ~/Pictures/Wallpapers
mkdir -p ~/Pictures/Screenshots

# Copying files
[ -d "./niri" ]           && cp -rv ./niri/config.kdl ~/.config/niri/
[ -d "./waybar" ]         && cp -rv ./waybar/* ~/.config/waybar/
[ -d "./alacritty" ]      && cp -rv ./alacritty/* ~/.config/alacritty/
[ -d "./fish/functions" ] && cp -rv ./fish/functions/* ~/.config/fish/functions/
[ -d "./fuzzel" ]         && cp -rv ./fuzzel/fuzzel.ini ~/.config/fuzzel/
[ -d "./Thunar" ]         && cp -rv ./Thunar/uca.xml ~/.config/Thunar/
[ -d "./mako" ]           && cp -rv ./mako/config ~/.config/mako/
[ -d "./qt5ct/colors" ]   && cp -rv ./qt5ct/colors/* ~/.config/qt5ct/colors/
[ -d "./qt6ct/colors" ]   && cp -rv ./qt6ct/colors/* ~/.config/qt6ct/colors/
[ -d "./wlogout" ]        && cp -rv ./wlogout/* ~/.config/wlogout/
[ -d "./scripts" ]        && cp -rv ./scripts/* ~/.local/bin/

# Keep an existing wallpaper choice, but provide the default on first install
if [ -f "./niri/wallpaper.sh" ]; then
    if [ ! -f ~/.config/niri/wallpaper.sh ]; then
        cp -v ./niri/wallpaper.sh ~/.config/niri/
    fi
    chmod +x ~/.config/niri/wallpaper.sh
fi

# Replace the old hardcoded user path in copied configs
home_sed="${HOME//&/\\&}"
for f in ~/.config/waybar/config.jsonc ~/.config/niri/config.kdl ~/.config/niri/wallpaper.sh; do
    [ -f "$f" ] && sed -i "s|/home/mark|$home_sed|g" "$f"
done

# Make all local scripts executable
echo "--- Making all local scripts executable ---"
if [ -n "$(ls -A ~/.local/bin 2>/dev/null)" ]; then
    chmod +x ~/.local/bin/*
fi

# Copy Wallpapers
echo "--- Setting up Wallpapers ---"
if [ -d "./wallpaper" ] && [ -n "$(ls -A ./wallpaper 2>/dev/null)" ]; then
    cp -v ./wallpaper/* ~/Pictures/Wallpapers/
else
    echo "Warning: No wallpaper found."
fi

# Extract themes
echo "--- Extracting themes ---"
for f in ./themes/*.zip; do
    sudo unzip -o -q "$f" -d /usr/share/themes
done

# desktop-portal
cat <<EOF > ~/.config/xdg-desktop-portal/portals.conf
[preferred]
default=gtk
org.freedesktop.impl.portal.ScreenCast=gnome
org.freedesktop.impl.portal.Screenshot=gnome
org.freedesktop.impl.portal.Secret=gnome-keyring
org.freedesktop.impl.portal.GlobalShortcuts=gnome
EOF


# Fish Config // reload waybar
FISH_CONFIG="$HOME/.config/fish/config.fish"
if [ -f "$FISH_CONFIG" ] && ! grep -q '^# arch-config managed$' "$FISH_CONFIG"; then
    cp -v "$FISH_CONFIG" "$FISH_CONFIG.bak.$(date +%Y%m%d%H%M%S)"
fi

cat <<'EOF' > "$FISH_CONFIG"
# arch-config managed
# Export Flatpak paths
if not set -q XDG_DATA_DIRS
    set -gx XDG_DATA_DIRS /usr/local/share:/usr/share
end
set -gx XDG_DATA_DIRS $XDG_DATA_DIRS:$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share

fish_add_path ~/.local/bin

function rwb
    killall waybar
    waybar > /dev/null 2>&1 &
    disown
    echo "Waybar reloaded!"
end
EOF

# Bash Config
BASHRC="$HOME/.bashrc"
if ! grep -q 'flatpak/exports/share' "$BASHRC" 2>/dev/null; then
    cat <<'EOF' >> "$BASHRC"

# arch-config: Flatpak paths
export XDG_DATA_DIRS=${XDG_DATA_DIRS:-/usr/local/share:/usr/share}:$HOME/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share
EOF
fi
if ! grep -qF '$HOME/.local/bin' "$BASHRC" 2>/dev/null; then
    cat <<'EOF' >> "$BASHRC"

# arch-config: local bin
export PATH=$PATH:$HOME/.local/bin
EOF
fi

# Fish plugins
echo "--- Installing Fish Plugins ---"
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
fish -c "fisher install IlanCosman/tide@v6"

# Basic setting/service
sudo usermod -aG wheel,video,storage "$USER_NAME"

run_gsettings() {
    if [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ] || ! command -v dbus-run-session >/dev/null 2>&1; then
        gsettings "$@"
    else
        dbus-run-session -- gsettings "$@"
    fi
}

run_gsettings set org.gnome.desktop.wm.preferences button-layout ":"
if [ -f /usr/lib/thunarx-3/thunar-wallpaper-plugin.so ]; then
    sudo mv /usr/lib/thunarx-3/thunar-wallpaper-plugin.so /usr/lib/thunarx-3/thunar-wallpaper-plugin.so.disabled
fi

# Set GTK theme for Wayland apps
run_gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark"
run_gsettings set org.gnome.desktop.interface icon-theme "Numix-Circle"
run_gsettings set org.gnome.desktop.interface font-name "Inter 11"
run_gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

# Remove the old global overrides that broke the screencast portal and conflicted with niri
if [ -f /etc/environment ]; then
    sudo sed -i -e '/^QT_QPA_PLATFORMTHEME=qt5ct$/d' -e '/^GDK_BACKEND=wayland,x11$/d' /etc/environment
fi

# Use the packaged niri session entry (niri-session) instead of the old Exec=niri override
if [ -f /usr/share/wayland-sessions/niri.desktop ] && grep -qx 'Exec=niri' /usr/share/wayland-sessions/niri.desktop; then
    sudo sed -i -e 's|^Exec=niri$|Exec=niri-session|' -e 's|^DesktopNames=Niri$|DesktopNames=niri|' /usr/share/wayland-sessions/niri.desktop
fi

# lightdm
sudo systemctl enable lightdm.service

sudo mkdir -p /usr/share/pixmaps/lightdm
if [ -d "./lightdm" ]; then
    sudo cp -rv ./lightdm/* /usr/share/pixmaps/lightdm/
    sudo chmod 755 /usr/share/pixmaps/lightdm
    sudo find /usr/share/pixmaps/lightdm -maxdepth 1 -type f -exec chmod 644 {} +
fi

# Overwrite (don't append) to ensure clean config
cat <<EOF | sudo tee /etc/lightdm/lightdm.conf
[LightDM]
run-directory=/run/lightdm

[Seat:*]
greeter-session=lightdm-slick-greeter
session-wrapper=/etc/lightdm/Xsession
user-session=niri
EOF

# Slick Greeter
cat <<EOF | sudo tee /etc/lightdm/slick-greeter.conf
[Greeter]
background=/usr/share/pixmaps/lightdm/bg.jpg
theme-name=adw-gtk3-dark
icon-theme-name=Numix-Circle
font-name=Inter 10
EOF
