#!/bin/bash

sudo pacman -S virtualbox-guest-utils
sudo systemctl enable --now vboxservice.service