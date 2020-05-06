#!/bin/bash

function mount_sysroot() {

    preAuthRoot && sudo mount -o bind "/proc" "${SYSROOT}/proc"
}

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if [ -f "${CACHE}/sysroot_ubuntu1804_X11.tar" ]; then

    if ( preAuthRoot && sudo tar -C "${SYSROOT}" -xf "${CACHE}/sysroot_ubuntu1804_X11.tar" --strip-components=1 ) ; then

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

if ! bash "${COREDIR}"/*sysroot_ubuntu1804_create_base.sh ; then showElapsedTime ; exit 2 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

install_deb_pkgs                \
    systemd                     \
    rfkill                      \
    nano                        \
    lshw                        \
    ifupdown                    \
    net-tools                   \
    hostapd                     \
    wireless-tools              \
    isc-dhcp-server

install_deb_pkgs                \
    xorg                        \
    xserver-xorg                \
    xserver-common              \
    xserver-xorg-core           \
    xserver-xorg-video-fbdev    \
    libdrm-etnaviv1             \
    libgl1-mesa-dri             \
    mesa-utils

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

preAuthRoot && sudo tar \
    --exclude="/proc"   \
    -C "${SYSROOT}/.." -cf "${CACHE}/sysroot_ubuntu1804_X11.tar" "sysroot"
