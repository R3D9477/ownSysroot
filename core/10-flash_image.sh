#!/bin/bash

exportdefvar IMG_BOOT                   ""
exportdefvar HOST_MMC_BOOT              ""

exportdefvar IMG_SYSROOT                "${IMG_NAME}"
exportdefvar HOST_MMC_SYSROOT           "${HOST_MMC}"

exportdefvar DEV_MAKE_STORAGE           y
exportdefvar DEV_FSTAB_MMC_PREFIX       "sda"

exportdefvar DEV_STORAGE_FS             "exfat"
exportdefvar DEV_STORAGE_LBL            "STORAGE"
exportdefvar DEV_STORAGE_MNT            "/mnt/storage"

exportdefvar DEV_USBOTG_STATEF          "/sys/class/udc/ci_hdrc.0/state"
exportdefvar DEV_USBOTG_LUNF            "/sys/devices/soc*/soc/2100000.aips-bus/2184000.usb/ci_hdrc.0/gadget/lun0/file"
exportdefvar DEV_USBOTG                 y
exportdefvar DEV_USBOTG_AUTOINS         n

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
# BURN IMAGE --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

show_message "$(basename $0)"

sync_fs

if ( [ "${IMG_BOOT}" ] && [ "${HOST_MMC_BOOT}" ] ) ; then

    show_message "BURN BOOT: ${IMG_BOOT} -> ${HOST_MMC_BOOT}"

    preAuthRoot ; dd if="${IMG_BOOT}" | pv -s $(wc -c < "${IMG_BOOT}") | sudo dd of="${HOST_MMC_BOOT}"
    sync_fs
fi

show_message "BURN SYSROOT: ${IMG_SYSROOT} -> ${HOST_MMC_SYSROOT}"

preAuthRoot ; dd if="${IMG_SYSROOT}" bs=32M | pv -s $(wc -c < "${IMG_SYSROOT}") | sudo dd of="${HOST_MMC_SYSROOT}" bs=32M
sync_fs

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
# MAKE STORAGE IN A FREE SPACE --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----

if [ "${DEV_MAKE_STORAGE}" != "y" ] ; then exit 0 ; fi

if [[ "${HOST_MMC_SYSROOT}" =~ "mmcblk" ]]
    then export HOST_MMC_SYSROOT_p="${HOST_MMC_SYSROOT}p"
    else export HOST_MMC_SYSROOT_p="${HOST_MMC_SYSROOT}"
fi

preAuthRoot && sudo wipefs --force --all "${HOST_MMC_SYSROOT_p}3"
sync_fs

preAuthRoot && sudo sfdisk --force --delete "${HOST_MMC_SYSROOT}" 3
sync_fs

preAuthRoot && echo ",$(sudo sfdisk -s ${HOST_MMC_SYSROOT})" | sudo sfdisk --force --append "${HOST_MMC_SYSROOT}" --no-reread
sync_fs

if [ "${DEV_STORAGE_FS}" == "ext4" ] ; then

    if ! ( preAuthRoot && sudo mkfs.ext4 "${HOST_MMC_SYSROOT_p}3" ) ; then goto_exit 2 ; fi
    sync_fs

    if ! ( preAuthRoot && sudo e2label "${HOST_MMC_SYSROOT_p}3" "${DEV_STORAGE_LBL}" ) ; then goto_exit 2 ; fi
    sync_fs

    if ! ( preAuthRoot && sudo fsck.ext4 -a -w -v "${HOST_MMC_SYSROOT_p}3" ) ; then goto_exit 2 ; fi

    FSTAB_STORAGE_FS="ext4 defaults 0 0"

