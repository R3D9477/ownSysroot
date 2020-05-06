#!/bin/bash

if ! ( preAuthRoot && sudo kpartx -av "${IMG_NAME}" ) ; then exit 1 ; fi

sleep 3s ; sync

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

preAuthRoot && readarray -t DEVARR <<< "$(sudo kpartx -l ${IMG_NAME})"

echo ""
echo ">>> kpartx output - ${DEVARR}"
echo ""

read  DEV1 VG <<< "${DEVARR[0]}"
read  DEV2 VG <<< "${DEVARR[1]}"
unset VG

echo ""
echo ">>> Devices to mount ${DEV1}, ${DEV2}"
echo ""

if ( [ -z "${DEV1}" ] || [ -z "${DEV2}" ] || [ -z "$(ls /dev/mapper/${DEV1})" ] || [ -z "$(ls /dev/mapper/${DEV2})" ] ) ; then

    echo ""
    echo ">>> DEVICE NOT FOUND"
    echo ""

    exit 2
fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! ( preAuthRoot && sudo mkfs.vfat -F 16 "/dev/mapper/${DEV1}" -n "BOOT" ) ; then exit 3 ; fi

if ( [ "${IMG_FMT_ON_MNT}" == "y" ] || ( [ "${IMG_FMT_ON_MNT}" == "a" ] && [ -z "$(fsck -N /dev/mapper/${DEV2} | grep ext4)" ] ) ) ; then

    echo ">>> Device /dev/mapper/${DEV2} will be formatted in"

    echo ""
    for i in $(seq 1 10); do echo "    $((11-$i)) second(s)..." ; sleep 1s ; done
    echo ""

    if ! ( preAuthRoot && sudo mkfs.ext4 "/dev/mapper/${DEV2}" -L "SYSROOT" ) ; then exit 4 ; fi
fi

sleep 3s ; sync

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! ( preAuthRoot && sudo mount "/dev/mapper/${DEV1}" "${BOOT}" ) ; then exit 5 ; fi
if ! ( preAuthRoot && sudo mount "/dev/mapper/${DEV2}" "${SYSROOT}" ) ; then exit 6 ; fi
