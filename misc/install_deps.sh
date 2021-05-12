#!/bin/bash

apt install libncurses-dev

apt install bc sudo dosfstools pkg-config

apt install fdisk kpartx qemu qemu-user-static git debootstrap lzop pv exfat-utils

apt install xz-utils flex bison autoconf-archive python-dev libglib2.0-dev libmount-dev
apt install python3 python3-pip python3-setuptools python3-wheel ninja-build nasm

mkdir -p "$HOME/.local/bin"
if [ -z `cat "$HOME/.profile" | grep .local/bin` ] ; then echo 'PATH="$PATH:$HOME/.local/bin"' | tee -a "$HOME/.profile" ; fi
export PATH="$PATH:$HOME/.local/bin"
pip3 install --user meson