elif [ "${DEV_STORAGE_FS}" == "exfat" ] ; then

    if ! ( preAuthRoot && sudo mkfs.exfat "${HOST_MMC_SYSROOT_p}3" ) ; then goto_exit 2 ; fi
    sync_fs

    if ! ( preAuthRoot && sudo exfatlabel "${HOST_MMC_SYSROOT_p}3" "${DEV_STORAGE_LBL}" ) ; then goto_exit 2 ; fi
    sync_fs

    if ! ( preAuthRoot && sudo fsck.exfat "${HOST_MMC_SYSROOT_p}3" ) ; then goto_exit 2 ; fi

    FSTAB_STORAGE_FS="exfat-fuse defaults 0 0"

elif [ "${DEV_STORAGE_FS}" == "fat32" ] ; then

    if ! ( preAuthRoot && sudo mkfs.fat -F32 "${HOST_MMC_SYSROOT_p}3" ) ; then goto_exit 2 ; fi
    sync_fs

    if ! ( preAuthRoot && sudo fatlabel "${HOST_MMC_SYSROOT_p}3" "${DEV_STORAGE_LBL}" ) ; then goto_exit 2 ; fi
    sync_fs

    if ! ( preAuthRoot && sudo fsck.fat -a -w -v "${HOST_MMC_SYSROOT_p}3" ) ; then goto_exit 2 ; fi

    FSTAB_STORAGE_FS="vfat defaults 0 0"

else

    show_message "UNKNOWN STORAGE FILESYSTEM: ${DEV_STORAGE_FS}"

    goto_exit 2
fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

if ! [ -z "${DEV_FSTAB_MMC_PREFIX}" ] ; then

    preAuthRoot

       BOOT_UUID=$(sudo blkid -s UUID -o value "${HOST_MMC_SYSROOT_p}1")
    SYSROOT_UUID=$(sudo blkid -s UUID -o value "${HOST_MMC_SYSROOT_p}2")
    STORAGE_UUID=$(sudo blkid -s UUID -o value "${HOST_MMC_SYSROOT_p}3")

    if ( [ -z "${BOOT_UUID}" ] || [ -z "${SYSROOT_UUID}" ] || [ -z "${STORAGE_UUID}" ] ) ; then goto_exit 3 ; fi

    preAuthRoot && sudo mkdir -p "${SYSROOT}"
    if ! ( preAuthRoot && sudo mount "${HOST_MMC_SYSROOT_p}2" "${SYSROOT}" ) ; then goto_exit 4 ; fi

        # SET FSTAB

        if ! ( preAuthRoot && sudo mkdir -p "${SYSROOT}/boot/efi" ) ; then goto_exit 5 ; fi
        if ! ( preAuthRoot && sudo mkdir -p "${SYSROOT}${DEV_STORAGE_MNT}" ) ; then goto_exit 6 ; fi

        if [ -z "${DEV_FSTAB_MMC_PREFIX}" ]
            then preAuthRoot && echo "UUID=${BOOT_UUID} /boot/efi vfat umask=0077 0 1" | sudo tee "${SYSROOT}/etc/fstab"
            else preAuthRoot && echo "/dev/${DEV_FSTAB_MMC_PREFIX}1 /boot/efi vfat umask=0077 0 1" | sudo tee "${SYSROOT}/etc/fstab"
        fi

        if [ -z "${DEV_FSTAB_MMC_PREFIX}" ]
            then preAuthRoot && echo "UUID=${SYSROOT_UUID} / ext4 noatime,errors=remount-ro 0 1" | sudo tee -a "${SYSROOT}/etc/fstab"
            else preAuthRoot && echo "/dev/${DEV_FSTAB_MMC_PREFIX}2 / ext4 errors=remount-ro 0 1" | sudo tee -a "${SYSROOT}/etc/fstab"
        fi

        if [ -z "${DEV_FSTAB_MMC_PREFIX}" ]
            then preAuthRoot && echo "UUID=${STORAGE_UUID} ${DEV_STORAGE_MNT} ${FSTAB_STORAGE_FS}" | sudo tee -a "${SYSROOT}/etc/fstab"
            else preAuthRoot && echo "/dev/${DEV_FSTAB_MMC_PREFIX}3 ${DEV_STORAGE_MNT} ${FSTAB_STORAGE_FS}" | sudo tee -a "${SYSROOT}/etc/fstab"
        fi

        # SET USB-OTG

        if [[ "${DEV_USBOTG}" == "y" ]] ; then

            OTG_DEVICE="/dev/${DEV_FSTAB_MMC_PREFIX}3"

            if [ -z "$(cat ${SYSROOT}/etc/modules | grep g_mass_storage)" ]
                then preAuthRoot && echo "g_mass_storage" | sudo tee -a "${SYSROOT}/etc/modules"
            fi

            preAuthRoot && echo "options g_mass_storage removable=y ro=0 stall=0" | sudo tee "${SYSROOT}/etc/modprobe.d/g_mass_storage.conf"

            if [ "${DEV_USBOTG_AUTOINS}" == y ] ; then

                preAuthRoot && echo "#!/bin/bash
