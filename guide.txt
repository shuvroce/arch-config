#### Config / customize

gnome-portal:
    mkdir -p ~/.config/xdg-desktop-portal
    nano ~/.config/xdg-desktop-portal/portals.conf
        [preferred]
        default=wlr;gtk
        org.freedesktop.impl.portal.Screencast=gnome
        org.freedesktop.impl.portal.Screenshot=gnome

grub:
    copy <theme-folder> with root priviledge to /boot/grub/themes/
    nano /etc/default/grub
        GRUB_THEME=/boot/grub/themes/<theme-folder>/theme.txt
    sudo grub-mkconfig -o /boot/grub/grub.cfg

lightdm:
    sudo mkdir -p /usr/share/pixmaps/lightdm
    
    copy bg.jpg and user.png with root priviledge to /usr/share/pixmaps/lightdm
    
    sudo micro /etc/lightdm/lightdm.conf
        [Seat:*]
        greeter-session=lightdm-gtk-greeter

    sudo micro /etc/lightdm/lightdm-gtk-greeter.conf
        [greeter]
        background=/usr/share/pixmaps/lightdm/bg.jpg
        theme-name=adw-gtk3-dark
        icon-theme-name=Numix-Circle
        font-name=Inter 10
        default-user-image=/usr/share/pixmaps/lightdm/user.png
        round-user-image=true


## auto mount external drive
sudo mkdir -p /mnt/external_drive
sudo micro /etc/fstab

sudo systemctl daemon-reload
sudo mount -a

sudo chown $USER:$USER /mnt/external_drive      # for ext4
sudo chmod -R 755 /mnt/external_drive           # for ext4


## For virtualbox
sudo pacman -S virtualbox-guest-utils
sudo systemctl enable --now vboxservice.service
