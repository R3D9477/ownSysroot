#!/bin/bash

show_message "$(basename $0)"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

if ! pushd "${CACHE}/${KERNEL_GITREPO}-${KERNEL_BRANCH}" ; then goto_exit 1; fi

    preAuthRoot && sudo rm -rf "${BOOT}"/*Image
    preAuthRoot && sudo rm -rf "${BOOT}"/*.dtb
    preAuthRoot && sudo rm -rf "${SYSROOT}/lib/modules"

    if [ -f "arch/arm/boot/zImage" ] ; then
        if ! ( preAuthRoot && sudo cp -v "arch/arm/boot/zImage" "${BOOT}/" )    ; then goto_exit 2 ; fi
    else
        if ! ( preAuthRoot && sudo cp -v "arch/arm/boot/Image" "${BOOT}/" )     ; then goto_exit 2 ; fi
    fi
    
    if ! ( preAuthRoot && sudo cp -v "arch/arm/boot/dts"/*.dtb "${BOOT}/" )     ; then goto_exit 3 ; fi

    if ! ( preAuthRoot && sudo make ARCH=${ARCH} CROSS_COMPILE="${TOOLCHAIN_PREFIX}" modules_install INSTALL_MOD_PATH="${SYSROOT}" ) ; then goto_exit 4 ; fi
    if ! ( preAuthRoot && sudo make ARCH=${ARCH} CROSS_COMPILE="${TOOLCHAIN_PREFIX}" headers_install INSTALL_HDR_PATH="${SYSROOT}" ) ; then goto_exit 5 ; fi

popd

pushd "${USERDIR}"
    if ! [ -z "${KERNEL_POSTINSTALL}" ] ; then
        if ! ( eval ${KERNEL_POSTINSTALL} ) ; then goto_exit 6 ; fi
    fi
popd
