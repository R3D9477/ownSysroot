#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

try_to_extract_sysroot "sysroot_debian10_base"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

preAuthRoot && sudo debootstrap --arch=armhf --foreign buster "${SYSROOT}" "http://deb.debian.org/debian"

preAuthRoot && sudo cp "/usr/bin/qemu-arm-static" "${SYSROOT}/usr/bin"
mount_sysroot

preAuthRoot && sudo chroot "${SYSROOT}" "/debootstrap/debootstrap" --second-stage

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

if [ -f "${SYSROOT}/etc/apt/sources.list" ] ; then
    preAuthRoot && sudo cp "${SYSROOT}/etc/apt/sources.list" "${SYSROOT}/etc/apt/sources.list.bck"
fi

preAuthRoot && echo "
deb http://httpredir.debian.org/debian buster main contrib non-free
deb-src http://httpredir.debian.org/debian buster main contrib non-free
deb http://httpredir.debian.org/debian buster-backports main contrib non-free
deb-src http://httpredir.debian.org/debian buster-backports main contrib non-free
" | sudo tee "${SYSROOT}/etc/apt/sources.list"

### raise backports priority
preAuthRoot && echo "
Package: *
Pin: release n=buster-backports
Pin-Priority: 500
" | sudo tee "${SYSROOT}/etc/apt/preferences.d/backports"

if ! (preAuthRoot && sudo chroot "${SYSROOT}" apt update ) ; then exit 1 ; fi
preAuthRoot && sudo chroot "${SYSROOT}" apt upgrade -y

preAuthRoot && sudo chroot "${SYSROOT}" apt autoremove -y
preAuthRoot && sudo chroot "${SYSROOT}" apt clean -y
preAuthRoot && sudo chroot "${SYSROOT}" apt remove linux-boundary* linux-headers-* linux-image-* -y

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

install_deb_pkgs      \
    pkg-config        \
    python-minimal    \
    exfat-utils       \
    exfat-fuse        \
    v4l-utils         \
    net-tools         \
    libc6-dev         \
    ifupdown          \
    systemd           \
    locales           \
    rfkill            \
    fbset             \
    nano              \
    lshw              \

preAuthRoot && sudo chroot "${SYSROOT}" chmod +s "/sbin/mount.fuse"
preAuthRoot && sudo chroot "${SYSROOT}" chmod +s "/sbin/mount.exfat"
preAuthRoot && sudo chroot "${SYSROOT}" chmod +s "/sbin/mount.exfat-fuse"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

make_sysroot_package "sysroot_debian10_base"
