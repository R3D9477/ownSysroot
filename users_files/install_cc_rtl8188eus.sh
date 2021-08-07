#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

exportdefvar rtl8188eus_GITURL      "https://github.com/aircrack-ng"
exportdefvar rtl8188eus_GITREPO     "rtl8188eus"
exportdefvar rtl8188eus_BRANCH      "v5.3.9"
exportdefvar rtl8188eus_REVISION    ""
exportdefvar rtl8188eus_RECOMPILE   n

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# GET PACKAGES --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! ( get_git_pkg "${rtl8188eus_GITURL}" "${rtl8188eus_GITREPO}" "${rtl8188eus_BRANCH}" "${rtl8188eus_REVISION}" ) ; then goto_exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# INSTALL PACKAGES - --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

if ! pushd "${CACHE}/${rtl8188eus_GITREPO}-${rtl8188eus_BRANCH}" ; then goto_exit 2 ; fi

    KVER=$(cd "${SYSROOT}/lib/" && ls "modules")
    KERNEL_DIR=$(realpath -s "${SYSROOT}/lib/modules/${KVER}/build")

    # MAKE

    if ( [ "${rtl8188eus_RECOMPILE}" != "n" ] || ! [ -f "8188eu.ko" ] ) ; then

        make clean
        if ! make ARCH="${ARCH}" CROSS_COMPILE="${TOOLCHAIN_PREFIX}" KSRC="${KERNEL_DIR}" KERNEL_SRC="${KERNEL_DIR}" ${NJ} ; then exit 3 ; fi
    fi

    # INSTALL

    preAuthRoot && sudo cp "8188eu.ko" "${SYSROOT}/opt/"
    preAuthRoot && sudo mkdir -p "${SYSROOT}/lib/modules/${KVER}/kernel/drivers/net/wireless/"
    
    if ! ( preAuthRoot && sudo chroot "${SYSROOT}" install -p -m 644 "/opt/8188eu.ko" "/lib/modules/${KVER}/kernel/drivers/net/wireless/" ) ; then exit 4 ; fi
    if ! ( preAuthRoot && sudo chroot "${SYSROOT}" depmod -a "${KVER}" ) ; then exit 5 ; fi
    
    preAuthRoot && sudo rm "${SYSROOT}/opt/8188eu.ko"
    
    preAuthRoot && echo "blacklist r8188eu" | sudo tee "${SYSROOT}/etc/modprobe.d/50-8188eu.conf"
    preAuthRoot && echo "options 8188eu rtw_power_mgnt=0 rtw_enusbss=0" | sudo tee -a "${SYSROOT}/etc/modprobe.d/50-8188eu.conf"

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

show_message "RTL8188EU WAS SUCCESSFULLY INSTALLED!"
