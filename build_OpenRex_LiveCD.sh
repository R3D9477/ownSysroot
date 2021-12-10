#!/bin/bash

source "core/00-func.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
# IMAGE BUILDING --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

    # OVERRIDE SETTINGS
    
exportdefvar REMOVE_IMG             y
exportdefvar FLASH_IMG              n

    # OVERRIDE INSTALLATION PATH (install_deb_MMC_flasher.sh) & USB-OTG storage (configure_usbotg.sh)
    
exportdefvar HOST_MMC               "/dev/mmcblk3"  # 8-bit SD4
exportdefvar DEV_FSTAB_MMC_PREFIX   "mmcblk3p"      # 8-bit SD4

    # RUN SYSROOT BUILDING SCRIPT

source "build_OpenRex.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
# LIVECD+INSTALLER --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- - --- --

    # OVERRIDE SETTINGS

export IMG_MMC_FL="${IMG_NAME}"
export REMOVE_IMG=n
export IMG_SIZE_MB="$((IMG_SIZE_MB+1000))"
export IMG_NAME=$(basename "${IMG_MMC_FL%.*}")"-livecd.img"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
# LIVECD IMAGE BUILDING --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

source "core/00-init.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

    # BUILD BASE IMAGE

clean_all "${REMOVE_IMG}"

pushd "${COREDIR}"
    if ! ( bash "03-create_bootable_img.sh" )               ; then goto_exit 001 ; fi
    if ! ( bash "04-mount_img.sh" )                         ; then goto_exit 002 ; fi
    if ! ( bash "05-sysroot_debian10_base.sh" )             ; then goto_exit 003 ; fi
    if ! ( bash "07-install_kernel.sh" )                    ; then goto_exit 004 ; fi
    if ! ( bash "08-install_uboot.sh" )                     ; then goto_exit 005 ; fi
    if ! ( bash "09-configure_sysroot.sh" )                 ; then goto_exit 006 ; fi
popd

pushd "${USERDIR}"
    if ! ( bash "configure_autologin.sh" )                  ; then goto_exit 101 ; fi
    if ! ( bash "configure_disable_eth.sh" )                ; then goto_exit 102 ; fi
    if ! ( bash "install_deb_mtd_uboot.sh" )                ; then goto_exit 103 ; fi
    if ! ( bash "install_deb_MMC_flasher.sh" )              ; then goto_exit 104 ; fi
popd

clean_all

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

    # MAKE BOOTABLE DRVIE

unset  HOST_MMC_BOOT
unset  HOST_MMC_SYSROOT
unset  DEV_MAKE_STORAGE
unset  DEV_STORAGE_FS
unset  DEV_FSTAB_MMC_PREFIX
unset  DEV_POSTCONFIG # copy all posconfig scripts into LiveCD, then run them through the "install_MMC_flasher.sh"

export HOST_MMC="/dev/sdb"
export FLASH_IMG=y

if [ "${FLASH_IMG}" != "n" ] ; then
    if ! ( bash "core/10-flash_image.sh" )                  ; then goto_exit 301 ; fi
fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

show_message "DONE ; target image -- ${IMG_NAME}"
goto_exit 0
