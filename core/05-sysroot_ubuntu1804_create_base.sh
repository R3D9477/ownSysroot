#!/bin/bash

show_message "$(basename $0)"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

try_to_extract_sysroot "sysroot_ubuntu1804_base"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

preAuthRoot && sudo debootstrap --arch=armhf --foreign bionic "${SYSROOT}" "http://ports.ubuntu.com"

preAuthRoot && sudo cp "/usr/bin/qemu-arm-static" "${SYSROOT}/usr/bin"
mount_sysroot

preAuthRoot && sudo chroot "${SYSROOT}" "/debootstrap/debootstrap" --second-stage

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

preAuthRoot && echo "deb http://ports.ubuntu.com/ubuntu-ports/ bionic main restricted universe multiverse"          | sudo tee    "${SYSROOT}/etc/apt/sources.list"
preAuthRoot && echo "deb http://ports.ubuntu.com/ubuntu-ports/ bionic-updates main restricted universe multiverse"  | sudo tee -a "${SYSROOT}/etc/apt/sources.list"
preAuthRoot && echo "deb http://ports.ubuntu.com/ubuntu-ports/ bionic-security main restricted universe multiverse" | sudo tee -a "${SYSROOT}/etc/apt/sources.list"

preAuthRoot && sudo chroot "${SYSROOT}" apt update
preAuthRoot && sudo chroot "${SYSROOT}" apt upgrade -y

preAuthRoot && sudo chroot "${SYSROOT}" apt autoremove -y
preAuthRoot && sudo chroot "${SYSROOT}" apt clean -y

preAuthRoot && sudo chroot "${SYSROOT}" apt remove linux-boundary* linux-headers-* linux-image-* -y

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

install_deb_pkgs    \
    libc6-dev       \
	locales         \
    systemd         \
    rfkill          \
    nano            \
    lshw            \
    ifupdown        \
    net-tools       \
    fbset           \
    python-minimal  \
    exfat-fuse      \
    exfat-utils

preAuthRoot && sudo chroot "${SYSROOT}" chmod +s /sbin/mount.fuse
preAuthRoot && sudo chroot "${SYSROOT}" chmod +s /sbin/mount.exfat
preAuthRoot && sudo chroot "${SYSROOT}" chmod +s /sbin/mount.exfat-fuse

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

make_sysroot_package "sysroot_ubuntu1804_base"
