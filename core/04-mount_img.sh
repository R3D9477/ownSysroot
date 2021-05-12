#!/bin/bash

show_message "$(basename $0)"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

show_message "${IMG_NAME}"

if ! ( preAuthRoot && sudo kpartx -av "${IMG_NAME}" ) ; then goto_exit 1 ; fi

sleep 3s ; sync

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

preAuthRoot && readarray -t DEVARR <<< "$(sudo kpartx -l ${IMG_NAME})"

show_message "kpartx output - ${DEVARR}"

read  DEV1 VG <<< "${DEVARR[0]}"
read  DEV2 VG <<< "${DEVARR[1]}"
unset VG

show_message "Devices to mount ${DEV1}, ${DEV2}"

if ( [ -z "${DEV1}" ] || [ -z "${DEV2}" ] || [ -z "$(ls /dev/mapper/${DEV1})" ] || [ -z "$(ls /dev/mapper/${DEV2})" ] ) ; then

    show_message "DEVICE NOT FOUND!"

    goto_exit 2
fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

preAuthRoot && sudo wipefs --force --all "/dev/mapper/${DEV1}"
if ! ( preAuthRoot && sudo mkfs.vfat -F 16 "/dev/mapper/${DEV1}" -n "BOOT" ) ; then goto_exit 3 ; fi

IS_EXT4=$(preAuthRoot && sudo fsck -N /dev/mapper/${DEV2} | grep ext4)
if ( [ "${IMG_FMT_ON_MNT}" == "y" ] || ( [ "${IMG_FMT_ON_MNT}" == "a" ] && [ -z "${IS_EXT4}" ] ) ) ; then

    show_message_counter "Device /dev/mapper/${DEV2} will be formatted in:"

    preAuthRoot && sudo wipefs --force --all "/dev/mapper/${DEV2}"
    if ! ( preAuthRoot && sudo mkfs.ext4 "/dev/mapper/${DEV2}" -L "SYSROOT" ) ; then goto_exit 4 ; fi
fi

sleep 3s ; sync

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

if ! ( preAuthRoot && sudo mount "/dev/mapper/${DEV1}" "${BOOT}"    ) ; then goto_exit 5 ; fi
if ! ( preAuthRoot && sudo mount "/dev/mapper/${DEV2}" "${SYSROOT}" ) ; then goto_exit 6 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

fix_chmod
