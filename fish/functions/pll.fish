function pll
    # %l: install date, %n: name, %v: version
    # Sort sorts by the date string at the start
    # expac --timefmt='%Y-%m-%d %T' '%l  %-30n %v' $(pacman -Qeq) | sort | tail -n40
    expac --timefmt='%Y-%m-%d %T' '%l  %-30n %v' $(pacman -Qeq) | sort
end