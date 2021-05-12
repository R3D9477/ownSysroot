#!/bin/bash

show_message "$(basename $0)"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

try_to_extract_sysroot "sysroot_debian10_X11_Qt"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

if ! bash "${COREDIR}"/*sysroot_debian10_create_Qt.sh ; then showElapsedTime ; exit 2 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

# X11

install_deb_pkgs                        \
    xinit                               \
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

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

make_sysroot_package "sysroot_debian10_X11_Qt"