OTG_STAT=\$(realpath ${DEV_USBOTG_STATEF})
OTG_FILE=\$(realpath ${DEV_USBOTG_LUNF})
while ( [ -f \"\${OTG_STAT}\" ] && [ -f \"\${OTG_FILE}\" ] ) ; do
    DMESG=\"\$(dmesg -c | grep g_mass_storage)\"
    if ( ! [ -z \"\${DMESG}\" ] && [ \"\$(cat \${OTG_STAT})\" == \"configured\" ] ) ; then
        pkill \"${DEV_STORAGE_MNT}\"
        umount \"${DEV_STORAGE_MNT}\"
        rm -rf \"${DEV_STORAGE_MNT}\"
        sleep 1s ; sync
        echo \"${OTG_DEVICE}\" > \"\${OTG_FILE}\"
    elif ( [ \"\$(cat \${OTG_STAT})\" != \"configured\" ] && [ -z \"\$(mount | grep ${OTG_DEVICE})\" ] ) ; then
        echo \"\" > \"\${OTG_FILE}\"
        sleep 1s ; sync
        pkill \"${DEV_STORAGE_MNT}\"
        rm -rf \"${DEV_STORAGE_MNT}\"
        mkdir -p \"${DEV_STORAGE_MNT}\"
        MNT_FS=\"\$(cat /etc/fstab  | grep ${OTG_DEVICE} | awk '{print \$3}')\"
        MNT_OPT=\"\$(cat /etc/fstab | grep ${OTG_DEVICE} | awk '{print \$4}')\"
        mount -t \"\${MNT_FS}\" -o \"\${MNT_OPT}\" \"${OTG_DEVICE}\" \"${DEV_STORAGE_MNT}\"
    fi
    sleep 1s
done
exit 1" | sudo tee "${SYSROOT}/opt/otg_auto_insert.sh"

                preAuthRoot && sudo chroot "${SYSROOT}" chmod +x "/opt/otg_auto_insert.sh"

                preAuthRoot && echo "[Unit]
Description=USB-OTG auto insert
[Service]
ExecStart=/opt/otg_auto_insert.sh
[Install]
WantedBy=default.target" | sudo tee "${SYSROOT}/etc/systemd/system/otg_auto_insert.service"

                preAuthRoot && sudo chroot "${SYSROOT}" systemctl enable otg_auto_insert
            fi
        fi

    sync_fs

    #--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

    pushd "${USERDIR}"
        if ! [ -z "${DEV_POSTCONFIG}" ] ; then
            if ! [ -f "${DEV_POSTCONFIG}" ] ; then goto_exit 7 ; fi
            pushd $(dirname "${DEV_POSTCONFIG}")
                if ! ( eval ./$(basename "${DEV_POSTCONFIG}") ) ; then goto_exit 8 ; fi
            popd
        fi
    popd

    #--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

    sync_fs

    preAuthRoot && sudo umount "${SYSROOT}"

fi
