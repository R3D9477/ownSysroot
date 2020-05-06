#!/bin/bash

function mount_sysroot() {

    preAuthRoot && sudo mount -o bind "/proc" "${SYSROOT}/proc"
}

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if [ -f "${CACHE}/sysroot_debian10_Qt.tar" ]; then

    if ( preAuthRoot && sudo tar -C "${SYSROOT}" -xf "${CACHE}/sysroot_debian10_Qt.tar" --strip-components=1 ) ; then

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

if ! bash "${COREDIR}"/*sysroot_debian10_create_base.sh ; then showElapsedTime ; exit 2 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

# System tools

install_deb_pkgs                        \
    systemd                             \
    rfkill                              \
    nano                                \
    fbset                               \
    lshw                                \
    ifupdown                            \
    net-tools                           \
    hostapd                             \
    wireless-tools                      \
    isc-dhcp-server                     \
    python-minimal

# GStreamer dependencies

install_deb_pkgs                        \
    gstreamer1.0-plugins-bad            \
    libgstreamer-plugins-bad1.0-dev     \
    gstreamer1.0-plugins-base           \
    libgstreamer-plugins-base1.0-dev    \
    gstreamer1.0-plugins-base-apps      \
    gstreamer1.0-plugins-good           \
    libgstreamer1.0-0                   \
    libgstreamer1.0-dev                 \
    gstreamer1.0-tools                  \
    libpango1.0-dev                     \
    libcairo2-dev

# Qt5 dependencies

install_deb_pkgs                        \
    libc6-dev                           \
    libgbm-dev                          \
    libudev-dev                         \
    libjpeg-dev                         \
    libpng-dev

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

preAuthRoot && sudo tar \
    --exclude="/proc"   \
    -C "${SYSROOT}/.." -cf "${CACHE}/sysroot_debian10_Qt.tar" "sysroot"
