#! /usr/bin/bash

init_swap() {
  fallocate -l 8G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
}

apply_swap() {
  cp /etc/fstab /etc/fstab.bak
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
}

show_info() {
  sudo swapon --show
  free -h
}

how_info
init_swap
apply_swap
show_info
