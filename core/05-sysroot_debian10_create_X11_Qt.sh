#!/bin/bash

function mount_sysroot() {

    preAuthRoot && sudo mount -o bind "/proc" "${SYSROOT}/proc"
}

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if [ -f "${CACHE}/sysroot_debian10_X11_Qt.tar" ]; then

    if ( preAuthRoot && sudo tar -C "${SYSROOT}" -xf "${CACHE}/sysroot_debian10_X11_Qt.tar" --strip-components=1 ) ; then

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

if ! bash "${COREDIR}"/*sysroot_debian10_create_Qt.sh ; then showElapsedTime ; exit 2 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

# X11

install_deb_pkgs                        \
    fbset                               \
    xorg                                \
    xserver-xorg                        \
    xserver-common                      \
    xserver-xorg-core                   \
    xserver-xorg-video-fbdev            \
    libdrm-etnaviv1                     \
    libgl1-mesa-dri                     \
    mesa-utils

# Qt5 dependencies

install_deb_pkgs                        \
    "^libxcb.*"                         \
    libx11-xcb-dev                      \
    libglu1-mesa-dev                    \
    libxrender-dev

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

preAuthRoot && sudo tar \
    --exclude="/proc"   \
    -C "${SYSROOT}/.." -cf "${CACHE}/sysroot_debian10_X11_Qt.tar" "sysroot"
