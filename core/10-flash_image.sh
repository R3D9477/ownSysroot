#!/bin/bash

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# BURN IMAGE

preAuthRoot ; dd if="${IMG_NAME}" bs=32M | pv -s $(wc -c < "${IMG_NAME}") | sudo dd of="${HOST_MMC}" bs=32M
sleep 3s ; sync

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
# MAKE STORAGE IN A FREE SPACE

if [ -z "${DEV_STORAGE_FS}"  ] ; then exit 0 ; fi
if [ -z "${DEV_STORAGE_LBL}" ] ; then export DEV_STORAGE_LBL="STORAGE" ; fi
if [ -z "${DEV_STORAGE_MNT}" ] ; then export DEV_STORAGE_MNT="/mnt/storage" ; fi
if [ -z "${DEV_STORAGE_OTG}" ] ; then export DEV_STORAGE_OTG="y" ; fi

preAuthRoot && sudo wipefs --force --all "${HOST_MMC}3"
sleep 3s ; sync

preAuthRoot && sudo sfdisk --force --delete "${HOST_MMC}" 3
sleep 3s ; sync

preAuthRoot && echo ",$(sudo sfdisk -s ${HOST_MMC})" | sudo sfdisk --force --append "${HOST_MMC}" --no-reread
sleep 3s ; sync

if [ "${DEV_STORAGE_FS}" == "ext4" ] ; then

    if ! ( preAuthRoot && sudo mkfs.ext4 "${HOST_MMC}3" ) ; then exit 2 ; fi
    sleep 3s ; sync

    if ! ( preAuthRoot && sudo e2label "${HOST_MMC}3" "${DEV_STORAGE_LBL}" ) ; then exit 2 ; fi
    sleep 3s ; sync

    if ! ( preAuthRoot && sudo fsck.ext4 -a -w -v "${HOST_MMC}3" ) ; then exit 2 ; fi

    FSTAB_STORAGE_FS="ext4 defaults 0 0"

elif [ "${DEV_STORAGE_FS}" == "exfat" ] ; then

    if ! ( preAuthRoot && sudo mkfs.exfat "${HOST_MMC}3" ) ; then exit 2 ; fi
    sleep 3s ; sync

    if ! ( preAuthRoot && sudo exfatlabel "${HOST_MMC}3" "${DEV_STORAGE_LBL}" ) ; then exit 2 ; fi
    sleep 3s ; sync

    if ! ( preAuthRoot && sudo fsck.exfat "${HOST_MMC}3" ) ; then exit 2 ; fi

    FSTAB_STORAGE_FS="exfat-fuse defaults 0 0"

elif [ "${DEV_STORAGE_FS}" == "fat32" ] ; then

    if ! ( preAuthRoot && sudo mkfs.fat -F32 "${HOST_MMC}3" ) ; then exit 2 ; fi
    sleep 3s ; sync

    if ! ( preAuthRoot && sudo fatlabel "${HOST_MMC}3" "${DEV_STORAGE_LBL}" ) ; then exit 2 ; fi
    sleep 3s ; sync

    if ! ( preAuthRoot && sudo fsck.fat -a -w -v "${HOST_MMC}3" ) ; then exit 2 ; fi

    FSTAB_STORAGE_FS="vfat defaults 0 0"

else

    echo ""
    echo ">>> UNKNOWN STORAGE FILESYSTEM: ${DEV_STORAGE_FS}"
    echo ""

    exit 2
fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! [ -z "${DEV_FSTAB_MMC_PREFIX}" ] ; then

    preAuthRoot
    BOOT_UUID=$(sudo blkid -s UUID -o value "${HOST_MMC}1")
    SYSROOT_UUID=$(sudo blkid -s UUID -o value "${HOST_MMC}2")
    STORAGE_UUID=$(sudo blkid -s UUID -o value "${HOST_MMC}3")

    if ( [ -z "${BOOT_UUID}" ] || [ -z "${SYSROOT_UUID}" ] || [ -z "${STORAGE_UUID}" ] ) ; then exit 3 ; fi

    if ! ( preAuthRoot && sudo mount "${HOST_MMC}2" "${SYSROOT}" ) ; then exit 4 ; fi

        # --- SET FSTAB --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

        if ! ( preAuthRoot && sudo mkdir -p "${SYSROOT}/boot/efi" ) ; then exit 5 ; fi
        if ! ( preAuthRoot && sudo mkdir -p "${SYSROOT}${DEV_STORAGE_MNT}" ) ; then exit 6 ; fi

        if [ -z "${DEV_FSTAB_MMC_PREFIX}" ] ; then preAuthRoot && echo "UUID=${BOOT_UUID} /boot/efi vfat umask=0077 0 1" | sudo tee "${SYSROOT}/etc/fstab"
        else preAuthRoot && echo "/dev/${DEV_FSTAB_MMC_PREFIX}1 /boot/efi vfat umask=0077 0 1" | sudo tee "${SYSROOT}/etc/fstab"
        fi

        if [ -z "${DEV_FSTAB_MMC_PREFIX}" ] ; then preAuthRoot && echo "UUID=${SYSROOT_UUID} / ext4 errors=remount-ro 0 1" | sudo tee -a "${SYSROOT}/etc/fstab"
        else preAuthRoot && echo "/dev/${DEV_FSTAB_MMC_PREFIX}2 / ext4 errors=remount-ro 0 1" | sudo tee -a "${SYSROOT}/etc/fstab"
        fi

        if [ -z "${DEV_FSTAB_MMC_PREFIX}" ] ; then preAuthRoot && echo "UUID=${STORAGE_UUID} ${DEV_STORAGE_MNT} ${FSTAB_STORAGE_FS}" | sudo tee -a "${SYSROOT}/etc/fstab"
        else preAuthRoot && echo "/dev/${DEV_FSTAB_MMC_PREFIX}3 ${DEV_STORAGE_MNT} ${FSTAB_STORAGE_FS}" | sudo tee -a "${SYSROOT}/etc/fstab"
        fi

        # --- SET USB-OTG --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

        if [ "${DEV_STORAGE_OTG}" == "y" ] ; then

            preAuthRoot && echo "options g_mass_storage removable=y ro=0 stall=0" | sudo tee "${SYSROOT}/etc/modprobe.d/g_mass_storage.conf"

            if [ -z "$(cat ${SYSROOT}/etc/modules | grep g_mass_storage)" ] ; then
                preAuthRoot && echo "g_mass_storage" | sudo tee "${SYSROOT}/etc/modules"
            fi

            preAuthRoot && echo "#!/bin/bash
if pushd \$(realpath /sys/devices/soc*/soc*/2100000.aips-bus/2184000.usb/ci_hdrc.0/gadget) ; then
    OTG_DEVICE=\$(mount | grep ${DEV_STORAGE_MNT} | awk '{print \$1}')
    while true ; do
        if ! [ -z \"\$(dmesg -c | grep g_mass_storage)\" ] ; then
            if [ -f 'lun0/file' ] ; then
                if [ -z \"\$(cat 'lun0/file' | grep \${OTG_DEVICE})\" ] ; then
                    echo \"\${OTG_DEVICE}\" > 'lun0/file'
                fi
            fi
        fi
        sleep 3s
    done
    popd
fi" | sudo tee "${SYSROOT}/opt/otg_auto_insert.sh"

            preAuthRoot && sudo chroot "${SYSROOT}" chmod +x "/opt/otg_auto_insert.sh"

            preAuthRoot && echo "[Unit]
Description=USB-OTG auto insert
[Service]
ExecStart=/opt/otg_auto_insert.sh
[Install]
WantedBy=default.target" | sudo tee "${SYSROOT}/etc/systemd/system/otg_auto_insert.service"

            preAuthRoot && sudo chroot "${SYSROOT}" systemctl enable otg_auto_insert
        fi

        # --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

    sleep 3s ; sync

    preAuthRoot && sudo umount "${SYSROOT}"

fi
