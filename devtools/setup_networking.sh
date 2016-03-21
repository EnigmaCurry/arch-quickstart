#!/bin/bash

# Functions to display commands
exe() { echo "\$ $@" ; "$@" ; }
exe_true() { echo "\$ $@" ; "$@" || true ; }

# Stop DHCP clients:
exe ip -o link show | awk -F': ' '{print $2}' | xargs -iXX systemctl stop dhcpcd@XX

# Start ssh:
exe pacman -Sy
exe pacman --noconfirm -S openssh
exe systemctl start sshd
exe echo "root:root" | chpasswd

echo "SSH server started with root password 'root'"
