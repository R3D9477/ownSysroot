#!/bin/bash

function mount_sysroot() {

    preAuthRoot && sudo mount -o bind "/proc" "${SYSROOT}/proc"
}

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if [ -f "${CACHE}/sysroot_ubuntu1804_base.tar" ]; then

    if ( preAuthRoot && sudo tar -C "${SYSROOT}" -xf "${CACHE}/sysroot_ubuntu1804_base.tar" --strip-components=1 ) ; then

        if ( preAuthRoot && sudo chmod -R +r "${SYSROOT}" ) ; then

            preAuthRoot && sudo cp "/usr/bin/qemu-arm-static" "${SYSROOT}/usr/bin"
            mount_sysroot

            echo ""
            echo ">>> Root filesystem was successfully extracted"
            echo ""

            exit 0
        fi
    fi

    exit 1
fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

preAuthRoot && sudo debootstrap --arch=armhf --foreign bionic "${SYSROOT}" "http://ports.ubuntu.com"

preAuthRoot && sudo cp "/usr/bin/qemu-arm-static" "${SYSROOT}/usr/bin"
mount_sysroot

preAuthRoot && sudo chroot "${SYSROOT}" "/debootstrap/debootstrap" --second-stage

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

preAuthRoot && echo "deb http://ports.ubuntu.com/ubuntu-ports/ bionic main restricted universe multiverse"          | sudo tee    "${SYSROOT}/etc/apt/sources.list"
preAuthRoot && echo "deb http://ports.ubuntu.com/ubuntu-ports/ bionic-updates main restricted universe multiverse"  | sudo tee -a "${SYSROOT}/etc/apt/sources.list"
preAuthRoot && echo "deb http://ports.ubuntu.com/ubuntu-ports/ bionic-security main restricted universe multiverse" | sudo tee -a "${SYSROOT}/etc/apt/sources.list"

preAuthRoot && sudo chroot "${SYSROOT}" apt update
preAuthRoot && sudo chroot "${SYSROOT}" apt upgrade -y

preAuthRoot && sudo chroot "${SYSROOT}" apt autoremove -y
preAuthRoot && sudo chroot "${SYSROOT}" apt clean -y

preAuthRoot && sudo chroot "${SYSROOT}" apt remove linux-boundary* linux-headers-* linux-image-* -y

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

preAuthRoot && sudo tar \
    --exclude="/proc"   \
    -C "${SYSROOT}/.." -cf "${CACHE}/sysroot_ubuntu1804_base.tar" "sysroot"
