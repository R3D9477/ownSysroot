#!/bin/bash

exportdefvar HOST_MMC_BOOT      ""
exportdefvar HOST_MMC_SYSROOT   ""

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

install_deb_pkgs    \
    debootstrap     \
    exfat-utils     \
    mmc-utils       \
    binutils        \
    kpartx          \
    fdisk           \
    lzop            \
    sudo            \
    pv

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

FN=$(basename "${IMG_MMC_FL}")
DN="${FN%.*}"

preAuthRoot && sudo rm -rf   "${SYSROOT}/opt/${DN}"
preAuthRoot && sudo mkdir -p "${SYSROOT}/opt/${DN}"

show_message "INSTALL IMAGE: ${IMG_MMC_FL}"

if ( [ "${HOST_MMC_BOOT}" ] && [ "${HOST_MMC_SYSROOT}" ] ) ; then

    if ! ( preAuthRoot && sudo kpartx -av "${IMG_MMC_FL}" ) ; then goto_exit 1 ; fi
    sleep 3s ; sync

    preAuthRoot && readarray -t DEVARR <<< "$(sudo kpartx -l ${IMG_MMC_FL})"

    i=0
    while [[ ${DEVARR[$i]} ]] ; do

        OUT_DEV=`echo $(echo ${DEVARR[$i]} | awk '{print $1}')`
        OUT_IMG="${SYSROOT}/opt/${DN}/${DN}_${OUT_DEV}.img"

        show_message "INSTALL: /dev/mapper/${OUT_DEV} --> ${SYSROOT}/opt/${DN}/${DN}_${OUT_DEV}.img"

        if ! ( preAuthRoot && sudo dd if="/dev/mapper/${OUT_DEV}" of="${SYSROOT}/opt/${DN}/${DN}_${OUT_DEV}.img" ) ; then goto_exit 2 ; fi

        i=$((i+1))

        if ( ! [ "${IMG_BOOT}" ] || ! [ "${HOST_MMC_BOOT}" ] ) ; then
            IMG_BOOT="/opt/${DN}/${DN}_${OUT_DEV}.img"
            HOST_MMC_BOOT="${HOST_MMC_BOOT}"
        elif ( ! [ "${IMG_SYSROOT}" ] || ! [ "${HOST_MMC_SYSROOT}" ] ) ; then
            IMG_SYSROOT="/opt/${DN}/${DN}_${OUT_DEV}.img"
            HOST_MMC_SYSROOT="${HOST_MMC_SYSROOT}"
        fi
    done

else
    if ! ( preAuthRoot && sudo install -m 0755 "${IMG_MMC_FL}" "${SYSROOT}/opt/${DN}/" ) ; then goto_exit 3 ; fi
    unset IMG_BOOT
    unset HOST_MMC_BOOT
    IMG_SYSROOT="/opt/${DN}/${FN}"
    HOST_MMC_SYSROOT="${HOST_MMC}"
fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

if [ -f "${CACHE}/u-boot-${UBOOT_BRANCH}/u-boot.bin" ] ; then
    if ! ( preAuthRoot && sudo install -m 0755 "${CACHE}/u-boot-${UBOOT_BRANCH}/u-boot.bin" "${SYSROOT}/opt/${DN}/" ) ; then goto_exit 4 ; fi
fi

if [ -f "${CACHE}/u-boot-${UBOOT_BRANCH}/u-boot.imx" ] ; then
    if ! ( preAuthRoot && sudo install -m 0755 "${CACHE}/u-boot-${UBOOT_BRANCH}/u-boot.imx" "${SYSROOT}/opt/${DN}/" ) ; then goto_exit 4 ; fi
fi

if ! ( preAuthRoot && sudo install -m 0755 "${COREDIR}"/*func.sh        "${SYSROOT}/opt/${DN}/" ) ; then goto_exit 5 ; fi
if ! ( preAuthRoot && sudo install -m 0755 "${COREDIR}"/*flash_image.sh "${SYSROOT}/opt/${DN}/" ) ; then goto_exit 6 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

preAuthRoot && echo "#!/bin/bash
source *func.sh

exportdefvar USERDIR                \"/opt\"
exportdefvar SYSROOT                \"/tmp/mmc_flasher_mount/sysroot\"

exportdefvar IMG_BOOT               \"${IMG_BOOT}\"
exportdefvar HOST_MMC_BOOT          \"${HOST_MMC_BOOT}\"

exportdefvar IMG_SYSROOT            \"${IMG_SYSROOT}\"
exportdefvar HOST_MMC_SYSROOT       \"${HOST_MMC_SYSROOT}\"

exportdefvar DEV_MAKE_STORAGE       ${DEV_MAKE_STORAGE}
exportdefvar DEV_FSTAB_MMC_PREFIX   \"${DEV_FSTAB_MMC_PREFIX}\"

exportdefvar DEV_STORAGE_FS         \"${DEV_STORAGE_FS}\"
exportdefvar DEV_STORAGE_LBL        \"${DEV_STORAGE_LBL}\"

exportdefvar DEV_USBOTG             ${DEV_USBOTG}
exportdefvar DEV_USBOTG_AUTOINSERT  ${DEV_USBOTG_AUTOINSERT}

exportdefvar DEV_POSTCONFIG         \"${DEV_POSTCONFIG}\"

/bin/bash /opt/${DN}/*flash_image.sh" | sudo tee -a "${SYSROOT}/opt/${DN}/install.sh"

if ! ( preAuthRoot && sudo chmod +x "${SYSROOT}/opt/${DN}/install.sh" ) ; then goto_exit 7 ; fi
