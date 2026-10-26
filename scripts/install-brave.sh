#!/bin/bash

# Install brave
yay -S --noconfirm --needed brave-bin

# make brave the default browser
xdg-settings set default-web-browser brave.desktop