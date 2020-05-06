#!/bin/bash

if ! pushd "${CACHE}/linux-${KERNEL_BRANCH}" ; then exit 1; fi

    if ! ( preAuthRoot && sudo cp -v arch/arm/boot/zImage "${BOOT}/" )    ; then exit 2 ; fi
    if ! ( preAuthRoot && sudo cp -v arch/arm/boot/dts/*.dtb "${BOOT}/" ) ; then exit 3 ; fi

    if ! ( preAuthRoot && sudo make ARCH=${ARCH} CROSS_COMPILE="${TOOLCHAIN_PREFIX}" modules_install INSTALL_MOD_PATH="${SYSROOT}" ) ; then exit 4 ; fi
    if ! ( preAuthRoot && sudo make ARCH=${ARCH} CROSS_COMPILE="${TOOLCHAIN_PREFIX}" headers_install INSTALL_HDR_PATH="${SYSROOT}" ) ; then exit 5 ; fi

popd

pushd "${USERDIR}"
    if ! [ -z "${KERNEL_POSTINSTALL}" ] ; then
        if ! ( eval ${KERNEL_POSTINSTALL} ) ; then exit 6 ; fi
    fi
popd
