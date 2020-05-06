#!/bin/bash

IMG_DD_ARGS="bs=1k seek=1 skip=0 oflag=dsync"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! ( dd if="/dev/zero" bs=1M count="${IMG_SIZE_MB}" >> "${IMG_NAME}" ) ; then exit 1 ; fi

sleep 3s ; sync

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if [ -f "${CACHE}/u-boot-${UBOOT_BRANCH}/SPL" ] ; then
    if ! ( dd conv=notrunc if="${CACHE}/u-boot-${UBOOT_BRANCH}/SPL" of="${IMG_NAME}" ${IMG_DD_ARGS} ) ; then exit 2 ; fi
    sync
    if [ -f "${CACHE}/u-boot-${UBOOT_BRANCH}/u-boot.img" ] ; then
        if ! ( dd conv=notrunc if="${CACHE}/u-boot-${UBOOT_BRANCH}/u-boot.img" of="${IMG_NAME}" bs=1K seek=69 ) ; then exit 2 ; fi
    fi
elif [ -f "${CACHE}/u-boot-${UBOOT_BRANCH}/u-boot.imx" ] ; then
    if ! ( dd conv=notrunc if="${CACHE}/u-boot-${UBOOT_BRANCH}/u-boot.imx" of="${IMG_NAME}" ${IMG_DD_ARGS} ) ; then exit 3 ; fi
else
    exit 3
fi

sleep 3s ; sync

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

sfdisk "${IMG_NAME}" << EOF
1M,50M,0xE,*
,,,-
EOF
