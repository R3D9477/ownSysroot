#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

try_to_extract_sysroot "sysroot_debian11_Qt"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

if ! bash "${COREDIR}"/*sysroot_debian11_base.sh ; then showElapsedTime ; goto_exit 2 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

# Qt5 dependencies

install_deb_pkgs    \
    libudev-dev     \
    libjpeg-dev     \
    libpng-dev      \
    libgbm-dev      \
    libc6-dev       \
    libglib2.0-dev

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

make_sysroot_package "sysroot_debian11_Qt"
