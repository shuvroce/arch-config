function clean_arch
    set orphans (pacman -Qtdq)
    if test -n "$orphans"
        echo "Removing orphaned packages..."
        sudo pacman -Rns $orphans
    else
        echo "No orphans found."
    end
    echo "Cleaning journal logs older than 2 days..."
    sudo journalctl --vacuum-time=2d
end