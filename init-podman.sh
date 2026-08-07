#! /usr/bin/bash

sudo apt update && sudo apt install flatpak
sudo apt install podman
echo 'export XDG_DATA_DIRS="$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:/home/ubuntu/.local/share/flatpak/exports/share"' >> ~/.bashrc

sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
sudo flatpak install flathub io.podman_desktop.PodmanDesktop
