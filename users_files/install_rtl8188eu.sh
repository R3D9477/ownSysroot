#!/bin/bash

if [ -z "${rtl8188eu_BRANCH}"    ] ; then export rtl8188eu_BRANCH="v5.2.2.4" ; fi
if [ -z "${rtl8188eu_RECOMPILE}" ] ; then export rtl8188eu_RECOMPILE="n"     ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# GET PACKAGES --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

rtl8188eu_GIT_URL="https://github.com/lwfinger"

if ! ( get_git_pkg "${rtl8188eu_GIT_URL}" "rtl8188eu" "${rtl8188eu_BRANCH}" ) ; then exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# INSTALL PACKAGES - --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

if ! pushd "${CACHE}/rtl8188eu-${rtl8188eu_BRANCH}" ; then exit 2 ; fi

    KVER=$(cd "${SYSROOT}/lib/" && ls "modules")
    KERNEL_DIR=$(realpath -s "${SYSROOT}/lib/modules/${KVER}/build")

    # MAKE

    if ( [ "${rtl8188eu_RECOMPILE}" != "n" ] || ! [ -f "8188eu.ko" ] ) ; then

        sed -i 's|KSRC :=|KSRC ?=|g' Makefile
        sed -i 's|KERNEL_SRC :=|KERNEL_SRC ?=|g' Makefile

        make clean
        if ! make ARCH="${ARCH}" CROSS_COMPILE="${TOOLCHAIN_PREFIX}" KSRC="${KERNEL_DIR}" KERNEL_SRC="${KERNEL_DIR}" ${NJ} ; then exit 3 ; fi
    fi

    # INSTALL

    preAuthRoot && sudo cp "8188eu.ko" "${SYSROOT}/opt/"
    preAuthRoot && sudo mkdir -p "${SYSROOT}/lib/modules/${KVER}/kernel/drivers/net/wireless/"
    
    if ! ( preAuthRoot && sudo chroot "${SYSROOT}" install -p -m 644 "/opt/8188eu.ko" "/lib/modules/${KVER}/kernel/drivers/net/wireless/" ) ; then exit 4 ; fi
    if ! ( preAuthRoot && sudo chroot "${SYSROOT}" depmod -a "${KVER}" ) ; then exit 5 ; fi
    
    preAuthRoot && sudo rm "${SYSROOT}/opt/8188eu.ko"

    preAuthRoot && sudo mkdir -p "${SYSROOT}/lib/firmware/rtlwifi"
    preAuthRoot && sudo cp "rtl8188eufw.bin" "${SYSROOT}/lib/firmware/rtlwifi/"
    preAuthRoot && sudo chroot "${SYSROOT}" chmod -R +x "/lib/firmware/rtlwifi"

    preAuthRoot && echo "blacklist r8188eu" | sudo tee "${SYSROOT}/etc/modprobe.d/50-8188eu.conf"

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

show_message "RTL8188EU WAS SUCCESSFULLY INSTALLED!"
